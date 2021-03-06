/*
 * mscodecs.cxx
 *
 * Microsoft nonstandard codecs handler
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
 * $Log: mscodecs.cxx,v $
 * Revision 1.15  2002/09/30 09:33:03  craigs
 * Removed ability to set no. of frames per packet for MS-GSM - there can be only one!
 *
 * Revision 1.14  2002/09/03 06:03:48  robertj
 * Added globally accessible functions for media format name.
 *
 * Revision 1.13  2002/08/19 00:36:40  craigs
 * Fixed Clone function
 *
 * Revision 1.12  2002/08/05 10:03:48  robertj
 * Cosmetic changes to normalise the usage of pragma interface/implementation.
 *
 * Revision 1.11  2001/09/21 02:51:29  robertj
 * Added default session ID to media format description.
 *
 * Revision 1.10  2001/05/14 05:56:28  robertj
 * Added H323 capability registration system so can add capabilities by
 *   string name instead of having to instantiate explicit classes.
 *
 * Revision 1.9  2001/03/08 01:42:22  robertj
 * Cosmetic changes to recently added MS IMA ADPCM codec.
 *
 * Revision 1.8  2001/03/08 00:57:46  craigs
 * Added MS-IMA codec thanks to Liu Hao. Not yet working - do not use
 *
 * Revision 1.7  2001/02/09 05:13:56  craigs
 * Added pragma implementation to (hopefully) reduce the executable image size
 * under Linux
 *
 * Revision 1.6  2001/01/25 07:27:17  robertj
 * Major changes to add more flexible OpalMediaFormat class to normalise
 *   all information about media types, especially codecs.
 *
 * Revision 1.5  2001/01/09 23:05:24  robertj
 * Fixed inability to have 2 non standard codecs in capability table.
 *
 * Revision 1.4  2000/08/31 02:57:51  craigs
 * Finally got it working
 *
 * Revision 1.3  2000/08/31 01:06:08  craigs
 * More changes to mscodecs
 *
 * Revision 1.2  2000/08/25 03:18:40  craigs
 * More work on support for MS-GSM format
 *
 * Revision 1.1  2000/08/23 14:27:04  craigs
 * Added prototype support for Microsoft GSM codec
 *
 *
 */

#include <ptlib.h>

#ifdef __GNUC__
#pragma implementation "mscodecs.h"
#endif

#include "mscodecs.h"

#include "h323caps.h"
#include "h245.h"
#include "rtp.h"

extern "C" {
#include "gsm/inc/gsm.h"
};


#define	MICROSOFT_COUNTRY_CODE	181
#define	MICROSOFT_T35EXTENSION	0
#define	MICROSOFT_MANUFACTURER	21324

#define	GSM_BYTES_PER_FRAME 65

#define new PNEW


#define GSM_H323_NAME OPAL_MSGSM "{sw}"


H323_REGISTER_CAPABILITY(MicrosoftGSMAudioCapability, GSM_H323_NAME);

OpalMediaFormat const OpalMSGSM(OPAL_MSGSM,
                                OpalMediaFormat::DefaultAudioSessionID,
                                RTP_DataFrame::DynamicBase,
                                TRUE,  // Needs jitter
                                13200, // bits/sec
                                GSM_BYTES_PER_FRAME,
                                320, // 40 milliseconds
                                OpalMediaFormat::AudioTimeUnits);


/////////////////////////////////////////////////////////////////////////

MicrosoftNonStandardAudioCapability::MicrosoftNonStandardAudioCapability(
            const BYTE * header,
            PINDEX headerSize,
            PINDEX offset,
            PINDEX len)

  : H323NonStandardAudioCapability(1, 1,
                                   MICROSOFT_COUNTRY_CODE,
                                   MICROSOFT_T35EXTENSION,
                                   MICROSOFT_MANUFACTURER,
                                   header, headerSize, offset, len)
{
}
                                                                         

/////////////////////////////////////////////////////////////////////////

