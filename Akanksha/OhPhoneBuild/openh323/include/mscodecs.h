/*
 * mscodecs.h
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
 * $Log: mscodecs.h,v $
 * Revision 1.11  2002/09/30 09:32:50  craigs
 * Removed ability to set no. of frames per packet for MS-GSM - there can be only one!
 *
 * Revision 1.10  2002/09/16 01:14:15  robertj
 * Added #define so can select if #pragma interface/implementation is used on
 *   platform basis (eg MacOS) rather than compiler, thanks Robert Monaghan.
 *
 * Revision 1.9  2002/09/03 05:41:56  robertj
 * Normalised the multi-include header prevention ifdef/define symbol.
 * Added globally accessible functions for media format names.
 *
 * Revision 1.8  2002/08/05 10:03:47  robertj
 * Cosmetic changes to normalise the usage of pragma interface/implementation.
 *
 * Revision 1.7  2001/10/24 01:20:34  robertj
 * Added code to help with static linking of H323Capability names database.
 *
 * Revision 1.6  2001/03/08 01:42:20  robertj
 * Cosmetic changes to recently added MS IMA ADPCM codec.
 *
 * Revision 1.5  2001/03/08 00:57:46  craigs
 * Added MS-IMA codec thanks to Liu Hao. Not yet working - do not use
 *
 * Revision 1.4  2001/02/09 05:16:24  robertj
 * Added #pragma interface for GNU C++.
 *
 * Revision 1.3  2001/01/25 07:27:14  robertj
 * Major changes to add more flexible OpalMediaFormat class to normalise
 *   all information about media types, especially codecs.
 *
 * Revision 1.2  2001/01/09 23:05:22  robertj
 * Fixed inability to have 2 non standard codecs in capability table.
 *
 * Revision 1.1  2000/08/23 14:23:11  craigs
 * Added prototype support for Microsoft GSM codec
 *
 *
 */

#ifndef __OPAL_MSCODECS_H
#define __OPAL_MSCODECS_H

#ifdef P_USE_PRAGMA
#pragma interface
#endif


#include "h323caps.h"



#define OPAL_MSGSM "MS-GSM"

extern OpalMediaFormat const OpalMSGSM;

#define OPAL_MSIMA "MS-IMA-ADPCM"

extern OpalMediaFormat const OpalMSIMA;


#ifdef H323_STATIC_LIB
H323_STATIC_LOAD_REGISTER_CAPABILITY(MicrosoftGSMAudioCapability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(MicrosoftIMAAudioCapability);
#endif


///////////////////////////////////////////////////////////////////////////////

class MicrosoftNonStandardAudioCapability : public H323NonStandardAudioCapability
{
  PCLASSINFO(MicrosoftNonStandardAudioCapability, H323NonStandardAudioCapability);

  public:
    MicrosoftNonStandardAudioCapability(
      const BYTE * header,
      PINDEX headerSize,
      PINDEX offset,
      PINDEX len
    );
};


/////////////////////////////////////////////////////////////////////////

class MicrosoftGSMAudioCapability : public MicrosoftNonStandardAudioCapability
{
  PCLASSINFO(MicrosoftGSMAudioCapability, MicrosoftNonStandardAudioCapability);

  public:
    MicrosoftGSMAudioCapability();
    PObject * MicrosoftGSMAudioCapability::Clone() const;
    PString MicrosoftGSMAudioCapability::GetFormatName() const;
    H323Codec * MicrosoftGSMAudioCapability::CreateCodec(H323Codec::Direction direction) const;
    void SetTxFramesInPacket(unsigned /*frames*/);
};


/////////////////////////////////////////////////////////////////////////

class MicrosoftGSMCodec : public H323FramedAudioCodec
{
  PCLASSINFO(MicrosoftGSMCodec, H323FramedAudioCodec);
  public:

  /**@name Construction */
  //@{
    /**Create a new GSM 06.10 codec for ALaw.
     */
    MicrosoftGSMCodec(
      Direction direction /// Direction in which this instance runs
    );

    ~MicrosoftGSMCodec();
  //@}

    /**Encode a sample block into the buffer specified.
       The samples have been read and are waiting in the readBuffer member
       variable. it is expected this function will encode exactly
       encodedBlockSize bytes.
     */
    virtual BOOL EncodeFrame(
      BYTE * buffer,    /// Buffer into which encoded bytes are placed
      unsigned & length /// Actual length of encoded data buffer
    );

    /**Decode a sample block from the buffer specified.
       The samples must be placed into the writeBuffer member variable. It is
       expected that no more than frameSamples is decoded. The return value
       is the number of samples decoded. Zero indicates an error.
     */
    virtual BOOL DecodeFrame(
      const BYTE * buffer,  /// Buffer from which encoded data is found
      unsigned length,      /// Length of encoded data buffer
      unsigned & written    /// Number of bytes used from data buffer
    );

  protected:
    struct gsm_state * gsm;
};


/////////////////////////////////////////////////////////////////////////

class MicrosoftIMAAudioCapability : public MicrosoftNonStandardAudioCapability
{
  PCLASSINFO(MicrosoftIMAAudioCapability, MicrosoftNonStandardAudioCapability);

  public:
    MicrosoftIMAAudioCapability();
    PObject * MicrosoftIMAAudioCapability::Clone() const;
    PString MicrosoftIMAAudioCapability::GetFormatName() const;
    H323Codec * MicrosoftIMAAudioCapability::CreateCodec(H323Codec::Direction direction) const;
};

/////////////////////////////////////////////////////////////////////////

struct adpcm_state {
  short valprev;        /* Previous output value */
  char  index;          /* Index into stepsize table */
};


class MicrosoftIMACodec : public H323FramedAudioCodec
{
  PCLASSINFO(MicrosoftIMACodec, H323FramedAudioCodec);
  public:

  /**@name Construction */
  //@{
    /**Create a new IMA codec for ALaw.
     */
    MicrosoftIMACodec(
      Direction direction /// Direction in which this instance runs
    );

    ~MicrosoftIMACodec();
  //@}

    /**Encode a sample block into the buffer specified.
       The samples have been read and are waiting in the readBuffer member
       variable. it is expected this function will encode exactly
       encodedBlockSize bytes.
     */
    virtual BOOL EncodeFrame(
      BYTE * buffer,    /// Buffer into which encoded bytes are placed
      unsigned & length /// Actual length of encoded data buffer
    );

    /**Decode a sample block from the buffer specified.
       The samples must be placed into the writeBuffer member variable. It is
       expected that no more than frameSamples is decoded. The return value
       is the number of samples decoded. Zero indicates an error.
     */
    virtual BOOL DecodeFrame(
      const BYTE * buffer,  /// Buffer from which encoded data is found
      unsigned length,      /// Length of encoded data buffer
      unsigned & written    /// Number of bytes used from data buffer
    );

    struct adpcm_state s_adpcm;
};


#endif // __OPAL_MSCODECS_H


/////////////////////////////////////////////////////////////////////////
