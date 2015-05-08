/*
 * speexcodec.cxx
 *
 * Speex codec handler
 *
 * Open H323 Library
 *
 * Copyright (c) 2002 Equivalence Pty. Ltd.
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
 * $Log: speexcodec.cxx,v $
 * Revision 1.20  2002/12/08 22:59:41  rogerh
 * Add XiphSpeex codec. Not yet finished.
 *
 * Revision 1.19  2002/12/06 10:11:54  rogerh
 * Back out the Xiph Speex changes on a tempoary basis while the Speex
 * spec is being redrafted.
 *
 * Revision 1.18  2002/12/06 03:27:47  robertj
 * Fixed MSVC warnings
 *
 * Revision 1.17  2002/12/05 12:57:17  rogerh
 * Speex now uses the manufacturer ID assigned to Xiph.Org.
 * To support existing applications using Speex, applications can use the
 * EquivalenceSpeex capabilities.
 *
 * Revision 1.16  2002/11/25 10:24:50  craigs
 * Fixed problem with Speex codec names causing mismatched capabilities
 * Reported by Ben Lear
 *
 * Revision 1.15  2002/11/09 07:08:20  robertj
 * Hide speex library from OPenH323 library users.
 * Made public the media format names.
 * Other cosmetic changes.
 *
 * Revision 1.14  2002/10/24 05:33:19  robertj
 * MSVC compatibility
 *
 * Revision 1.13  2002/10/22 11:54:32  rogerh
 * Fix including of speex.h
 *
 * Revision 1.12  2002/10/22 11:33:04  rogerh
 * Use the local speex.h header file
 *
 * Revision 1.11  2002/10/09 10:55:21  rogerh
 * Update the bit rates to match what the codec now does
 *
 * Revision 1.10  2002/09/02 21:58:40  rogerh
 * Update for Speex 0.8.0
 *
 * Revision 1.9  2002/08/21 06:49:13  rogerh
 * Fix the RTP Payload size too small problem with Speex 0.7.0.
 *
 * Revision 1.8  2002/08/15 18:34:51  rogerh
 * Fix some more bugs
 *
 * Revision 1.7  2002/08/14 19:06:53  rogerh
 * Fix some bugs when using the speex library
 *
 * Revision 1.6  2002/08/14 04:35:33  craigs
 * CHanged Speex names to remove spaces
 *
 * Revision 1.5  2002/08/14 04:30:14  craigs
 * Added bit rates to Speex codecs
 *
 * Revision 1.4  2002/08/14 04:27:26  craigs
 * Fixed name of Speex codecs
 *
 * Revision 1.3  2002/08/14 04:24:43  craigs
 * Fixed ifdef problem
 *
 * Revision 1.2  2002/08/13 14:25:25  craigs
 * Added trailing newlines to avoid Linux warnings
 *
 * Revision 1.1  2002/08/13 14:14:59  craigs
 * Initial version
 *
 */

#include <ptlib.h>

#ifdef __GNUC__
#pragma implementation "speexcodec.h"
#endif

#include "speexcodec.h"

#include "h323caps.h"
#include "h245.h"
#include "rtp.h"

extern "C" {
#include "speex/libspeex/speex.h"
};


#define new PNEW

#define XIPH_COUNTRY_CODE       0xB5  // (181) Country code for United States
#define XIPH_T35EXTENSION       0
#define XIPH_MANUFACTURER_CODE  0x0026 // Allocated by Delta Inc

#define EQUIVALENCE_COUNTRY_CODE       9  // Country code for Australia
#define EQUIVALENCE_T35EXTENSION       0
#define EQUIVALENCE_MANUFACTURER_CODE  61 // Allocated by Australian Communications Authority, Oct 2000

#define SAMPLES_PER_FRAME        160

#define SPEEX_BASE_NAME "Speex"