static const BYTE msGSMHeader[] = {

  // unknown data
  0x02, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x40, 0x01, 
  0x00, 0x00, 0x40, 0x01, 
  0x02, 0x00, 0x08, 0x00, 
  0x00, 0x00, 0x00, 0x00,

#define	GSM_FIXED_START 20  // Offset to this point in header

  // standard MS waveformatex structure follows
  0x31, 0x00,                 //    WORD    wFormatTag;        /* format type */
  0x01, 0x00,                 //    WORD    nChannels;         /* number of channels (i.e. mono, stereo...) */
  0x40, 0x1f, 0x00, 0x00,     //    DWORD   nSamplesPerSec;    /* sample rate */  
  0x59, 0x06, 0x00, 0x00,     //    DWORD   nAvgBytesPerSec;   /* for buffer estimation */
  0x41, 0x00,                 //    WORD    nBlockAlign;       /* block size of data */
  0x00, 0x00,                 //    WORD    wBitsPerSample;    /* Number of bits per sample of mono data */
  0x02, 0x00,                 //    WORD    cbSize;            /* The count in bytes of the size of 

#define	GSM_FIXED_LEN 18  // Number of bytes from GSM_FIXED_START to here 

  // extra GSM information
  0x40, 0x01,                 //    WORD    numberOfSamples    /* 320 */
  
  // unknown data
  0x00, 0x00  
};

MicrosoftGSMAudioCapability::MicrosoftGSMAudioCapability()
  : MicrosoftNonStandardAudioCapability(msGSMHeader, sizeof(msGSMHeader), GSM_FIXED_START, GSM_FIXED_LEN)
{
  txFramesInPacket = 1;
}

void MicrosoftGSMAudioCapability::SetTxFramesInPacket(unsigned /*frames*/)
{
}

PObject * MicrosoftGSMAudioCapability::Clone() const
{
  return new MicrosoftGSMAudioCapability(*this);
}


PString MicrosoftGSMAudioCapability::GetFormatName() const
{
  return GSM_H323_NAME;
}


H323Codec * MicrosoftGSMAudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new MicrosoftGSMCodec(direction);
}

/////////////////////////////////////////////////////////////////////////////

MicrosoftGSMCodec::MicrosoftGSMCodec(Direction dir)
  : H323FramedAudioCodec(OpalMSGSM, dir)
{
  gsm = gsm_create();
  int opt = 1;
  gsm_option(gsm, GSM_OPT_WAV49, &opt);
  PTRACE(3, "Codec\tMS-GSM " << (dir == Encoder ? "en" : "de")
         << "coder created");
}

MicrosoftGSMCodec::~MicrosoftGSMCodec()
{
  gsm_destroy(gsm);
}

BOOL MicrosoftGSMCodec::EncodeFrame(BYTE * buffer, unsigned &)
{
  // the first frame is encoded at the start of the buffer
  gsm_encode(gsm, sampleBuffer.GetPointer(), buffer);

  // the second frame is encoded partially through the buffer
  gsm_encode(gsm, sampleBuffer.GetPointer()+160, buffer+32);

  return TRUE;
}


BOOL MicrosoftGSMCodec::DecodeFrame(const BYTE * buffer, unsigned length, unsigned &)
{
  if (length != GSM_BYTES_PER_FRAME)
    return FALSE;

  // decode the first frame 
  gsm_decode(gsm, (BYTE *)buffer, sampleBuffer.GetPointer());

  // decode the second frame 
  gsm_decode(gsm, (BYTE *)buffer+33, sampleBuffer.GetPointer()+160);

  return TRUE;
}

/////////////////////////////////////////////////////////////////////////

//By LH, Microsoft IMA ADPCM CODEC Capability
#define IMA_MAX_PACKET_SIZE 		1
#define IMA_DESIRED_TRANSMIT_SIZE	1

#define IMA_SAMPLES_PER_FRAME		505
#define IMA_BYTES_PER_FRAME		256

#define IMA_FIXED_START			20
#define IMA_FIXED_LEN			18

static const BYTE msIMAHeader[] = {

  // unknown data
  0x02, 0x00, 0x00, 0x00,
  0x00, 0x00, 0xf9, 0x01,
  0x00, 0x00, 0xf9, 0x01,
  0x01, 0x00, 0x04, 0x00,
  0x00, 0x00, 0x00, 0x00,

  // standard MS waveformatex structure follows
  0x11, 0x00,                 //    WORD    wFormatTag;        /* format type */
  0x01, 0x00,                 //    WORD    nChannels;         /* number of channels (i.e. mono, stereo...) */
  0x40, 0x1f, 0x00, 0x00,     //    DWORD   nSamplesPerSec;    /* sample rate */
  0xd7, 0x0f, 0x00, 0x00,     //    DWORD   nAvgBytesPerSec;   /* for buffer estimation */
  0x00, 0x01,                 //    WORD    nBlockAlign;       /* block size of data */
  0x04, 0x00,                 //    WORD    wBitsPerSample;    /* Number of bits per sample of mono data */
  0x02, 0x00,                 //    WORD    cbSize;            /* The count in bytes of the size of

  // extra IMA information
  0xf9, 0x01, 		      //    WORD    numberOfSamples    /* 505 */

  // unknown data
  0x00, 0x00 

};


