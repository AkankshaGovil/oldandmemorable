/*
 * g729codec.h
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
 * $Log: g729codec.h,v $
 * Revision 1.7  2003/05/05 11:59:21  robertj
 * Changed to use autoconf style selection of options and subsystems.
 *
 * Revision 1.6  2002/11/12 00:06:10  robertj
 * Added check for Voice Age G.729 only being able to do a single instance
 *   of the encoder and decoder. Now fails the second isntance isntead of
 *   interfering with the first one.
 *
 * Revision 1.5  2002/09/16 01:14:15  robertj
 * Added #define so can select if #pragma interface/implementation is used on
 *   platform basis (eg MacOS) rather than compiler, thanks Robert Monaghan.
 *
 * Revision 1.4  2002/09/03 06:19:36  robertj
 * Normalised the multi-include header prevention ifdef/define symbol.
 *
 * Revision 1.3  2002/08/05 10:03:47  robertj
 * Cosmetic changes to normalise the usage of pragma interface/implementation.
 *
 * Revision 1.2  2002/06/27 03:08:31  robertj
 * Added G.729 capabilitity support even though is really G.729A.
 * Added code to include G.729 codecs on static linking.
 *
 * Revision 1.1  2001/09/21 02:54:47  robertj
 * Added new codec framework with no actual implementation.
 *
 */

#ifndef __OPAL_G729CODEC_H
#define __OPAL_G729CODEC_H

#ifdef P_USE_PRAGMA
#pragma interface
#endif

#include <openh323buildopts.h>

#if VOICE_AGE_G729A

#include "h323caps.h"


#ifdef H323_STATIC_LIB
H323_STATIC_LOAD_REGISTER_CAPABILITY(H323_G729Capability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(H323_G729ACapability);
#endif


/**This class describes the (fake) G729 codec capability.
 */
class H323_G729Capability : public H323AudioCapability
{
  PCLASSINFO(H323_G729Capability, H323AudioCapability);

  public:
  /**@name Construction */
  //@{
    /**Create a new G.729 capability.
     */
    H323_G729Capability();
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
    /**Get the sub-type of the capability. This is a code dependent on the
       main type of the capability.

       This returns one of the four possible combinations of mode and speed
       using the enum values of the protocol ASN H245_AudioCapability class.
     */
    virtual unsigned GetSubType() const;

    /**Get the name of the media data format this class represents.
     */
    virtual PString GetFormatName() const;
  //@}
};


/**This class describes the VoiceAge G729A codec capability.
 */
class H323_G729ACapability : public H323AudioCapability
{
  PCLASSINFO(H323_G729ACapability, H323AudioCapability);

  public:
  /**@name Construction */
  //@{
    /**Create a new G.729A capability.
     */
    H323_G729ACapability();
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
    /**Get the sub-type of the capability. This is a code dependent on the
       main type of the capability.

       This returns one of the four possible combinations of mode and speed
       using the enum values of the protocol ASN H245_AudioCapability class.
     */
    virtual unsigned GetSubType() const;

    /**Get the name of the media data format this class represents.
     */
    virtual PString GetFormatName() const;
  //@}
};


/**This class is a G.729A codec.
 */
class H323_G729ACodec : public H323FramedAudioCodec
{
  PCLASSINFO(H323_G729ACodec, H323FramedAudioCodec)

  public:
  /**@name Construction */
  //@{
    /**Create a new Open LPC codec.
     */
    H323_G729ACodec(
      Direction direction         /// Direction in which this instance runs
    );
    ~H323_G729ACodec();
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
};


#endif // VOICE_AGE_G729A

#endif // __OPAL_G729CODEC_H


/////////////////////////////////////////////////////////////////////////////
