/*
 * ilbc.h
 *
 * Internet Low Bitrate Codec
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
 * $Log: ilbccodec.h,v $
 * Revision 1.1  2003/06/06 02:19:04  rjongbloed
 * Added iLBC codec
 *
 */

#ifndef __OPAL_ILBC_H
#define __OPAL_ILBC_H

#ifdef P_USE_PRAGMA
#pragma interface
#endif


#include "h323caps.h"


struct iLBC_Enc_Inst_t_;
struct iLBC_Dec_Inst_t_;


#define OPAL_ILBC_13k3 "iLBC-13k3"
#define OPAL_ILBC_15k2 "iLBC-15k2"

extern OpalMediaFormat const OpaliLBC_13k3;
extern OpalMediaFormat const OpaliLBC_15k2;


#ifdef H323_STATIC_LIB
H323_STATIC_LOAD_REGISTER_CAPABILITY(H323_iLBC_Capability_13k3);
H323_STATIC_LOAD_REGISTER_CAPABILITY(H323_iLBC_Capability_15k2);
#endif


///////////////////////////////////////////////////////////////////////////////

/**This class describes the ILBC codec capability.
 */
class H323_iLBC_Capability : public H323NonStandardAudioCapability
{
  PCLASSINFO(H323_iLBC_Capability, H323NonStandardAudioCapability)

  public:
  /**@name Construction */
  //@{
    enum Speed {
      e_13k3,
      e_15k2
    };

    /**Create a new ILBC capability.
     */
    H323_iLBC_Capability(
      H323EndPoint & endpoint,
      Speed speed
    );
  //@}

  /**@name Overrides from class PObject */
  //@{
    /**Create a copy of the object.
      */
    virtual PObject * Clone() const;
  //@}

  /**@name Identification functions */
  //@{
    /**Get the name of the media data format this class represents.
     */
    virtual PString GetFormatName() const;
  //@}

  /**@name Operations */
  //@{
    /**Create the codec instance, allocating resources as required.
     */
    virtual H323Codec * CreateCodec(
      H323Codec::Direction direction  /// Direction in which this instance runs
    ) const;
  //@}

  private:
    Speed speed;
};


/**This class is a iLBC codec.
 */
class H323_iLBC_Codec : public H323FramedAudioCodec
{
  PCLASSINFO(H323_iLBC_Codec,  H323FramedAudioCodec)

  public:
  /**@name Construction */
  //@{
    /**Create a new iLBC codec.
     */
    H323_iLBC_Codec(
      Direction direction,        /// Direction in which this instance runs
      H323_iLBC_Capability::Speed speed
    );
    ~H323_iLBC_Codec();
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
    struct iLBC_Enc_Inst_t_ * encoder; 
    struct iLBC_Dec_Inst_t_ * decoder;
};


#endif // __OPAL_ILBC_H


/////////////////////////////////////////////////////////////////////////////