#define IMA_H323_NAME OPAL_MSIMA "{sw}"


H323_REGISTER_CAPABILITY(MicrosoftIMAAudioCapability, IMA_H323_NAME);

OpalMediaFormat const OpalMSIMA(OPAL_MSIMA,
                                OpalMediaFormat::DefaultAudioSessionID,
                                RTP_DataFrame::DynamicBase,
                                TRUE,  // Needs jitter
                                32443, // bits/sec
                                IMA_BYTES_PER_FRAME,
                                IMA_SAMPLES_PER_FRAME, // 63.1 milliseconds
                                OpalMediaFormat::AudioTimeUnits);


MicrosoftIMAAudioCapability::MicrosoftIMAAudioCapability()
  : MicrosoftNonStandardAudioCapability(msIMAHeader, sizeof(msIMAHeader),
                                        IMA_FIXED_START, IMA_FIXED_LEN)
{
}

PObject * MicrosoftIMAAudioCapability::Clone() const
{
  return new MicrosoftIMAAudioCapability(*this);
}


PString MicrosoftIMAAudioCapability::GetFormatName() const
{
  return IMA_H323_NAME;
}


H323Codec * MicrosoftIMAAudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new MicrosoftIMACodec(direction);
}

/////////////////////////////////////////////////////////////////////////////


MicrosoftIMACodec::MicrosoftIMACodec(Direction dir)
  : H323FramedAudioCodec(OpalMSIMA, dir)
{
  PTRACE(3, "Codec\tOnStartup ");
  s_adpcm.valprev = 0;
  s_adpcm.index = 0;
  PTRACE(3, "Codec\tMS-IMA " << (dir == Encoder ? "en" : "de") << "coder created");
}

MicrosoftIMACodec::~MicrosoftIMACodec()
{
}


/* Intel ADPCM step variation table */
static int indexTable[16] = {
    -1, -1, -1, -1, 2, 4, 6, 8,
    -1, -1, -1, -1, 2, 4, 6, 8
};

static int stepsizeTable[89] = {
    7, 8, 9, 10, 11, 12, 13, 14, 16, 17,
    19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
    50, 55, 60, 66, 73, 80, 88, 97, 107, 118,
    130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
    337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
    876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
    2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358,
    5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899,
    15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767
};


static void adpcm_coder(short indata[], char outdata[], int len, struct adpcm_state *state)
{
    short *inp;                 /* Input buffer pointer */
    signed char *outp;          /* output buffer pointer */
    int val;                    /* Current input sample value */
    int sign;                   /* Current adpcm sign bit */
    int delta;                  /* Current adpcm output value */
    int diff;                   /* Difference between val and valprev */
    int step;                   /* Stepsize */
    int valpred;                /* Predicted output value */
    int vpdiff;                 /* Current change to valpred */
    char index;                 /* Current step change index */
    int outputbuffer = 0;       /* place to keep previous 4-bit value */
    int bufferstep;             /* toggle between outputbuffer/output */

    outp = (signed char *)outdata;
    inp = indata;

    //create header
    valpred = *inp;
    memcpy(outp, (char *)inp, 2);
    inp++;
    outp += sizeof(short);

    index = state->index;
    memcpy(outp, (char *)&index, 1);
    inp++;
    outp++;
    *outp = 0;
    outp++;
    //create header ends

    len--;

    step = stepsizeTable[index];

    bufferstep = 1;

    for ( ; len > 0 ; len-- ) {
        val = *inp++;

        /* Step 1 - compute difference with previous value */
        diff = val - valpred;
        sign = (diff < 0) ? 8 : 0;
        if ( sign ) diff = (-diff);

        /* Step 2 - Divide and clamp */
        /* Note:
        ** This code *approximately* computes:
        **    delta = diff*4/step;
        **    vpdiff = (delta+0.5)*step/4;
        ** but in shift step bits are dropped. The net result of this is
        ** that even if you have fast mul/div hardware you cannot put it to
        ** good use since the fixup would be too expensive.
        */
        delta = 0;
        vpdiff = (step >> 3);

        if ( diff >= step ) {
            delta = 4;
            diff -= step;
            vpdiff += step;
        }
        step >>= 1;
        if ( diff >= step  ) {
            delta |= 2;
            diff -= step;
            vpdiff += step;
        }
        step >>= 1;
        if ( diff >= step ) {
            delta |= 1;
            vpdiff += step;
        }

        /* Step 3 - Update previous value */
        if ( sign )
          valpred -= vpdiff;
        else
          valpred += vpdiff;

        /* Step 4 - Clamp previous value to 16 bits */
        if ( valpred > 32767 )
          valpred = 32767;
        else if ( valpred < -32768 )
          valpred = -32768;

        /* Step 5 - Assemble value, update index and step values */
        delta |= sign;
        index = (char)(index + indexTable[delta]);
        if ( index < 0 ) index = 0;
        if ( index > 88 ) index = 88;
        step = stepsizeTable[index];

        /* Step 6 - Output value */
        if ( bufferstep ) {
            outputbuffer = (delta << 4) & 0xf0;
        } else {
            *outp++ = (char)((delta & 0x0f) | outputbuffer);
        }
        bufferstep = !bufferstep;
    }

    /* Output last step, if needed */
    if ( !bufferstep )
      *outp++ = (char)outputbuffer;

    state->valprev = (short)valpred;
    state->index = index;

}