#define SPEEX_NARROW2_H323_NAME    SPEEX_BASE_NAME "Narrow-5.95k{sw}"
#define SPEEX_NARROW3_H323_NAME    SPEEX_BASE_NAME "Narrow-8k{sw}"
#define SPEEX_NARROW4_H323_NAME    SPEEX_BASE_NAME "Narrow-11k{sw}"
#define SPEEX_NARROW5_H323_NAME    SPEEX_BASE_NAME "Narrow-15k{sw}"
#define SPEEX_NARROW6_H323_NAME    SPEEX_BASE_NAME "Narrow-18.2k{sw}"

H323_REGISTER_CAPABILITY(SpeexNarrow2AudioCapability, SPEEX_NARROW2_H323_NAME);
H323_REGISTER_CAPABILITY(SpeexNarrow3AudioCapability, SPEEX_NARROW3_H323_NAME);
H323_REGISTER_CAPABILITY(SpeexNarrow4AudioCapability, SPEEX_NARROW4_H323_NAME);
H323_REGISTER_CAPABILITY(SpeexNarrow5AudioCapability, SPEEX_NARROW5_H323_NAME);
H323_REGISTER_CAPABILITY(SpeexNarrow6AudioCapability, SPEEX_NARROW6_H323_NAME);

#define XIPH_SPEEX_NARROW2_H323_NAME    SPEEX_BASE_NAME "Narrow-5.95k(Xiph){sw}"
#define XIPH_SPEEX_NARROW3_H323_NAME    SPEEX_BASE_NAME "Narrow-8k(Xiph){sw}"
#define XIPH_SPEEX_NARROW4_H323_NAME    SPEEX_BASE_NAME "Narrow-11k(Xiph){sw}"
#define XIPH_SPEEX_NARROW5_H323_NAME    SPEEX_BASE_NAME "Narrow-15k(Xiph){sw}"
#define XIPH_SPEEX_NARROW6_H323_NAME    SPEEX_BASE_NAME "Narrow-18.2k(Xiph){sw}"

H323_REGISTER_CAPABILITY(XiphSpeexNarrow2AudioCapability, XIPH_SPEEX_NARROW2_H323_NAME);
H323_REGISTER_CAPABILITY(XiphSpeexNarrow3AudioCapability, XIPH_SPEEX_NARROW3_H323_NAME);
H323_REGISTER_CAPABILITY(XiphSpeexNarrow4AudioCapability, XIPH_SPEEX_NARROW4_H323_NAME);
H323_REGISTER_CAPABILITY(XiphSpeexNarrow5AudioCapability, XIPH_SPEEX_NARROW5_H323_NAME);
H323_REGISTER_CAPABILITY(XiphSpeexNarrow6AudioCapability, XIPH_SPEEX_NARROW6_H323_NAME);

/////////////////////////////////////////////////////////////////////////

static int Speex_Bits_Per_Second(int mode) {
    void *tmp_coder_state;
    int bitrate;
    tmp_coder_state = speex_encoder_init(&speex_nb_mode);
    speex_encoder_ctl(tmp_coder_state, SPEEX_SET_QUALITY, &mode);
    speex_encoder_ctl(tmp_coder_state, SPEEX_GET_BITRATE, &bitrate);
    speex_encoder_destroy(tmp_coder_state); 
    return bitrate;
}

static int Speex_Bytes_Per_Frame(int mode) {
    int bits_per_frame = Speex_Bits_Per_Second(mode) / 50; // (20ms frame size)
    return ((bits_per_frame+7)/8); // round up
}

OpalMediaFormat const OpalSpeexNarrow_5k95(OPAL_SPEEX_NARROW_5k95,
                                           OpalMediaFormat::DefaultAudioSessionID,
                                           RTP_DataFrame::DynamicBase,
                                           TRUE,  // Needs jitter
                                           Speex_Bits_Per_Second(2),
                                           Speex_Bytes_Per_Frame(2),
                                           SAMPLES_PER_FRAME, // 20 milliseconds
                                           OpalMediaFormat::AudioTimeUnits);

