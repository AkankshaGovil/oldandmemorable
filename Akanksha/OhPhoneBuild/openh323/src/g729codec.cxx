/*
 * g729codec.cxx
 *
 * H.323 interface for G.729A codec
 *
 * Open H323 Library
 *
 * Copyright (c) 2001 Equivalence Pty. Ltd.
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
 * the License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is Open H323 Library.
 *
 * The Initial Developer of the Original Code is Equivalence Pty. Ltd.
 *
 * Portions of this code were written with the assisance of funding from
 * Vovida Networks, Inc. http://www.vovida.com.
 *
 * Contributor(s): ______________________________________.
 *
 * $Log: g729codec.cxx,v $
 * Revision 1.7  2003/05/05 11:59:25  robertj
 * Changed to use autoconf style selection of options and subsystems.
 *
 * Revision 1.6  2002/11/12 00:07:12  robertj
 * Added check for Voice Age G.729 only being able to do a single instance
 *   of the encoder and decoder. Now fails the second isntance isntead of
 *   interfering with the first one.
 *
 * Revision 1.5  2002/08/05 10:03:47  robertj
 * Cosmetic changes to normalise the usage of pragma interface/implementation.
 *
 * Revision 1.4  2002/06/27 03:13:11  robertj
 * Added G.729 capabilitity support even though is really G.729A.
 * Changed compilation under Windows to use environment variables for
 *   determining if Voice Age G.729A library installed.
 *
 * Revision 1.3  2001/09/21 04:37:30  robertj
 * Added missing GetSubType() function.
 *
 * Revision 1.2  2001/09/21 03:57:18  robertj
 * Fixed warning when no voice age library present.
 * Added pragma interface
 *
 * Revision 1.1  2001/09/21 02:54:47  robertj
 * Added new codec framework with no actual implementation.
 *
 */

#include <ptlib.h>

#ifdef __GNUC__
#pragma implementation "g729codec.h"
#endif

#include "g729codec.h"

#include "h245.h"


#if VOICE_AGE_G729A

extern "C" {
#include "va_g729a.h"
};


#if defined(_MSC_VER)

#pragma comment(lib, VOICE_AGE_G729_LIBRARY)

// All of PWLib/OpenH323 use MSVCRT.LIB or MSVCRTD.LIB, but vag729a.lib uses
// libcmt.lib, so we need to tell the linker to ignore it, can't have two
// Run Time libraries!
#pragma comment(linker, "/NODEFAULTLIB:libcmt.lib")

#endif


#define new PNEW


#define H323_G729  OPAL_G729 "{sw}"
#define H323_G729A OPAL_G729A"{sw}"
static H323_G729ACodec * voiceAgeEncoderInUse = NULL;
static H323_G729ACodec * voiceAgeDecoderInUse = NULL;

H323_REGISTER_CAPABILITY(H323_G729Capability,  H323_G729);
H323_REGISTER_CAPABILITY(H323_G729ACapability, H323_G729A);


/////////////////////////////////////////////////////////////////////////////

H323_G729Capability::H323_G729Capability()
  : H323AudioCapability(24, 6)
{
}


PObject * H323_G729Capability::Clone() const
{
  return new H323_G729Capability(*this);
}


unsigned H323_G729Capability::GetSubType() const
{
  return H245_AudioCapability::e_g729;
}


PString H323_G729Capability::GetFormatName() const
{
  return H323_G729;
}


H323Codec * H323_G729Capability::CreateCodec(H323Codec::Direction direction) const
{
  return new H323_G729ACodec(direction);
}


/////////////////////////////////////////////////////////////////////////////

H323_G729ACapability::H323_G729ACapability()
  : H323AudioCapability(24, 6)
{
}


PObject * H323_G729ACapability::Clone() const
{
  return new H323_G729ACapability(*this);
}


unsigned H323_G729ACapability::GetSubType() const
{
  return H245_AudioCapability::e_g729AnnexA;
}


PString H323_G729ACapability::GetFormatName() const
{
  return H323_G729A;
}


H323Codec * H323_G729ACapability::CreateCodec(H323Codec::Direction direction) const
{
  return new H323_G729ACodec(direction);
}


/////////////////////////////////////////////////////////////////////////////

H323_G729ACodec::H323_G729ACodec(Direction dir)
  : H323FramedAudioCodec(OpalG729A, dir)
{
  if(dir == Encoder) {
    if (voiceAgeEncoderInUse != NULL) {
      PTRACE(1, "Codec\tVoice Age G.729A encoder already in use!");
      return;
    }
    voiceAgeEncoderInUse = this;
    va_g729a_init_encoder();
  }
  else {
    if (voiceAgeDecoderInUse != NULL) {
      PTRACE(1, "Codec\tVoice Age G.729A decoder already in use!");
      return;
    }
    voiceAgeDecoderInUse = this;
    va_g729a_init_decoder();
  }

  PTRACE(1, "Codec\tG.729A " << (dir == Encoder ? " en" : " de") << "coder created");
}


H323_G729ACodec::~H323_G729ACodec()
{
  if (voiceAgeEncoderInUse == this) {
    voiceAgeEncoderInUse = NULL;
    PTRACE(1, "Codec\tG.729A encoder destroyed");
  }
  if (voiceAgeDecoderInUse == this) {
    voiceAgeDecoderInUse = NULL;
    PTRACE(1, "Codec\tG.729A decoder destroyed");
  }
}


BOOL H323_G729ACodec::EncodeFrame(BYTE * buffer, unsigned & /*length*/)
{
  if (voiceAgeEncoderInUse != this)
    return FALSE;

  va_g729a_encoder(sampleBuffer.GetPointer(), buffer);
  return TRUE;
}


BOOL H323_G729ACodec::DecodeFrame(const BYTE * buffer,
                                  unsigned length,
                                  unsigned & /*written*/)
{
  if (voiceAgeDecoderInUse != this)
    return FALSE;

  if (length < L_FRAME_COMPRESSED)
    return FALSE;

  va_g729a_decoder((BYTE*)buffer, sampleBuffer.GetPointer(), 0);
  return TRUE;
}


#endif // VOICE_AGE_G729A


/////////////////////////////////////////////////////////////////////////////
