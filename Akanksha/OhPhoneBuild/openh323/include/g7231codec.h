/*
 * g7231codec.h
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
 * $Log: g7231codec.h,v $
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
 * Revision 1.2  2002/06/25 08:30:08  robertj
 * Changes to differentiate between stright G.723.1 and G.723.1 Annex A using
 *   the OLC dataType silenceSuppression field so does not send SID frames
 *   to receiver codecs that do not understand them.
 *
 * Revision 1.1  2001/09/21 02:54:47  robertj
 * Added new codec framework with no actual implementation.
 *
 */

#ifndef __OPAL_G7231CODEC_H
#define __OPAL_G7231CODEC_H

#ifdef P_USE_PRAGMA
#pragma interface
#endif


#include "h323caps.h"


/**This class describes the G.723.1 codec capability.
 */
class H323_G7231Capability : public H323AudioCapability
{
    PCLASSINFO(H323_G7231Capability, H323AudioCapability);
  public:
  /**@name Construction */
  //@{
    /**Create a new G.723.1 capability.
     */
    H323_G7231Capability(
      BOOL annexA = TRUE  /// Enable Annex A silence insertion descriptors
    );
  //@}

  /**@name Overrides from class PObject */
  //@{
    /**Compare the object with another of the same class.
      */
    Comparison Compare(const PObject & obj) const;

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

  /**@name Protocol manipulation */
  //@{
    /**This function is called whenever and outgoing TerminalCapabilitySet
       or OpenLogicalChannel PDU is being constructed for the control channel.
       It allows the capability to set the PDU fields from information in
       members specific to the class.

       The default behaviour sets the data rate field in the PDU.
     */
    virtual BOOL OnSendingPDU(
      H245_AudioCapability & pdu,  /// PDU to set information on
      unsigned packetSize          /// Packet size to use in capability
    ) const;

    /**This function is called whenever and incoming TerminalCapabilitySet
       or OpenLogicalChannel PDU has been used to construct the control
       channel. It allows the capability to set from the PDU fields,
       information in members specific to the class.

       The default behaviour gets the data rate field from the PDU.
     */
    virtual BOOL OnReceivedPDU(
      const H245_AudioCapability & pdu,  /// PDU to get information from
      unsigned & packetSize              /// Packet size to use in capability
    );
  //@}

  protected:
    BOOL annexA;
};


#ifdef ITU_REFERENCE_G7231
struct dec_state;
struct cod_state;
#endif


/**This class is a G.723.1 codec.
 */
class H323_G7231Codec : public H323FramedAudioCodec
{
    PCLASSINFO(H323_G7231Codec, H323FramedAudioCodec);
  public:
    enum {
      SamplesPerFrame = 240,  // 30 milliseconds
      BytesPerFrame = 24      // Encoded size
    };

  /**@name Construction */
  //@{
    /**Create a new G.723.1 codec.
     */
    H323_G7231Codec(
      Direction direction, /// Direction in which this instance runs
      BOOL annexA          /// Use Annex A silence insertion descriptors
    );
    ~H323_G7231Codec();
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
#ifdef ITU_REFERENCE_G7231
    struct cod_state * encoderState;
    struct dec_state * decoderState;
#endif
};


#endif // __OPAL_G7231CODEC_H


/////////////////////////////////////////////////////////////////////////////