OpalMediaFormat const OpalSpeexNarrow_8k(OPAL_SPEEX_NARROW_8k,
                                         OpalMediaFormat::DefaultAudioSessionID,
                                         RTP_DataFrame::DynamicBase,
                                         TRUE,  // Needs jitter
                                         Speex_Bits_Per_Second(3),
                                         Speex_Bytes_Per_Frame(3),
                                         SAMPLES_PER_FRAME, // 20 milliseconds
                                         OpalMediaFormat::AudioTimeUnits);

OpalMediaFormat const OpalSpeexNarrow_11k(OPAL_SPEEX_NARROW_11k,
                                          OpalMediaFormat::DefaultAudioSessionID,
                                          RTP_DataFrame::DynamicBase,
                                          TRUE,  // Needs jitter
                                          Speex_Bits_Per_Second(4),
                                          Speex_Bytes_Per_Frame(4),
                                          SAMPLES_PER_FRAME, // 20 milliseconds
                                          OpalMediaFormat::AudioTimeUnits);

OpalMediaFormat const OpalSpeexNarrow_15k(OPAL_SPEEX_NARROW_15k,
                                          OpalMediaFormat::DefaultAudioSessionID,
                                          RTP_DataFrame::DynamicBase,
                                          TRUE,  // Needs jitter
                                          Speex_Bits_Per_Second(5),
                                          Speex_Bytes_Per_Frame(5),
                                          SAMPLES_PER_FRAME, // 20 milliseconds
                                          OpalMediaFormat::AudioTimeUnits);

OpalMediaFormat const OpalSpeexNarrow_18k2(OPAL_SPEEX_NARROW_18k2,
                                           OpalMediaFormat::DefaultAudioSessionID,
                                           RTP_DataFrame::DynamicBase,
                                           TRUE,  // Needs jitter
                                           Speex_Bits_Per_Second(6),
                                           Speex_Bytes_Per_Frame(6),
                                           SAMPLES_PER_FRAME, // 20 milliseconds
                                           OpalMediaFormat::AudioTimeUnits);


/////////////////////////////////////////////////////////////////////////

SpeexNonStandardAudioCapability::SpeexNonStandardAudioCapability(int mode)
  : H323NonStandardAudioCapability(1, 1,
                                   EQUIVALENCE_COUNTRY_CODE,
                                   EQUIVALENCE_T35EXTENSION,
                                   EQUIVALENCE_MANUFACTURER_CODE,
                                   NULL, 0, 0, P_MAX_INDEX)
{
  PStringStream s;
  s << "Speex bs" << speex_nb_mode.bitstream_version << " Narrow" << mode;
  PINDEX len = s.GetLength();
  memcpy(nonStandardData.GetPointer(len), (const char *)s, len);
}


/////////////////////////////////////////////////////////////////////////

SpeexNarrow2AudioCapability::SpeexNarrow2AudioCapability()
  : SpeexNonStandardAudioCapability(2) 
{
}


PObject * SpeexNarrow2AudioCapability::Clone() const
{
  return new SpeexNarrow2AudioCapability(*this);
}


PString SpeexNarrow2AudioCapability::GetFormatName() const
{
  return SPEEX_NARROW2_H323_NAME;
}


H323Codec * SpeexNarrow2AudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new SpeexCodec(OpalSpeexNarrow_5k95, 2, direction);
}


/////////////////////////////////////////////////////////////////////////

SpeexNarrow3AudioCapability::SpeexNarrow3AudioCapability()
  : SpeexNonStandardAudioCapability(3) 
{
}


PObject * SpeexNarrow3AudioCapability::Clone() const
{
  return new SpeexNarrow3AudioCapability(*this);
}


PString SpeexNarrow3AudioCapability::GetFormatName() const
{
  return SPEEX_NARROW3_H323_NAME;
}


H323Codec * SpeexNarrow3AudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new SpeexCodec(OpalSpeexNarrow_8k, 3, direction);
}


/////////////////////////////////////////////////////////////////////////

SpeexNarrow4AudioCapability::SpeexNarrow4AudioCapability()
  : SpeexNonStandardAudioCapability(4) 
{
}


