/*
 * ilbccodec.cxx
 *
 * Internet Low Bitrate Codec
 *
 * Open H323 Library
 *
 * Copyright (c) 2003 Equivalence Pty. Ltd.
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
 * $Log: ilbccodec.cxx,v $
 * Revision 1.1  2003/06/06 02:19:12  rjongbloed
 * Added iLBC codec
 *
 */

#include <ptlib.h>

#ifdef __GNUC__
#pragma implementation "ilbccodec.h"
#endif

#include "ilbccodec.h"

#include "rtp.h"

extern "C" {
#include "iLBC/iLBC_encode.h" 
#include "iLBC/iLBC_decode.h" 
};
    

#define new PNEW


#define H323_ILBC_13k3 OPAL_ILBC_13k3"{sw}"
#define H323_ILBC_15k2 OPAL_ILBC_15k2"{sw}"

H323_REGISTER_CAPABILITY_FUNCTION(H323_iLBC_Capability_13k3, H323_ILBC_13k3, ep)
  { return new H323_iLBC_Capability(ep, H323_iLBC_Capability::e_13k3); }

H323_REGISTER_CAPABILITY_FUNCTION(H323_iLBC_Capability_15k2, H323_ILBC_15k2, ep)
  { return new H323_iLBC_Capability(ep, H323_iLBC_Capability::e_15k2); }


OpalMediaFormat const OpaliLBC_13k3(OPAL_ILBC_13k3,
                                    OpalMediaFormat::DefaultAudioSessionID,
                                    RTP_DataFrame::DynamicBase,
                                    TRUE,  // Needs jitter
                                    NO_OF_BYTES_30MS*8*8000/BLOCKL_30MS,
                                    NO_OF_BYTES_30MS,
                                    BLOCKL_30MS,
                                    OpalMediaFormat::AudioTimeUnits);

OpalMediaFormat const OpaliLBC_15k2(OPAL_ILBC_15k2,
                                    OpalMediaFormat::DefaultAudioSessionID,
                                    RTP_DataFrame::DynamicBase,
                                    TRUE,  // Needs jitter
                                    NO_OF_BYTES_20MS*8*8000/BLOCKL_20MS,
                                    NO_OF_BYTES_20MS,
                                    BLOCKL_20MS,
                                    OpalMediaFormat::AudioTimeUnits);


/////////////////////////////////////////////////////////////////////////////

H323_iLBC_Capability::H323_iLBC_Capability(H323EndPoint & endpoint, Speed s)
  : H323NonStandardAudioCapability(7, speed == e_13k3 ? 3 : 4, endpoint,
                                   (const BYTE *)(s == e_13k3 ? OPAL_ILBC_13k3 : OPAL_ILBC_15k2))
{
  speed = s;
}


PObject * H323_iLBC_Capability::Clone() const
{
  return new H323_iLBC_Capability(*this);
}


PString H323_iLBC_Capability::GetFormatName() const
{
  return speed == e_13k3 ? H323_ILBC_13k3 : H323_ILBC_15k2;
}


H323Codec * H323_iLBC_Capability::CreateCodec(H323Codec::Direction direction) const
{
  return new H323_iLBC_Codec(direction, speed);
}


/////////////////////////////////////////////////////////////////////////////

H323_iLBC_Codec::H323_iLBC_Codec(Direction dir, H323_iLBC_Capability::Speed speed)
  : H323FramedAudioCodec(speed == H323_iLBC_Capability::e_13k3 ? OPAL_ILBC_13k3
                                                               : OPAL_ILBC_15k2,
                         dir)
{
  int ilbc_speed = speed == H323_iLBC_Capability::e_13k3 ? 30 : 20;

  if (dir == Encoder) {
    decoder = NULL;
    encoder = (struct iLBC_Enc_Inst_t_ *)malloc((unsigned)sizeof(struct iLBC_Enc_Inst_t_));
    if (encoder != 0) 
      initEncode(encoder, ilbc_speed); 
  }
  else {
    encoder = NULL;
    decoder = (struct iLBC_Dec_Inst_t_ *)malloc((unsigned)sizeof(struct iLBC_Dec_Inst_t_));
    if (decoder != 0) 
      initDecode(decoder, ilbc_speed, 1); 
  }

  PTRACE(3, "Codec\tILBC " << (dir == Encoder ? "en" : "de")
         << "coder created");
}


H323_iLBC_Codec::~H323_iLBC_Codec()
{
  if (encoder != NULL)
    free(encoder);
  if (decoder != NULL)
    free(decoder);
}


BOOL H323_iLBC_Codec::EncodeFrame(BYTE * buffer, unsigned & length)
{
  float block[BLOCKL_MAX];

  /* convert signal to float */
  for (int i = 0; i < encoder->blockl; i++)
    block[i] = (float)sampleBuffer[i];

  /* do the actual encoding */
  iLBC_encode(buffer, block, encoder);
  length = encoder->no_of_bytes;

  return TRUE; 
}


BOOL H323_iLBC_Codec::DecodeFrame(const BYTE * buffer, unsigned length, unsigned &)
{
  if (length < (unsigned)decoder->no_of_bytes)
    return FALSE;

  float block[BLOCKL_MAX];

  /* do actual decoding of block */ 
  iLBC_decode(block, (unsigned char *)buffer, decoder, 1);

  /* convert to short */     
  for (int i = 0; i < decoder->blockl; i++) {
    float tmp = block[i];
    if (tmp < MIN_SAMPLE)
      tmp = MIN_SAMPLE;
    else if (tmp > MAX_SAMPLE)
      tmp = MAX_SAMPLE;
    sampleBuffer[i] = (short)tmp;
  }

  return TRUE;
}


/////////////////////////////////////////////////////////////////////////////
