/*
 * g726codec.h
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
 *
 */

#ifndef __OPAL_G726CODEC_H
#define __OPAL_G726CODEC_H

#ifdef P_USE_PRAGMA
#pragma interface
#endif


#include "h323caps.h"


struct g726_state_s;


#define OPAL_G726_40 "G.726-40k"
#define OPAL_G726_32 "G.726-32k"
#define OPAL_G726_24 "G.726-24k"
#define OPAL_G726_16 "G.726-16k"

extern OpalMediaFormat const OpalG726_40;
extern OpalMediaFormat const OpalG726_32;
extern OpalMediaFormat const OpalG726_24;
extern OpalMediaFormat const OpalG726_16;


///////////////////////////////////////////////////////////////////////////////

/**This class describes the G726 codec capability.
 */
class H323_G726_Capability : public H323NonStandardAudioCapability
{
  PCLASSINFO(H323_G726_Capability, H323NonStandardAudioCapability)
	

  public:
    enum Speeds {
      e_40k,
      e_32k,
      e_24k,
      e_16k,
      NumSpeeds
    };

  /**@name Construction */
  //@{
    /**Create a new G.726 capability.
     */
    H323_G726_Capability(
      H323EndPoint & endpoint,  /// Endpoint to get NonStandardInfo from.
      Speeds speed              /// Speed of encoding
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
    Speeds speed;
};


#ifdef H323_STATIC_LIB
H323_STATIC_LOAD_REGISTER_CAPABILITY(H323_G726_40_Capability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(H323_G726_32_Capability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(H323_G726_24_Capability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(H323_G726_16_Capability);
#endif



///////////////////////////////////////////////////////////////////////////////

/**This class is a G726 ADPCM codec.
 */

class H323_G726_Codec : public H323StreamedAudioCodec
{
  PCLASSINFO(H323_G726_Codec, H323StreamedAudioCodec)

  public:
  /**@name Construction */
  //@{
    /**Create a new G.726 codec
     */
    H323_G726_Codec(
      H323_G726_Capability::Speeds speed, /// Speed of codec
      Direction direction,  /// Direction in which this instance runs
      unsigned frameSize    /// Size of frame in bytes
    );

    /**Destroy the codec.
      */
    ~H323_G726_Codec();
  //@}

    virtual int   Encode(short sample) const;
    virtual short Decode(int   sample) const;
  
  protected:
    g726_state_s * g726;
    H323_G726_Capability::Speeds speed;
};


#endif // __OPAL_G726CODEC_H


/////////////////////////////////////////////////////////////////////////////