PObject * SpeexNarrow4AudioCapability::Clone() const
{
  return new SpeexNarrow4AudioCapability(*this);
}


PString SpeexNarrow4AudioCapability::GetFormatName() const
{
  return SPEEX_NARROW4_H323_NAME;
}


H323Codec * SpeexNarrow4AudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new SpeexCodec(OpalSpeexNarrow_11k, 4, direction);
}


/////////////////////////////////////////////////////////////////////////

SpeexNarrow5AudioCapability::SpeexNarrow5AudioCapability()
  : SpeexNonStandardAudioCapability(5) 
{
}


PObject * SpeexNarrow5AudioCapability::Clone() const
{
  return new SpeexNarrow5AudioCapability(*this);
}


PString SpeexNarrow5AudioCapability::GetFormatName() const
{
  return SPEEX_NARROW5_H323_NAME;
}


H323Codec * SpeexNarrow5AudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new SpeexCodec(OpalSpeexNarrow_15k, 5, direction);
}


/////////////////////////////////////////////////////////////////////////

SpeexNarrow6AudioCapability::SpeexNarrow6AudioCapability()
  : SpeexNonStandardAudioCapability(6) 
{
}


PObject * SpeexNarrow6AudioCapability::Clone() const
{
  return new SpeexNarrow6AudioCapability(*this);
}


PString SpeexNarrow6AudioCapability::GetFormatName() const
{
  return SPEEX_NARROW6_H323_NAME;
}


H323Codec * SpeexNarrow6AudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new SpeexCodec(OpalSpeexNarrow_18k2, 6, direction);
}


/////////////////////////////////////////////////////////////////////////

XiphSpeexNonStandardAudioCapability::XiphSpeexNonStandardAudioCapability(int mode)
  : H323NonStandardAudioCapability(1, 1,
                                   XIPH_COUNTRY_CODE,
                                   XIPH_T35EXTENSION,
                                   XIPH_MANUFACTURER_CODE,
                                   NULL, 0, 0, P_MAX_INDEX)
{
  // FIXME: To be replaced by an ASN defined block of data
  PStringStream s;
  s << "Speex bs" << speex_nb_mode.bitstream_version << " Narrow" << mode;
  PINDEX len = s.GetLength();
  memcpy(nonStandardData.GetPointer(len), (const char *)s, len);
}


/////////////////////////////////////////////////////////////////////////

XiphSpeexNarrow2AudioCapability::XiphSpeexNarrow2AudioCapability()
  : XiphSpeexNonStandardAudioCapability(2) 
{
}


PObject * XiphSpeexNarrow2AudioCapability::Clone() const
{
  return new XiphSpeexNarrow2AudioCapability(*this);
}


PString XiphSpeexNarrow2AudioCapability::GetFormatName() const
{
  return XIPH_SPEEX_NARROW2_H323_NAME;
}


H323Codec * XiphSpeexNarrow2AudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new SpeexCodec(OpalSpeexNarrow_5k95, 2, direction);
}


/////////////////////////////////////////////////////////////////////////

XiphSpeexNarrow3AudioCapability::XiphSpeexNarrow3AudioCapability()
  : XiphSpeexNonStandardAudioCapability(3) 
{
}


PObject * XiphSpeexNarrow3AudioCapability::Clone() const
{
  return new XiphSpeexNarrow3AudioCapability(*this);
}


PString XiphSpeexNarrow3AudioCapability::GetFormatName() const
{
  return XIPH_SPEEX_NARROW3_H323_NAME;
}


H323Codec * XiphSpeexNarrow3AudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new SpeexCodec(OpalSpeexNarrow_8k, 3, direction);
}


/////////////////////////////////////////////////////////////////////////

XiphSpeexNarrow4AudioCapability::XiphSpeexNarrow4AudioCapability()
  : XiphSpeexNonStandardAudioCapability(4) 
{
}


PObject * XiphSpeexNarrow4AudioCapability::Clone() const
{
  return new XiphSpeexNarrow4AudioCapability(*this);
}


