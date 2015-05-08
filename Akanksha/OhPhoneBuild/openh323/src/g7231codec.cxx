/*
 * g7231codec.cxx
 *
* H.323 interface for a G.723.1 codec
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
 * Contributor(s): ______________________________________.
 *
 * $Log: g7231codec.cxx,v $
 * Revision 1.6  2002/08/05 10:03:47  robertj
 * Cosmetic changes to normalise the usage of pragma interface/implementation.
 *
 * Revision 1.5  2002/07/02 23:13:32  robertj
 * Fixed copy & paste error in Compare() function, thanks Federico Pinna
 *
 * Revision 1.4  2002/06/25 08:27:38  robertj
 * Changes to differentiate between stright G.723.1 and G.723.1 Annex A using
 *   the OLC dataType silenceSuppression field so does not send SID frames
 *   to receiver codecs that do not understand them.
 *
 * Revision 1.3  2002/02/08 14:45:05  craigs
 * Changed to use #define from mediastream.h. Thanks to Roger Hardiman
 *
 * Revision 1.2  2001/09/21 03:57:49  robertj
 * Added missing includes.
 * Added pragma interface
 *
 * Revision 1.1  2001/09/21 02:54:47  robertj
 * Added new codec framework with no actual implementation.
 *
 */

#include <ptlib.h>

#ifdef __GNUC__
#pragma implementation "g7231codec.h"
#endif

#include "g7231codec.h"

#include "h245.h"
#include "rtp.h"


#ifdef ITU_REFERENCE_G7231
extern "C" {

#include "itu_g.723.1/typedef.h"
#include "itu_g.723.1/cst_lbc.h"
#include "itu_g.723.1/decod.h"
#include "itu_g.723.1/coder.h"

Flag UsePf = True;
Flag UseHp = True;
Flag UseVx = True;
enum Crate WrkRate = Rate63;

};
#endif


#define new PNEW


#define H323_NAME OPAL_G7231_6k3"{sw}"

H323_REGISTER_CAPABILITY(H323_G7231Capability, H323_NAME);


/////////////////////////////////////////////////////////////////////////////

H323_G7231Capability::H323_G7231Capability(BOOL annexA_)
  : H323AudioCapability(7, 4)
{
  annexA = annexA_;
}


PObject::Comparison H323_G7231Capability::Compare(const PObject & obj) const
{
  Comparison result = H323AudioCapability::Compare(obj);
  if (result != EqualTo)
    return result;

  PINDEX otherAnnexA = ((const H323_G7231Capability &)obj).annexA;
  if (annexA < otherAnnexA)
    return LessThan;
  if (annexA > otherAnnexA)
    return GreaterThan;
  return EqualTo;
}


PObject * H323_G7231Capability::Clone() const
{
  return new H323_G7231Capability(*this);
}


PString H323_G7231Capability::GetFormatName() const
{
  return H323_NAME;
}


unsigned H323_G7231Capability::GetSubType() const
{
  return H245_AudioCapability::e_g7231;
}


BOOL H323_G7231Capability::OnSendingPDU(H245_AudioCapability & cap,
                                          unsigned packetSize) const
{
  cap.SetTag(H245_AudioCapability::e_g7231);

  H245_AudioCapability_g7231 & g7231 = cap;
  g7231.m_maxAl_sduAudioFrames = packetSize;
  g7231.m_silenceSuppression = annexA;

  return TRUE;
}


BOOL H323_G7231Capability::OnReceivedPDU(const H245_AudioCapability & cap,
                                           unsigned & packetSize)
{
  if (cap.GetTag() != H245_AudioCapability::e_g7231)
    return FALSE;

  const H245_AudioCapability_g7231 & g7231 = cap;
  packetSize = g7231.m_maxAl_sduAudioFrames;
  annexA = g7231.m_silenceSuppression;

  return TRUE;
}


H323Codec * H323_G7231Capability::CreateCodec(H323Codec::Direction direction) const
{
  return new H323_G7231Codec(direction, annexA);
}


/////////////////////////////////////////////////////////////////////////////

H323_G7231Codec::H323_G7231Codec(Direction dir, BOOL /*annexA*/)
  : H323FramedAudioCodec(OpalG7231, dir)
{
#ifdef ITU_REFERENCE_G7231
  if (dir == Encoder) {
    decoderState = NULL;
    encoderState = new cod_state;
    ::Init_Coder(encoderState);
  }
  else {
    encoderState = NULL;
    decoderState = new dec_state;
    ::Init_Decod(decoderState);
  }
#endif

  PTRACE(3, "Codec\tG.723.1 " << (dir == Encoder ? "en" : "de")
         << "coder created");
}


H323_G7231Codec::~H323_G7231Codec()
{
#ifdef ITU_REFERENCE_G7231
  delete encoderState;
  delete decoderState;
#endif
}


static unsigned const FrameSizes[4] = { 24, 20, 4, 1 };

BOOL H323_G7231Codec::EncodeFrame(BYTE * buffer, unsigned & length)
{
#ifdef ITU_REFERENCE_G7231
  ::Coder(encoderState, sampleBuffer.GetPointer(), (char *)buffer);
#endif

  length = FrameSizes[*buffer&3];
  return TRUE;
}


BOOL H323_G7231Codec::DecodeFrame(const BYTE * buffer, unsigned length, unsigned & written)
{
  written = FrameSizes[*buffer&3];

  if (length < written)
    return FALSE;

#ifdef ITU_REFERENCE_G7231
  ::Decod(decoderState, sampleBuffer.GetPointer(), (char *)buffer, 0);
#endif
  return TRUE;
}


/////////////////////////////////////////////////////////////////////////////