static void adpcm_decoder(char indata[], short outdata[], int len)
{
    signed char *inp;           /* Input buffer pointer */
    short *outp;                /* output buffer pointer */
    int sign;                   /* Current adpcm sign bit */
    int delta;                  /* Current adpcm output value */
    int step;                   /* Stepsize */
    int valpred;                /* Predicted value */
    int vpdiff;                 /* Current change to valpred */
    int index;                  /* Current step change index */
    int inputbuffer = 0;        /* place to keep next 4-bit value */
    int bufferstep;             /* toggle between inputbuffer/input */

    outp = outdata;
    inp = (signed char *)indata;

    valpred = 0;
    index = 0;
    memcpy((char *)&valpred, (char *)inp, 2);
    inp += 2; //skip first 16 bits sample
    index = (int)(unsigned char)*inp;
    inp += 2; //skip index

    step = stepsizeTable[index];
    len -= 4; //skip header

    bufferstep = 0;

    len *= 2;

    for ( ; len > 0 ; len-- ) {
        /* Step 1 - get the delta value */
        if ( bufferstep ) {
            delta = inputbuffer & 0xf;
        } else {
            inputbuffer = *inp++;
            delta = (inputbuffer >> 4) & 0xf;
        }
        bufferstep = !bufferstep;

        /* Step 2 - Find new index value (for later) */
        index += indexTable[delta];
        if ( index < 0 ) index = 0;
        if ( index > 88 ) index = 88;

        /* Step 3 - Separate sign and magnitude */
        sign = delta & 8;
        delta = delta & 7;
        /* Step 4 - Compute difference and new predicted value */
        /*
        ** Computes 'vpdiff = (delta+0.5)*step/4', but see comment
        ** in adpcm_coder.
        */
        vpdiff = step >> 3;
        if ( delta & 4 ) vpdiff += step;
        if ( delta & 2 ) vpdiff += step>>1;
        if ( delta & 1 ) vpdiff += step>>2;

        if ( sign )
          valpred -= vpdiff;
        else
          valpred += vpdiff;

        /* Step 5 - clamp output value */
        if ( valpred > 32767 )
          valpred = 32767;
        else if ( valpred < -32768 )
          valpred = -32768;

        /* Step 6 - Update step value */
        step = stepsizeTable[index];

        /* Step 7 - Output value */
        *outp++ = (char)valpred;
    }
}



BOOL MicrosoftIMACodec::EncodeFrame(BYTE * buffer, unsigned &)
{
  PTRACE(5, "MS_IMA is encoding frame");

  // IMA_SAMPLES_PER_FRAME:505
  // sample must be linear 16 bits sample PCM
  adpcm_coder(sampleBuffer.GetPointer(), (char *)buffer, IMA_SAMPLES_PER_FRAME, &s_adpcm);

  return TRUE;
}


BOOL MicrosoftIMACodec::DecodeFrame(const BYTE * buffer, unsigned length, unsigned &)
{
  //IMA_BYTES_PER_FRAME	256
  PTRACE(5, "MS-IMA is decoding frame, with length=" << length);

  if (length < IMA_BYTES_PER_FRAME)
    return FALSE;

  // decode the first frame
  adpcm_decoder((char *)buffer, sampleBuffer.GetPointer(), IMA_BYTES_PER_FRAME);

  return TRUE;
}