PString XiphSpeexNarrow4AudioCapability::GetFormatName() const
{
  return XIPH_SPEEX_NARROW4_H323_NAME;
}


H323Codec * XiphSpeexNarrow4AudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new SpeexCodec(OpalSpeexNarrow_11k, 4, direction);
}


/////////////////////////////////////////////////////////////////////////

XiphSpeexNarrow5AudioCapability::XiphSpeexNarrow5AudioCapability()
  : XiphSpeexNonStandardAudioCapability(5) 
{
}


PObject * XiphSpeexNarrow5AudioCapability::Clone() const
{
  return new XiphSpeexNarrow5AudioCapability(*this);
}


PString XiphSpeexNarrow5AudioCapability::GetFormatName() const
{
  return XIPH_SPEEX_NARROW5_H323_NAME;
}


H323Codec * XiphSpeexNarrow5AudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new SpeexCodec(OpalSpeexNarrow_15k, 5, direction);
}


/////////////////////////////////////////////////////////////////////////

XiphSpeexNarrow6AudioCapability::XiphSpeexNarrow6AudioCapability()
  : XiphSpeexNonStandardAudioCapability(6) 
{
}


PObject * XiphSpeexNarrow6AudioCapability::Clone() const
{
  return new XiphSpeexNarrow6AudioCapability(*this);
}


PString XiphSpeexNarrow6AudioCapability::GetFormatName() const
{
  return XIPH_SPEEX_NARROW6_H323_NAME;
}


H323Codec * XiphSpeexNarrow6AudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new SpeexCodec(OpalSpeexNarrow_18k2, 6, direction);
}


/////////////////////////////////////////////////////////////////////////////

const float MaxSampleValue   = 32767.0;
const float MinSampleValue   = -32767.0;

SpeexCodec::SpeexCodec(const char * name, int mode, Direction dir)
  : H323FramedAudioCodec(name, dir)
{
  PTRACE(3, "Codec\tSpeex mode " << mode << " " << (dir == Encoder ? "en" : "de")
         << "coder created");

  bits = new SpeexBits;
  speex_bits_init(bits);

  if (direction == Encoder) {
    coder_state = speex_encoder_init(&speex_nb_mode);
    speex_encoder_ctl(coder_state, SPEEX_GET_FRAME_SIZE, &encoder_frame_size);
    speex_encoder_ctl(coder_state, SPEEX_SET_QUALITY,    &mode);
  } else {
    coder_state = speex_decoder_init(&speex_nb_mode);
  }
}

SpeexCodec::~SpeexCodec()
{
  speex_bits_destroy(bits);
  delete bits;

  if (direction == Encoder)
    speex_encoder_destroy(coder_state); 
  else
    speex_decoder_destroy(coder_state); 
}


BOOL SpeexCodec::EncodeFrame(BYTE * buffer, unsigned & length)
{
  // convert PCM to float
  float floatData[SAMPLES_PER_FRAME];
  PINDEX i;
  for (i = 0; i < SAMPLES_PER_FRAME; i++)
    floatData[i] = sampleBuffer[i];

  // encode PCM data in sampleBuffer to buffer
  speex_bits_reset(bits); 
  speex_encode(coder_state, floatData, bits); 

  length = speex_bits_write(bits, (char *)buffer, encoder_frame_size); 

  return TRUE;
}


BOOL SpeexCodec::DecodeFrame(const BYTE * buffer, unsigned length, unsigned &)
{
  float floatData[SAMPLES_PER_FRAME];

  // decode Speex data to floats
  speex_bits_read_from(bits, (char *)buffer, length); 
  speex_decode(coder_state, bits, floatData); 

  // convert float to PCM
  PINDEX i;
  for (i = 0; i < SAMPLES_PER_FRAME; i++) {
    float sample = floatData[i];
    if (sample < MinSampleValue)
      sample = MinSampleValue;
    else if (sample > MaxSampleValue)
      sample = MaxSampleValue;
    sampleBuffer[i] = (short)sample;
  }

  return TRUE;
}


/////////////////////////////////////////////////////////////////////////
