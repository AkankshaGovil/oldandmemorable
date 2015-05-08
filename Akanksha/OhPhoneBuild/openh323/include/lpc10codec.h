/*
 * lpc10codec.h
 *
 * H.323 protocol handler
 *
 * Open H323 Library
 *
 * Copyright (c) 1999-2000 Equivalence Pty. Ltd.
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
 * $Log: lpc10codec.h,v $
 * Revision 1.9  2002/09/16 01:14:15  robertj
 * Added #define so can select if #pragma interface/implementation is used on
 *   platform basis (eg MacOS) rather than compiler, thanks Robert Monaghan.
 *
 * Revision 1.8  2002/09/03 05:41:25  robertj
 * Normalised the multi-include header prevention ifdef/define symbol.
 * Added globally accessible functions for media format name.
 *
 * Revision 1.7  2002/08/14 19:35:08  rogerh
 * fix typo
 *
 * Revision 1.6  2002/08/05 10:03:47  robertj
 * Cosmetic changes to normalise the usage of pragma interface/implementation.
 *
 * Revision 1.5  2001/10/24 01:20:34  robertj
 * Added code to help with static linking of H323Capability names database.
 *
 * Revision 1.4  2001/02/09 05:16:24  robertj
 * Added #pragma interface for GNU C++.
 *
 * Revision 1.3  2001/01/25 07:27:14  robertj
 * Major changes to add more flexible OpalMediaFormat class to normalise
 *   all information about media types, especially codecs.
 *
 * Revision 1.2  2000/06/10 09:04:56  rogerh
 * fix typo in a comment
 *
 * Revision 1.1  2000/06/05 04:45:02  robertj
 * Added LPC-10 2400bps codec
 *
 */

#ifndef __OPAL_LPC10CODEC_H
#define __OPAL_LPC10CODEC_H

#ifdef P_USE_PRAGMA
#pragma interface
#endif


#include "h323caps.h"


struct lpc10_encoder_state;
struct lpc10_decoder_state;

#define OPAL_LPC10 "LPC-10"

extern OpalMediaFormat const OpalLPC10;


#ifdef H323_STATIC_LIB
H323_STATIC_LOAD_REGISTER_CAPABILITY(H323_LPC10Capability);
#endif


///////////////////////////////////////////////////////////////////////////////

/**This class describes the LPC-10 (FS-1015) codec capability.
 */
class H323_LPC10Capability : public H323NonStandardAudioCapability
{
  PCLASSINFO(H323_LPC10Capability, H323NonStandardAudioCapability);

  public:
  /**@name Construction */
  //@{
    /**Create a new LPC-10 capability.
     */
    H323_LPC10Capability(
      H323EndPoint & endpoint   // Endpoint to get NonStandardInfo from.
    );
  //@}

  /**@name Overrides from class PObject */
  //@{
    /**Create a copy of the object.
      */
    virtual PObject * Clone() const;
  //@}

  /**@name Operations */
  //@{
    /**Create the codec instance, allocating resources as required.
     */
    virtual H323Codec * CreateCodec(
      H323Codec::Direction direction  /// Direction in which this instance runs
    ) const;
  //@}

  /**@name Identification functions */
  //@{
    /**Get the name of the media data format this class represents.
     */
    virtual PString GetFormatName() const;
  //@}
};


/**This class is a LPC-10 codec.
 */
class H323_LPC10Codec : public H323FramedAudioCodec
{
  PCLASSINFO(H323_LPC10Codec, H323FramedAudioCodec)

  public:
  /**@name Construction */
  //@{
    /**Create a new LPC-10 codec.
     */
    H323_LPC10Codec(
      Direction direction         /// Direction in which this instance runs
    );
    ~H323_LPC10Codec();
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
    struct lpc10_encoder_state * encoder;
    struct lpc10_decoder_state * decoder;
};


#endif // __OPAL_LPC10CODEC_H


/////////////////////////////////////////////////////////////////////////////

