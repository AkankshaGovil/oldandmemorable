/*
 * speexcodec.h
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
 * $Log: speexcodec.h,v $
 * Revision 1.15  2002/12/08 22:59:41  rogerh
 * Add XiphSpeex codec. Not yet finished.
 *
 * Revision 1.14  2002/12/06 10:11:54  rogerh
 * Back out the Xiph Speex changes on a tempoary basis while the Speex
 * spec is being redrafted.
 *
 * Revision 1.13  2002/12/05 12:57:17  rogerh
 * Speex now uses the manufacturer ID assigned to Xiph.Org.
 * To support existing applications using Speex, applications can use the
 * EquivalenceSpeex capabilities.
 *
 * Revision 1.12  2002/11/09 07:08:02  robertj
 * Hide speex library from OPenH323 library users.
 * Made public the media format names.
 * Other cosmetic changes.
 *
 * Revision 1.11  2002/10/24 05:32:57  robertj
 * MSVC compatibility
 *
 * Revision 1.10  2002/10/22 11:54:32  rogerh
 * Fix including of speex.h
 *
 * Revision 1.9  2002/10/22 11:33:04  rogerh
 * Use the local speex.h header file
 *
 * Revision 1.8  2002/09/16 01:14:15  robertj
 * Added #define so can select if #pragma interface/implementation is used on
 *   platform basis (eg MacOS) rather than compiler, thanks Robert Monaghan.
 *
 * Revision 1.7  2002/08/22 08:30:23  craigs
 * Fixed remainder of Clone operators
 *
 * Revision 1.6  2002/08/20 15:22:50  rogerh
 * Make the codec name include the bitstream format for Speex to prevent users
 * with incompatible copies of Speex trying to use this codec.
 *
 * Revision 1.5  2002/08/15 18:35:36  rogerh
 * Fix more bugs with the Speex codec
 *
 * Revision 1.4  2002/08/14 19:34:31  rogerh
 * fix typo
 *
 * Revision 1.3  2002/08/14 04:26:20  craigs
 * Fixed ifdef problem
 *
 * Revision 1.2  2002/08/13 14:25:25  craigs
 * Added trailing newlines to avoid Linux warnings
 *
 * Revision 1.1  2002/08/13 14:14:28  craigs
 * Initial version
 *
 */


#ifndef __OPAL_SPEEXCODEC_H
#define __OPAL_SPEEXCODEC_H

#ifdef P_USE_PRAGMA
#pragma interface
#endif

#include "h323caps.h"
#include "codecs.h"


#define OPAL_SPEEX_NARROW_5k95 "SpeexNarrow-5.95k"
#define OPAL_SPEEX_NARROW_8k   "SpeexNarrow-8k"
#define OPAL_SPEEX_NARROW_11k  "SpeexNarrow-11k"
#define OPAL_SPEEX_NARROW_15k  "SpeexNarrow-15k"
#define OPAL_SPEEX_NARROW_18k2 "SpeexNarrow-18.2k"

extern OpalMediaFormat const OpalSpeexNarrow_5k95;
extern OpalMediaFormat const OpalSpeexNarrow_8k;
extern OpalMediaFormat const OpalSpeexNarrow_11k;
extern OpalMediaFormat const OpalSpeexNarrow_15k;
extern OpalMediaFormat const OpalSpeexNarrow_18k2;


struct SpeexBits;


///////////////////////////////////////////////////////////////////////////////

/**This class describes the Speex codec capability.
 */
class SpeexNonStandardAudioCapability : public H323NonStandardAudioCapability
{
  PCLASSINFO(SpeexNonStandardAudioCapability, H323NonStandardAudioCapability);

  public:
    SpeexNonStandardAudioCapability(int mode);
};

/////////////////////////////////////////////////////////////////////////

class SpeexNarrow2AudioCapability : public SpeexNonStandardAudioCapability
{
  PCLASSINFO(SpeexNarrow2AudioCapability, SpeexNonStandardAudioCapability);

  public:
    SpeexNarrow2AudioCapability();
    PObject * Clone() const;
    PString GetFormatName() const;
    H323Codec * CreateCodec(H323Codec::Direction direction) const;
};

class SpeexNarrow3AudioCapability : public SpeexNonStandardAudioCapability
{
  PCLASSINFO(SpeexNarrow3AudioCapability, SpeexNonStandardAudioCapability);

  public:
    SpeexNarrow3AudioCapability();
    PObject * Clone() const;
    PString GetFormatName() const;
    H323Codec * CreateCodec(H323Codec::Direction direction) const;
};

class SpeexNarrow4AudioCapability : public SpeexNonStandardAudioCapability
{
  PCLASSINFO(SpeexNarrow4AudioCapability, SpeexNonStandardAudioCapability);

  public:
    SpeexNarrow4AudioCapability();
    PObject * Clone() const;
    PString GetFormatName() const;
    H323Codec * CreateCodec(H323Codec::Direction direction) const;
};

