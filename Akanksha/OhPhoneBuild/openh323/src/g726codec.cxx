/*
 * g726codec.cxx
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
 * $Log: g726codec.cxx,v $
 * Revision 1.5  2002/11/09 07:07:10  robertj
 * Made public the media format names.
 * Other cosmetic changes.
 *
 * Revision 1.4  2002/09/03 07:28:42  robertj
 * Cosmetic change to formatting.
 *
 */

#include <ptlib.h>

#ifdef __GNUC__
#pragma implementation "g726codec.h"
#endif

#include "g726codec.h"

#include "rtp.h"

extern "C" {
#include "g726/g72x.h"
};


#define new PNEW


OpalMediaFormat const OpalG726_40(OPAL_G726_40,
                                  OpalMediaFormat::DefaultAudioSessionID,
                                  RTP_DataFrame::G721,
                                  TRUE,  // Needs jitter
                                  40000, // bits/sec
                                  5,  // 4 bytes per "frame"
                                  8,  // 1 millisecond
                                  OpalMediaFormat::AudioTimeUnits);

OpalMediaFormat const OpalG726_32(OPAL_G726_32,
                                  OpalMediaFormat::DefaultAudioSessionID,
                                  RTP_DataFrame::G721,
                                  TRUE,  // Needs jitter
                                  32000, // bits/sec
                                  4,  // 4 bytes per "frame"
                                  8,  // 1 millisecond
                                  OpalMediaFormat::AudioTimeUnits);

OpalMediaFormat const OpalG726_24(OPAL_G726_24,
                                  OpalMediaFormat::DefaultAudioSessionID,
                                  RTP_DataFrame::G721,
                                  TRUE,  // Needs jitter
                                  24000, // bits/sec
                                  3,  // 4 bytes per "frame"
                                  8,  // 1 millisecond
                                  OpalMediaFormat::AudioTimeUnits);

OpalMediaFormat const OpalG726_16(OPAL_G726_16,
                                  OpalMediaFormat::DefaultAudioSessionID,
                                  RTP_DataFrame::G721,
                                  TRUE,  // Needs jitter
                                  16000, // bits/sec
                                  2,  // 4 bytes per "frame"
                                  8,  // 1 millisecond
                                  OpalMediaFormat::AudioTimeUnits);


H323_REGISTER_CAPABILITY_FUNCTION(H323_G726_40_Capability, OPAL_G726_40"{sw}", ep)
{
  return new H323_G726_Capability(ep, H323_G726_Capability::e_40k);
}

H323_REGISTER_CAPABILITY_FUNCTION(H323_G726_32_Capability, OPAL_G726_32"{sw}", ep)
{
  return new H323_G726_Capability(ep, H323_G726_Capability::e_32k);
}

H323_REGISTER_CAPABILITY_FUNCTION(H323_G726_24_Capability, OPAL_G726_24"{sw}", ep)
{
  return new H323_G726_Capability(ep, H323_G726_Capability::e_24k);
}

H323_REGISTER_CAPABILITY_FUNCTION(H323_G726_16_Capability, OPAL_G726_16"{sw}", ep)
{
  return new H323_G726_Capability(ep, H323_G726_Capability::e_16k);
}


struct G726_NonStandardInfo {
  char name[10]; /// G.726-xxk
  BYTE count;
};


static G726_NonStandardInfo const G726_NonStandard[H323_G726_Capability::NumSpeeds] = {
  { OPAL_G726_40 },
  { OPAL_G726_32 },
  { OPAL_G726_24 },
  { OPAL_G726_16 }
};


/////////////////////////////////////////////////////////////////////////////

H323_G726_Capability::H323_G726_Capability(H323EndPoint & endpoint, Speeds s)
    : H323NonStandardAudioCapability(240, 10, endpoint,
                                     (const BYTE *)&G726_NonStandard[s],
                                     sizeof(G726_NonStandard),
                                     0, sizeof(G726_NonStandard[s].name))
{
  speed = s;
}


PObject * H323_G726_Capability::Clone() const
{
  return new H323_G726_Capability(*this);
}


PString H323_G726_Capability::GetFormatName() const
{
  return PString(G726_NonStandard[speed].name) + "{sw}";
}


BOOL H323_G726_Capability::OnSendingPDU(H245_AudioCapability & pdu,
                                        unsigned packetSize) const
{
  G726_NonStandardInfo * info = (G726_NonStandardInfo *)(const BYTE *)nonStandardData;
  info->count = (BYTE)packetSize;
  return H323NonStandardAudioCapability::OnSendingPDU(pdu, packetSize);
}


BOOL H323_G726_Capability::OnReceivedPDU(const H245_AudioCapability & pdu,
                                         unsigned & packetSize)
{
  if (!H323NonStandardAudioCapability::OnReceivedPDU(pdu, packetSize))
    return FALSE;

  const G726_NonStandardInfo * info = (const G726_NonStandardInfo *)(const BYTE *)nonStandardData;
  packetSize = info->count;
  return TRUE;
}


H323Codec * H323_G726_Capability::CreateCodec(H323Codec::Direction direction) const
{
  unsigned packetSize = 8*(direction == H323Codec::Encoder ? txFramesInPacket : rxFramesInPacket);

  return new H323_G726_Codec(speed, direction, packetSize);
}


/////////////////////////////////////////////////////////////////////////////

H323_G726_Codec::H323_G726_Codec(H323_G726_Capability::Speeds s,
                                 Direction dir,
                                 unsigned frameSize)
  : H323StreamedAudioCodec(G726_NonStandard[s].name, dir, frameSize, 5-s)
{
  speed = s;

  g726 = new g726_state_s;
  g726_init_state(g726);
  
  PTRACE(3, "Codec\t" <<  G726_NonStandard[speed].name << ' '
         << (dir == Encoder ? "en" : "de") << "coder created for "
         << frameSize << " samples");
}


H323_G726_Codec::~H323_G726_Codec()
{
  delete g726;
}


int H323_G726_Codec::Encode(short sample) const
{
  switch (speed) {
    case H323_G726_Capability::e_40k :
      return g726_40_encoder(sample, AUDIO_ENCODING_LINEAR, g726);
    case H323_G726_Capability::e_32k :
      return g726_32_encoder(sample, AUDIO_ENCODING_LINEAR, g726);
    case H323_G726_Capability::e_24k :
      return g726_24_encoder(sample, AUDIO_ENCODING_LINEAR, g726);
    case H323_G726_Capability::e_16k :
      return g726_16_encoder(sample, AUDIO_ENCODING_LINEAR, g726);
    default :
      PAssertAlways(PLogicError);
  }

  return 0;
}


short H323_G726_Codec::Decode(int sample) const
{
  switch (speed) {
    case H323_G726_Capability::e_40k :
      return (short)g726_40_decoder(sample, AUDIO_ENCODING_LINEAR, g726);
    case H323_G726_Capability::e_32k :
      return (short)g726_32_decoder(sample, AUDIO_ENCODING_LINEAR, g726);
    case H323_G726_Capability::e_24k :
      return (short)g726_24_decoder(sample, AUDIO_ENCODING_LINEAR, g726);
    case H323_G726_Capability::e_16k :
      return (short)g726_16_decoder(sample, AUDIO_ENCODING_LINEAR, g726);
    default :
      PAssertAlways(PLogicError);
  }

  return 0;
}


/////////////////////////////////////////////////////////////////////////////



