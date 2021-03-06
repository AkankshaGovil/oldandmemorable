/*
 * lpc10codec.cxx
 *
 * H.323 protocol handler
 *
 * Open H323 Library
 *
 * Copyright (c) 1998-2000 Equivalence Pty. Ltd.
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
 * $Log: lpc10codec.cxx,v $
 * Revision 1.11  2003/06/05 23:44:20  rjongbloed
 * Minor optimisations. Extremely minor.
 *
 * Revision 1.10  2003/04/27 23:51:19  craigs
 * Fixed possible problem with context deletion
 *
 * Revision 1.9  2002/09/03 06:01:16  robertj
 * Added globally accessible functions for media format name.
 *
 * Revision 1.8  2002/08/05 10:03:48  robertj
 * Cosmetic changes to normalise the usage of pragma interface/implementation.
 *
 * Revision 1.7  2001/09/21 02:51:29  robertj
 * Added default session ID to media format description.
 *
 * Revision 1.6  2001/05/14 05:56:28  robertj
 * Added H323 capability registration system so can add capabilities by
 *   string name instead of having to instantiate explicit classes.
 *
 * Revision 1.5  2001/02/09 05:13:56  craigs
 * Added pragma implementation to (hopefully) reduce the executable image size
 * under Linux
 *
 * Revision 1.4  2001/01/25 07:27:16  robertj
 * Major changes to add more flexible OpalMediaFormat class to normalise
 *   all information about media types, especially codecs.
 *
 * Revision 1.3  2000/07/12 10:25:37  robertj
 * Renamed all codecs so obvious whether software or hardware.
 *
 * Revision 1.2  2000/06/17 04:09:49  craigs
 * Fixed problem with (possibly bogus) underrun errors being reported in debug mode
 *
 * Revision 1.1  2000/06/05 04:45:11  robertj
 * Added LPC-10 2400bps codec
 *
 */

#include <ptlib.h>

#ifdef __GNUC__
#pragma implementation "lpc10codec.h"
#endif

#include "lpc10codec.h"

#include "rtp.h"

extern "C" {
#include "lpc10/lpc10.h"
};


#define new PNEW


enum {
  SamplesPerFrame = 180,    // 22.5 milliseconds
  BitsPerFrame = 54,        // Encoded size
  BytesPerFrame = (BitsPerFrame+7)/8
};


#define H323_NAME OPAL_LPC10 "{sw}"


H323_REGISTER_CAPABILITY_EP(H323_LPC10Capability, H323_NAME);

OpalMediaFormat const OpalLPC10(OPAL_LPC10,
                                OpalMediaFormat::DefaultAudioSessionID,
                                RTP_DataFrame::LPC,
                                TRUE,  // Needs jitter
                                2400,  // bits/sec
                                BytesPerFrame,
                                SamplesPerFrame,
                                OpalMediaFormat::AudioTimeUnits);


H323_LPC10Capability::H323_LPC10Capability(H323EndPoint & endpoint)
  : H323NonStandardAudioCapability(7, 4, endpoint,
                                   (const BYTE *)(const char *)OpalLPC10,
                                   OpalLPC10.GetLength())
{
}


PObject * H323_LPC10Capability::Clone() const
{
  return new H323_LPC10Capability(*this);
}


PString H323_LPC10Capability::GetFormatName() const
{
  return H323_NAME;
}


H323Codec * H323_LPC10Capability::CreateCodec(H323Codec::Direction direction) const
{
  return new H323_LPC10Codec(direction);
}


/////////////////////////////////////////////////////////////////////////////

H323_LPC10Codec::H323_LPC10Codec(Direction dir)
  : H323FramedAudioCodec(OpalLPC10, dir)
{
  if (dir == Encoder) {
    decoder = NULL;
    encoder = (struct lpc10_encoder_state *)malloc((unsigned)sizeof(struct lpc10_encoder_state));
    if (encoder != 0) 
      ::init_lpc10_encoder_state(encoder);
  }
  else {
    encoder = NULL;
    decoder = (struct lpc10_decoder_state *)malloc((unsigned)sizeof(struct lpc10_decoder_state));
    if (decoder != 0) 
      ::init_lpc10_decoder_state(decoder);
  }

  PTRACE(3, "Codec\tLPC-10 " << (dir == Encoder ? "en" : "de")
         << "coder created");
}


H323_LPC10Codec::~H323_LPC10Codec()
{
  if (encoder != NULL)
    free(encoder);
  if (decoder != NULL)
    free(decoder);
}


const real SampleValueScale = 32768.0;
const real MaxSampleValue = 32767.0;
const real MinSampleValue = -32767.0;

BOOL H323_LPC10Codec::EncodeFrame(BYTE * buffer, unsigned &)
{
  PINDEX i;

  real speech[SamplesPerFrame];
  for (i = 0; i < SamplesPerFrame; i++)
    speech[i] = sampleBuffer[i]/SampleValueScale;

  INT32 bits[BitsPerFrame];
  lpc10_encode(speech, bits, encoder);

  memset(buffer, 0, BytesPerFrame);
  for (i = 0; i < BitsPerFrame; i++) {
    if (bits[i])
      buffer[i>>3] |= 1 << (i&7);
  }

  return TRUE;
}


BOOL H323_LPC10Codec::DecodeFrame(const BYTE * buffer, unsigned length, unsigned &)
{
  if (length < BytesPerFrame)
    return FALSE;

  PINDEX i;

  INT32 bits[BitsPerFrame];
  for (i = 0; i < BitsPerFrame; i++)
    bits[i] = (buffer[i>>3]&(1<<(i&7))) != 0;

  real speech[SamplesPerFrame];
  lpc10_decode(bits, speech, decoder);

  for (i = 0; i < SamplesPerFrame; i++) {
    real sample = speech[i]*SampleValueScale;
    if (sample < MinSampleValue)
      sample = MinSampleValue;
    else if (sample > MaxSampleValue)
      sample = MaxSampleValue;
    sampleBuffer[i] = (short)sample;
  }

  return TRUE;
}


/////////////////////////////////////////////////////////////////////////////