class SpeexNarrow5AudioCapability : public SpeexNonStandardAudioCapability
{
  PCLASSINFO(SpeexNarrow5AudioCapability, SpeexNonStandardAudioCapability);

  public:
    SpeexNarrow5AudioCapability();
    PObject * Clone() const;
    PString GetFormatName() const;
    H323Codec * CreateCodec(H323Codec::Direction direction) const;
};

class SpeexNarrow6AudioCapability : public SpeexNonStandardAudioCapability
{
  PCLASSINFO(SpeexNarrow6AudioCapability, SpeexNonStandardAudioCapability);

  public:
    SpeexNarrow6AudioCapability();
    PObject * Clone() const;
    PString GetFormatName() const;
    H323Codec * CreateCodec(H323Codec::Direction direction) const;
};


#ifdef H323_STATIC_LIB
H323_STATIC_LOAD_REGISTER_CAPABILITY(SpeexNarrow2AudioCapability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(SpeexNarrow3AudioCapability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(SpeexNarrow4AudioCapability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(SpeexNarrow5AudioCapability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(SpeexNarrow6AudioCapability);
#endif


///////////////////////////////////////////////////////////////////////////////

/**This class describes the Xiph Speex codec capability.
 */
class XiphSpeexNonStandardAudioCapability : public H323NonStandardAudioCapability
{
  PCLASSINFO(XiphSpeexNonStandardAudioCapability, H323NonStandardAudioCapability);

  public:
    XiphSpeexNonStandardAudioCapability(int mode);
};

/////////////////////////////////////////////////////////////////////////

class XiphSpeexNarrow2AudioCapability : public XiphSpeexNonStandardAudioCapability
{
  PCLASSINFO(XiphSpeexNarrow2AudioCapability, XiphSpeexNonStandardAudioCapability);

  public:
    XiphSpeexNarrow2AudioCapability();
    PObject * Clone() const;
    PString GetFormatName() const;
    H323Codec * CreateCodec(H323Codec::Direction direction) const;
};

class XiphSpeexNarrow3AudioCapability : public XiphSpeexNonStandardAudioCapability
{
  PCLASSINFO(XiphSpeexNarrow3AudioCapability, XiphSpeexNonStandardAudioCapability);

  public:
    XiphSpeexNarrow3AudioCapability();
    PObject * Clone() const;
    PString GetFormatName() const;
    H323Codec * CreateCodec(H323Codec::Direction direction) const;
};

class XiphSpeexNarrow4AudioCapability : public XiphSpeexNonStandardAudioCapability
{
  PCLASSINFO(XiphSpeexNarrow4AudioCapability, XiphSpeexNonStandardAudioCapability);

  public:
    XiphSpeexNarrow4AudioCapability();
    PObject * Clone() const;
    PString GetFormatName() const;
    H323Codec * CreateCodec(H323Codec::Direction direction) const;
};

class XiphSpeexNarrow5AudioCapability : public XiphSpeexNonStandardAudioCapability
{
  PCLASSINFO(XiphSpeexNarrow5AudioCapability, XiphSpeexNonStandardAudioCapability);

  public:
    XiphSpeexNarrow5AudioCapability();
    PObject * Clone() const;
    PString GetFormatName() const;
    H323Codec * CreateCodec(H323Codec::Direction direction) const;
};

class XiphSpeexNarrow6AudioCapability : public XiphSpeexNonStandardAudioCapability
{
  PCLASSINFO(XiphSpeexNarrow6AudioCapability, XiphSpeexNonStandardAudioCapability);

  public:
    XiphSpeexNarrow6AudioCapability();
    PObject * Clone() const;
    PString GetFormatName() const;
    H323Codec * CreateCodec(H323Codec::Direction direction) const;
};


#ifdef H323_STATIC_LIB
H323_STATIC_LOAD_REGISTER_CAPABILITY(XiphSpeexNarrow2AudioCapability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(XiphSpeexNarrow3AudioCapability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(XiphSpeexNarrow4AudioCapability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(XiphSpeexNarrow5AudioCapability);
H323_STATIC_LOAD_REGISTER_CAPABILITY(XiphSpeexNarrow6AudioCapability);
#endif


/////////////////////////////////////////////////////////////////////////

class SpeexCodec : public H323FramedAudioCodec
{
  PCLASSINFO(SpeexCodec, H323FramedAudioCodec);
  public:

  /**@name Construction */
  //@{
    /**Create a new Speex codec.
     */
    SpeexCodec(
      const char * name,   /// Speex codec name
      int mode,            /// Quality parameter passed to compressor
      Direction direction  /// Direction in which this instance runs
    );

    ~SpeexCodec();
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
    SpeexBits * bits;
    void      * coder_state;
    unsigned    encoder_frame_size;
};


#endif // __OPAL_SPEEXCODEC_H


/////////////////////////////////////////////////////////////////////////
