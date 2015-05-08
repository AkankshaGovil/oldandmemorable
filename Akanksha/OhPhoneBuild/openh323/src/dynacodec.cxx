/*
 * dynacodec.cxx
 *
 * Dynamic codec loading
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
 * Contributor(s): ______________________________________.
 *
 * $Log: dynacodec.cxx,v $
 * Revision 1.5  2003/04/30 14:15:25  craigs
 * Changed for new codec API
 *
 * Revision 1.4  2003/04/30 06:55:05  craigs
 * Changed interface to DLL codec to improve Opal compatibility
 *
 * Revision 1.3  2003/04/30 04:56:42  craigs
 * Changed interface to DLL codec to improve Opal compatibility
 *
 * Revision 1.2  2003/04/28 07:00:09  robertj
 * Fixed problem with compiler(s) not correctly initialising static globals
 *
 * Revision 1.1  2003/04/27 23:49:48  craigs
 * Initial version
 *
 */

#include <ptlib.h>

#include <dynacodec.h>
#include <rtp.h>
#include "h245.h"

#ifdef  _WIN32
static const char * dllExt = ".dll";
#else
static const char * dllExt = ".so";
#endif

static const char H323EXT[] = "{sw}";

#define CURRENT_API_VERSION   1           // library current supports this API version

#define EQUIVALENCE_COUNTRY_CODE       9  // Country code for Australia
#define EQUIVALENCE_T35EXTENSION       0
#define EQUIVALENCE_MANUFACTURER_CODE  61 // Allocated by Australian Communications Authority, Oct 2000

#define GSM_BYTES_PER_FRAME 33

// following attributes must exist on all codecs
static const char ATTRIBUTE_APIVERSION[]                 = "apiversion";
static const char ATTRIBUTE_TYPE[]                       = "type";     // audio or video

// following attributes are optional on all codecs
static const char ATTRIBUTE_NAME[]              = "name";              // name fo the code
static const char ATTRIBUTE_VERSION[]           = "version";           // codec version
static const char ATTRIBUTE_DATE[]              = "date";              // date of DLL creation

static const char ATTRIBUTE_CODECVENDOR[]       = "codecvendor";       // vendor of the codec
static const char ATTRIBUTE_CODECVERSION[]      = "codecversion";      // vendor version information
static const char ATTRIBUTE_CODECCOPYRIGHT[]    = "codeccopyright";    // copyright notice
static const char ATTRIBUTE_CODECDATE[]         = "codecdate";         // date associated with codec
static const char ATTRIBUTE_CODECLICENSE[]      = "codeclicense";      // vendor codec licence information 
static const char ATTRIBUTE_CODECSOURCE[]       = "codecsource";       // vendor source code location
static const char ATTRIBUTE_CODECCONTACT[]      = "codeccontact";      // vendor contact email address 

static const char ATTRIBUTE_INTEGRATORNAME[]    = "integratorname";    // name of codec integrator
static const char ATTRIBUTE_INTEGRATORCONTACT[] = "integratorcontact"; // integrator contact email address

// following attribute names must exist on all non-PCM16 codecs 
// and be prefixed by "input" or "output" as appropriate
static const char ATTRIBUTE_IOFORMAT[]                = "format";
static const char ATTRIBUTE_IOBITPERSECOND[]          = "bitspersecond";
static const char ATTRIBUTE_IOBITSPERFRAME[]          = "bitsperframe";   
static const char ATTRIBUTE_IOBYTESPERFRAME[]         = "bytesperframe";
static const char ATTRIBUTE_IOSAMPLERATE[]            = "samplerate";      
static const char ATTRIBUTE_IOSAMPLESPERFRAME[]       = "samplesperframe";
static const char ATTRIBUTE_IORTP[]                   = "rtp";              
static const char ATTRIBUTE_IOSDP[]                   = "sdp";       

// following attribute names are optional on all non-PCM16 codecs 
// and mst be prefixed by "input" or "output" as appropriate
static const char ATTRIBUTE_SDPFMTP[]                    = "sdpfmtp";       

// the following attribute are optional for any codec
static const char ATTRIBUTE_H323NOSTANDARDHEADER[]       = "h323nonstandardheader";
static const char ATTRIBUTE_H323NOSTANDARDHEADERHEX[]    = "h323nonstandardheaderhex";
static const char ATTRIBUTE_H323CODECSUBTYPE[]           = "h323codecsubtype";
static const char ATTRIBUTE_T35COUNTRYCODE[]             = "t35countrycode";
static const char ATTRIBUTE_T35EXTENSION[]               = "t35extension";
static const char ATTRIBUTE_T35MANUFACTURER[]            = "t35manufacturer";
static const char ATTRIBUTE_MAXFRAMESPERPACKET[]         = "maxframesperpacket";
static const char ATTRIBUTE_PREFERREDTXFRAMESPERPACKET[] = "preferredtxframesperpacket";
static const char ATTRIBUTE_MEDIAFORMATNAME[]            = "mediaformatname";

// input and output format strings
static const char ATTRIBUTE_INPUTFORMAT[]                = "inputformat";
static const char ATTRIBUTE_OUTPUTFORMAT[]               = "outputformat";

// common values used as attribute values
static const char VALUE_PCM16[]  = "l16";
static const char VALUE_AUDIO[]  = "audio";
static const char VALUE_VIDEO[]  = "video";
static const char VALUE_INPUT[]  = "input";
static const char VALUE_OUTPUT[] = "output";

static const char *RequiredAttributes[] = {
  ATTRIBUTE_APIVERSION,
  ATTRIBUTE_INPUTFORMAT,
  ATTRIBUTE_OUTPUTFORMAT,
  NULL
};

static const char *RequiredNonPCM16Attributes[] = {
  ATTRIBUTE_IOFORMAT,
  ATTRIBUTE_IOBITPERSECOND,
  ATTRIBUTE_IOBITSPERFRAME,
  ATTRIBUTE_IOBYTESPERFRAME,
  ATTRIBUTE_IOSAMPLERATE,
  ATTRIBUTE_IOSAMPLESPERFRAME,
  ATTRIBUTE_IORTP,
  ATTRIBUTE_IOSDP,
  NULL
};

class TempCodecInfo : public PObject
{
  PCLASSINFO(TempCodecInfo, PObject);
  public:
    TempCodecInfo(const PStringToString & _attributes, OpalDLLCodecInfo & _codecInfo)
      : attributes(_attributes), codecInfo(_codecInfo)
      { }

    PStringToString attributes;
    OpalDLLCodecInfo & codecInfo;
};

PDICTIONARY(TempCodecInfoDict, PCaselessString, TempCodecInfo);

/////////////////////////////////////////////////////////////////////////////

PMutex OpalDynaCodecDLL::mutex;
BOOL OpalDynaCodecDLL::inited = FALSE;
PDirectory OpalDynaCodecDLL::defaultCodecDir;

/////////////////////////////////////////////////////////////////////////////

OpalDLLCodecRec::OpalDLLCodecRec(OpalDynaCodecDLL & _encoder, 
                            const PStringToString & _attributes, 
                           const OpalDLLCodecInfo & _info,
                                  OpalMediaFormat * _mediaFormat)
 : encoder(_encoder), attributes(_attributes), info(_info), mediaFormat(_mediaFormat)
{
}

void * OpalDLLCodecRec::CreateContext() const
{
  void * context = NULL;
  if (info.createContext != NULL)
    context = (*info.createContext)(info.codecUserData);
  return context;
}

void OpalDLLCodecRec::DestroyContext(void * context) const
{
  if (info.destroyContext != NULL)
    (*info.destroyContext)(info.codecUserData, context);
  else if (context != NULL)
    free(context);
}

void OpalDLLCodecRec::SetParameter(const PString & attribute, const PString & value) const
{
  if (info.setParameter != NULL)
    (*info.setParameter)(info.codecUserData, (const char *)attribute, (const char *)value);
}

PString OpalDLLCodecRec::GetParameter(const PString & attribute, const char * defValue) const
{
  if (info.getParameter == NULL)
    return defValue;

  char value[100];
  if (!(*info.getParameter)(info.codecUserData, (const char *)attribute, value, sizeof(value)))
    return PString::Empty();

  return PString(value);
}

H323Capability * OpalDLLCodecRec::CreateCapability(H323EndPoint & ep) const
{
  // get T35 country code
  BYTE country;
  if (attributes.Contains(ATTRIBUTE_T35COUNTRYCODE))
    country = (BYTE)attributes(ATTRIBUTE_T35COUNTRYCODE).AsUnsigned();
  else
    country = EQUIVALENCE_COUNTRY_CODE;                   /// t35 information

  // get T35 extension code
  BYTE extension;
  if (attributes.Contains(ATTRIBUTE_T35EXTENSION))
    extension = (BYTE)attributes(ATTRIBUTE_T35EXTENSION).AsUnsigned();
  else
    extension = EQUIVALENCE_T35EXTENSION;                   /// t35 information

  // get T35 manufacturer code
  WORD manufacturer;
  if (attributes.Contains(ATTRIBUTE_T35MANUFACTURER))
    manufacturer = (WORD)attributes(ATTRIBUTE_T35MANUFACTURER).AsUnsigned();
  else
    manufacturer = EQUIVALENCE_MANUFACTURER_CODE;              /// t35 information

  // look for specific paramaters for non-standard headers definitions
  // if not, then use codec name 
  PBYTEArray nonStandardHeader;
  unsigned subType = 0;
  if (attributes.Contains(ATTRIBUTE_H323CODECSUBTYPE)) {
    subType = attributes(ATTRIBUTE_H323CODECSUBTYPE).AsUnsigned();
  }

  else if (attributes.Contains(ATTRIBUTE_H323NOSTANDARDHEADER)) {
    PString str = attributes(ATTRIBUTE_H323NOSTANDARDHEADER);
    memcpy(nonStandardHeader.GetPointer(str.GetLength()), (const char *)str, str.GetLength());
  }
  
  else if (attributes.Contains(ATTRIBUTE_H323NOSTANDARDHEADERHEX)) {
    PStringArray tokens = attributes(ATTRIBUTE_H323NOSTANDARDHEADERHEX).Trim().Tokenise(", ");
    PINDEX i;
    PINDEX len = 0;
    nonStandardHeader.SetSize(0);
    for (i = 0; i < tokens.GetSize(); i++) {
      PString hex = tokens[i].Trim();
      if (hex.Left(2) *= "0x")
        hex = hex.Mid(2);
      int val;
      if (sscanf((const char *)hex, "%2x", &val) == 1) {
       nonStandardHeader.SetSize(len+1);
       nonStandardHeader[len] = (BYTE)val;
       len++;
      }
    }
  }
  
  else {
    PString name = attributes(ATTRIBUTE_NAME);
    memcpy(nonStandardHeader.GetPointer(name.GetLength()), (const char *)name, name.GetLength());
  }

  PString type = attributes(ATTRIBUTE_TYPE);
  if (type *= "audio") {

    unsigned maxFramesPerPacket = 1;
    if (attributes.Contains(ATTRIBUTE_MAXFRAMESPERPACKET)) {
      unsigned v = attributes(ATTRIBUTE_MAXFRAMESPERPACKET).AsUnsigned();
      if (v > 0)
        maxFramesPerPacket = v;
    }
    unsigned txFramesPerPacket = maxFramesPerPacket;
    if (attributes.Contains(ATTRIBUTE_PREFERREDTXFRAMESPERPACKET)) {
      unsigned v = attributes(ATTRIBUTE_PREFERREDTXFRAMESPERPACKET).AsUnsigned();
      if (0 < v && v <= maxFramesPerPacket)
        txFramesPerPacket = v;
    }

    if (subType != 0)
      return new OpalDynaCodecStandardAudioCapability(*this,
                                                       ep, 
                                                       maxFramesPerPacket, 
                                                       txFramesPerPacket,
                                                       subType);
    else
      return new OpalDynaCodecNonStandardAudioCapability(*this,
                                                         ep, 
                                                         maxFramesPerPacket, 
                                                         txFramesPerPacket, 
                                                         country, 
                                                         extension, 
                                                         manufacturer, 
                                                         (const BYTE *)nonStandardHeader,
                                                         nonStandardHeader.GetSize());
  }

  return NULL;
}

/////////////////////////////////////////////////////////////////////////////

BOOL OpalDynaCodecDLL::LoadCodecs()
{
  return LoadCodecs(defaultCodecDir);
}

BOOL OpalDynaCodecDLL::LoadCodecs(const PDirectory & _dir)
{
  PWaitAndSignal m(mutex);

  PDirectory dir = _dir;

  if (!dir.Open()) {
    PTRACE(2, "OpalDynaCodecDLL\tCannot find dynamic codec directory " << dir);
    return FALSE;
  }

  do {
    PFilePathString name = dir.GetEntryName();
    if ((name.GetLength() > (PINDEX)strlen(dllExt)) && (name.Right(strlen(dllExt)) == dllExt)) {
      PFileInfo info;
      if (dir.GetInfo(info)) {
        PTRACE(2, "OpalDynaCodecDLL\tLoading " << dir + name);
        LoadCodec(dir + name);
      }
    }
  } while (dir.Next());

  return TRUE;
}

static BOOL CheckRequestNonPCM16Attributes(const PFilePath & fn, PINDEX i, const PStringToString & attributes, const PString & prefix)
{
  const char ** requiredAttributes = RequiredNonPCM16Attributes;
  BOOL passed = TRUE;
  while (*requiredAttributes != NULL) {
    if (!attributes.Contains(prefix + *requiredAttributes)) {
      PTRACE(2, "OpalDynaCodecDLL\tCodec " << i << " in " << fn << " missing required attribute " << prefix << *requiredAttributes);
      passed = FALSE;
    }
    requiredAttributes++;
  }
  return passed;
}

static SetPCM16Attributes(PStringToString & attributes, BOOL input)
{
  PString prefix, otherPrefix;
  if (input) {
    prefix      = VALUE_INPUT;
    otherPrefix = VALUE_OUTPUT;
  } else {
    otherPrefix = VALUE_INPUT;
    prefix      = VALUE_OUTPUT;
  }

  // sample rate is identical
  PString str = attributes(otherPrefix + ATTRIBUTE_IOSAMPLERATE);
  attributes.SetAt(prefix + ATTRIBUTE_IOSAMPLERATE, str);
  unsigned sampleRate = str.AsUnsigned();

  // bits per second is calculated from sample rate given 16 bits per sample
  attributes.SetAt(prefix + ATTRIBUTE_IOBITPERSECOND, PString(PString::Unsigned, sampleRate * 16));

  // samples per frame is identical
  str = attributes(otherPrefix + ATTRIBUTE_IOSAMPLESPERFRAME);
  attributes.SetAt(prefix + ATTRIBUTE_IOSAMPLESPERFRAME, str);
  unsigned samplesPerFrame = str.AsUnsigned();

  // bits per frame calculated from samples per frame given 16 bits per sample
  attributes.SetAt(prefix + ATTRIBUTE_IOBITSPERFRAME, PString(PString::Unsigned, samplesPerFrame * 16));

  // byte per frame calculated from samples per frame given 2 bytes per sample
  attributes.SetAt(prefix + ATTRIBUTE_IOBYTESPERFRAME, PString(PString::Unsigned, samplesPerFrame * 2));

  // set RTP and SDPs  type for pcm16
  attributes.SetAt(prefix + ATTRIBUTE_IORTP,  (int)RTP_DataFrame::L16_Mono);
  attributes.SetAt(prefix + ATTRIBUTE_IOSDP,  "L16");
}


BOOL OpalDynaCodecDLL::LoadCodec(const PFilePath & fn)
{
  PWaitAndSignal m(mutex);

  if (!inited) {
    inited = TRUE;
  }

  OpalDynaCodecDLL * codec = new OpalDynaCodecDLL(fn);
  if (!codec->IsLoaded()) {
    PTRACE(2, "OpalDynaCodecDLL\tCannot find file " << fn);
    delete codec;
    return FALSE;
  }

  if (!codec->Load()) {
    PTRACE(2, "OpalDynaCodecDLL\tFile " << fn << " does not contain an Opal codec library signature");
    delete codec;
    return FALSE;
  }

  if (!codec->IsLoaded()) {
    PTRACE(2, "OpalDynaCodecDLL\tFile " << fn << " does not implement Opal codec library API version " << CURRENT_API_VERSION);
    delete codec;
    return FALSE;
  }

  unsigned count;
  OpalDLLCodecInfo * codecInfo = codec->EnumerateCodecs(&count);
  if (codecInfo == NULL || count == 0) {
    PTRACE(2, "OpalDynaCodecDLL\tCodec " << fn << " contains no codecs");
    delete codec;
    return FALSE;
  }

  TempCodecInfoDict tempCodecDict;

  // scan through the list and create a temporay list of validated definitions
  // indexed by type and to and from formats
  PINDEX i;
  for (i = 0; i < (PINDEX)count; i++) {

    // get attributes;
    PStringToString attributes;
    const OpalDLLCodecKeyValue * keyValue = codecInfo[i].attributes;
    while (keyValue->key != NULL) {
      attributes.SetAt(keyValue->key, keyValue->value);
      keyValue++;
    }
    keyValue = codecInfo[i].attributes2;
    while (keyValue->key != NULL) {
      attributes.SetAt(PCaselessString(keyValue->key), keyValue->value);
      keyValue++;
    }

    // check for required attributes
    const char ** requiredAttributes = RequiredAttributes;
    BOOL passed = TRUE;
    while (*requiredAttributes != NULL) {
      if (!attributes.Contains(*requiredAttributes)) {
        PTRACE(2, "OpalDynaCodecDLL\tCodec " << i << " in " << fn << " missing required attribute " << *requiredAttributes);
        passed = FALSE;
      }
      requiredAttributes++;
    }

    // only accept video or audio codecs
    PCaselessString type = attributes(ATTRIBUTE_TYPE);
    if (!(type *= VALUE_VIDEO) && !(type *= VALUE_AUDIO)) {
      PTRACE(2, "OpalDynaCodecDLL\tCodec " << i << " in " << fn << " has unknown type " << type);
      passed = FALSE;
    }

    // check input attributes
    PCaselessString inputFormat  = attributes(ATTRIBUTE_INPUTFORMAT);
    if (inputFormat != VALUE_PCM16)
      passed = passed && CheckRequestNonPCM16Attributes(fn, i, attributes, VALUE_INPUT);
    else
      SetPCM16Attributes(attributes, TRUE);

    // check output attributes
    PCaselessString outputFormat = attributes(ATTRIBUTE_OUTPUTFORMAT);
    if (outputFormat != VALUE_PCM16)
      passed = passed && CheckRequestNonPCM16Attributes(fn, i, attributes, VALUE_OUTPUT);
    else
      SetPCM16Attributes(attributes, FALSE);

    // if codec is not legal, then ignore it
    if (!passed)
      continue;

    // save information about this codec
    PCaselessString key = type + "|" + inputFormat + "|" + outputFormat;
    TempCodecInfo * info = new TempCodecInfo(attributes, codecInfo[i]);
    tempCodecDict.SetAt(key, info);
  }

  // merge the new codecs into the list
  // note that OpenH323 can only deal with codecs that convert to or from PCM
  for (i = 0; i < tempCodecDict.GetSize(); i++) {

    PString encoderKey = tempCodecDict.GetKeyAt(i);

    // look for specific codec types:
    //     "formattype" == "audio" && "formatfrom" == "pcm"
    if (encoderKey.Find("audio|l16|") == 0) {

      PString encoderPrefix(VALUE_OUTPUT);

      TempCodecInfo & encoderCodecInfo = tempCodecDict.GetDataAt(i);

      // ignore this codec if this mediaformat is already defined
      // this ensures that loading the same codec will be idempotent
      PString mediaFormatName = encoderCodecInfo.attributes(ATTRIBUTE_MEDIAFORMATNAME);
      if (mediaFormatName.IsEmpty())
        mediaFormatName = encoderCodecInfo.attributes(ATTRIBUTE_OUTPUTFORMAT);

      if (OpalMediaFormat::GetRegisteredMediaFormats().GetValuesIndex(mediaFormatName) != P_MAX_INDEX) {
        PTRACE(2, "OpalDynaCodecDLL\tCodec " << i << " in " << fn << " defines already loaded codec " << mediaFormatName);
        continue;
      }

      PCaselessString type = encoderCodecInfo.attributes(ATTRIBUTE_TYPE);

      // see if there is an decoder that matches this encoder
      PString decoderKey = encoderCodecInfo.attributes(ATTRIBUTE_TYPE) + 
                           "|" + encoderCodecInfo.attributes(ATTRIBUTE_OUTPUTFORMAT) + 
                           "|" + VALUE_PCM16;
      if (!tempCodecDict.Contains(decoderKey)) {
        PTRACE(2, "OpalDynaCodecDLL\tCodec " << i << " contains an encoder but no decoder for " << mediaFormatName);
      } 
      
      else {
        TempCodecInfo & decoderCodecInfo = tempCodecDict[decoderKey];

        // get rtp payload type from encoder
        BYTE rtpPayloadType = 0;
        PString rtp = encoderCodecInfo.attributes(encoderPrefix + ATTRIBUTE_IORTP);
        if (rtp *= "dynamic")
          rtpPayloadType = (BYTE)RTP_DataFrame::DynamicBase;
        else
          rtpPayloadType = (BYTE)encoderCodecInfo.attributes(encoderPrefix + ATTRIBUTE_IORTP).AsUnsigned();

        // do codec-type specific attribute checking
        PCaselessString type = encoderCodecInfo.attributes(ATTRIBUTE_TYPE);
        OpalMediaFormat * mediaFormat = NULL;

        if (type *= "audio") {
          mediaFormat = new OpalMediaFormat(
                                            mediaFormatName,  
                                            OpalMediaFormat::DefaultAudioSessionID,
                                            (RTP_DataFrame::PayloadTypes)rtpPayloadType,
                                            TRUE,
                                            encoderCodecInfo.attributes(encoderPrefix + ATTRIBUTE_IOBITPERSECOND).AsUnsigned(),
                                            encoderCodecInfo.attributes(encoderPrefix + ATTRIBUTE_IOBYTESPERFRAME).AsUnsigned(),
                                            encoderCodecInfo.attributes(encoderPrefix + ATTRIBUTE_IOSAMPLESPERFRAME).AsUnsigned(),
                                            OpalMediaFormat::AudioTimeUnits);

        } else if (type *= "video") {
          mediaFormat = new OpalMediaFormat(
                                            mediaFormatName,  
                                            OpalMediaFormat::DefaultVideoSessionID,
                                            (RTP_DataFrame::PayloadTypes)rtpPayloadType,
                                            FALSE,
                                            encoderCodecInfo.attributes(encoderPrefix + ATTRIBUTE_IOBITPERSECOND).AsUnsigned(),
                                            0,
                                            0,
                                            OpalMediaFormat::VideoTimeUnits);
        } else {
          PAssertAlways(PString("unknown codec type ") + type);
        }

        // indicate how many times this codec has been used
        codec->referenceCount += 2;

        // register the codec
        new OpalDynaCodecRegistration(*mediaFormat + H323EXT, 
                                      new OpalDLLCodecRec(*codec, encoderCodecInfo.attributes, codecInfo[i], mediaFormat),
                                      new OpalDLLCodecRec(*codec, decoderCodecInfo.attributes, codecInfo[i], mediaFormat),
                                      mediaFormat);

        PTRACE(2, "OpalDynaCodecDLL\tLoaded " << type << " codec \"" << *mediaFormat << "\" from " << fn);
      }
    }
  }

  if (codec->referenceCount == 0) {
    PTRACE(2, "OpalDynaCodecDLL\tCodec " << fn << " contains no complete codecs");
    delete codec;
    return FALSE;
  }

  return TRUE;
}

PINDEX OpalDynaCodecDLL::AddAudioCapabilities(H323EndPoint & ep,
                                              PINDEX descriptorNum,
                                              PINDEX simultaneousNum,
                                              H323Capabilities & capabilities)
{
  return OpalDynaCodecDLL::AddCapabilities(ep, descriptorNum, simultaneousNum, capabilities, "audio");
}

PINDEX OpalDynaCodecDLL::AddVideoCapabilities(H323EndPoint & ep,
                                              PINDEX descriptorNum,
                                              PINDEX simultaneousNum,
                                              H323Capabilities & capabilities)
{
  return OpalDynaCodecDLL::AddCapabilities(ep, descriptorNum, simultaneousNum, capabilities, "video");
}


PINDEX OpalDynaCodecDLL::AddCapabilities(H323EndPoint & ep,
                                         PINDEX descriptorNum,
                                         PINDEX simultaneousNum,
                                         H323Capabilities & capabilities,
                                         const PString & type)
{
  PWaitAndSignal mutex(H323CapabilityRegistration::GetMutex());
  H323CapabilityRegistration * find = H323CapabilityRegistration::registeredCapabilitiesListHead;

  PINDEX added = 0;
  while (find != NULL) {
    if (find->IsDescendant(OpalDynaCodecRegistration::Class())) {
      OpalDynaCodecRegistration * dynaCodec = (OpalDynaCodecRegistration *)find;
      if (dynaCodec->encoderInfo->attributes(ATTRIBUTE_TYPE) *= type) {
        H323Capability * cap = find->Create(ep);
        if (cap != NULL) {
          capabilities.SetCapability(descriptorNum, simultaneousNum, find->Create(ep));
          added++;
        }
      }
    }
    find = find->link;
  }

  return added;
}

/////////////////////////////////////////////////////////////////////////////

OpalDynaCodecDLL::OpalDynaCodecDLL(const PFilePath & fn)
  : PDynaLink(fn)
{
  referenceCount = 0;
}

BOOL OpalDynaCodecDLL::Load()
{
#ifdef _WIN32
  unsigned (FAR *versionFn)(unsigned apiVersion);
#else
  unsigned (*versionFn)(unsigned apiVersion);
#endif

  if (!GetFunction("OpalCheckAPIVersion", (Function &)versionFn) || !(*versionFn)(CURRENT_API_VERSION)) {
    Close();
    return FALSE;
  }

  if (!GetFunction("OpalEnumerateCodecs", (Function &)EnumerateCodecsFn))
    Close();

  return TRUE;
}

OpalDLLCodecInfo * OpalDynaCodecDLL::EnumerateCodecs(unsigned * count)
{
  return (*EnumerateCodecsFn)(CURRENT_API_VERSION, count);
}

/////////////////////////////////////////////////////////////////////////////

OpalDynaAudioCodec::OpalDynaAudioCodec(const OpalDLLCodecRec & _info, Direction dir)
  : H323FramedAudioCodec(*_info.mediaFormat, dir), info(_info)
{
  PString prefix = (dir == Encoder) ? VALUE_OUTPUT : VALUE_INPUT;

  context         = info.CreateContext();
  samplesPerFrame = info.attributes(prefix + ATTRIBUTE_IOSAMPLESPERFRAME).AsUnsigned();
  bytesPerFrame   = info.attributes(prefix + ATTRIBUTE_IOBYTESPERFRAME).AsUnsigned();

  PTRACE(3, "Codec\t" << *info.mediaFormat << " " << (dir == Encoder ? "en" : "de")
         << "coder created");
}

OpalDynaAudioCodec::~OpalDynaAudioCodec()
{  
  info.DestroyContext(context);
}

BOOL OpalDynaAudioCodec::EncodeFrame(BYTE * buffer, unsigned & length)
{
  if (info.info.encoder == NULL)
    return FALSE;

  return (*info.info.encoder)(info.info.codecUserData, context, 
                                   sampleBuffer, samplesPerFrame, buffer, &length);
}

BOOL OpalDynaAudioCodec::DecodeFrame(const BYTE * buffer, unsigned length, unsigned & written)
{
  if (info.info.encoder == NULL)
    return FALSE;

  if (length < bytesPerFrame)
    return FALSE;

  return (*info.info.encoder)(info.info.codecUserData, context, buffer, length, &sampleBuffer[0], &written);
}

/////////////////////////////////////////////////////////////////////////////

OpalDynaCodecRegistration::OpalDynaCodecRegistration(const PString & name, 
                                                     OpalDLLCodecRec * _encoderInfo,
                                                     OpalDLLCodecRec * _decoderInfo,
                                                     OpalMediaFormat * _mediaFormat)
  : H323CapabilityRegistration(name), 
    encoderInfo(_encoderInfo),
    decoderInfo(_decoderInfo),
    mediaFormat(_mediaFormat)
{
}

H323Capability * OpalDynaCodecRegistration::Create(H323EndPoint & ep) const
{
  return decoderInfo->CreateCapability(ep);
}


/////////////////////////////////////////////////////////////////////////////

OpalDynaCodecNonStandardAudioCapability::OpalDynaCodecNonStandardAudioCapability(
      const OpalDLLCodecRec & _info,
      H323EndPoint & _endpoint,
      unsigned maxPacketSize,         /// Maximum size of an audio packet in frames
      unsigned desiredPacketSize,     /// Desired transmit size of an audio packet in frames
      BYTE country,                   /// t35 information
      BYTE extension,                 /// t35 information
      WORD manufacturer,              /// t35 information
      const BYTE * nonstdHeader,      /// nonstandard header
      PINDEX nonstdHeaderLen)

  : H323NonStandardAudioCapability(maxPacketSize, 
                                   desiredPacketSize, 
                                   country,
                                   extension,
                                   manufacturer,
                                   nonstdHeader,
                                   nonstdHeaderLen),
    info(_info), endpoint(_endpoint)
{
}

PObject * OpalDynaCodecNonStandardAudioCapability::Clone() const
{
  return new OpalDynaCodecNonStandardAudioCapability(*this);
}

PString OpalDynaCodecNonStandardAudioCapability::GetFormatName() const
{
  return *info.mediaFormat + H323EXT;
}

H323Codec * OpalDynaCodecNonStandardAudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new OpalDynaAudioCodec(info, direction);
}

/////////////////////////////////////////////////////////////////////////////

OpalDynaCodecStandardAudioCapability::OpalDynaCodecStandardAudioCapability(
      const OpalDLLCodecRec & _info,
      H323EndPoint & _endpoint,
      unsigned maxPacketSize,         /// Maximum size of an audio packet in frames
      unsigned desiredPacketSize,     /// Desired transmit size of an audio packet in frames
      unsigned _subType)
  : H323AudioCapability(maxPacketSize, desiredPacketSize), 
    info(_info), endpoint(_endpoint), subType(_subType)
{
}

PObject * OpalDynaCodecStandardAudioCapability::Clone() const
{
  return new OpalDynaCodecStandardAudioCapability(*this);
}

PString OpalDynaCodecStandardAudioCapability::GetFormatName() const
{
  return *info.mediaFormat + H323EXT;
}

unsigned OpalDynaCodecStandardAudioCapability::GetSubType() const
{
  return subType;
}

H323Codec * OpalDynaCodecStandardAudioCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new OpalDynaAudioCodec(info, direction);
}

BOOL OpalDynaCodecStandardAudioCapability::OnSendingPDU(H245_AudioCapability & cap, unsigned packetSize) const
{
  switch (subType) {
    case H245_AudioCapability::e_g7231:
      {
        cap.SetTag(H245_AudioCapability::e_g7231);
        H245_AudioCapability_g7231 & g7231 = cap;
        g7231.m_maxAl_sduAudioFrames = packetSize;
        //TODO:  g7231.m_silenceSuppression   = info.GetParameter((direction == Encoder), "silenceSuppression", "0").AsUnsigned();
      }
      break;

    case H245_AudioCapability::e_gsmFullRate:
      {
        cap.SetTag(H245_AudioCapability::e_gsmFullRate);
        H245_GSMAudioCapability & gsm = cap;
        gsm.m_audioUnitSize = packetSize*GSM_BYTES_PER_FRAME;
      }
      break;

    //case H245_AudioCapability::e_g728:
    //case H245_AudioCapability::e_g729:
    //case H245_AudioCapability::e_g729AnnexA;
    //case H245_AudioCapability::e_g728:
    //case H245_AudioCapability::e_g711Alaw64k:
    //case H245_AudioCapability::e_g711Alaw56k:
    //case H245_AudioCapability::e_g711Ulaw64k:
    //case H245_AudioCapability::e_g711Ulaw56k:
    //case H245_AudioCapability::e_g722_64k:
    //case H245_AudioCapability::e_g722_56k:
    //case H245_AudioCapability::e_g722_48k:
    default:
      break;
  }

  return TRUE;
}


BOOL OpalDynaCodecStandardAudioCapability::OnReceivedPDU(const H245_AudioCapability & cap, unsigned & packetSize)
{
  if (cap.GetTag() != subType)
    return FALSE;

  switch (subType) {
    case H245_AudioCapability::e_g7231:
      {
        const H245_AudioCapability_g7231 & g7231 = cap;
        packetSize = g7231.m_maxAl_sduAudioFrames;
        //TODO: info.SetParameter((direction == Encoder), "silenceSuppression", PString(PString::Unsigned, g7231.m_silenceSuppression));
      }
      break;

    case H245_AudioCapability::e_gsmFullRate:
      {
        const H245_GSMAudioCapability & gsm = cap;
        packetSize = gsm.m_audioUnitSize / GSM_BYTES_PER_FRAME;
        if (packetSize == 0)
          packetSize = 1;
      }
      break;

    //case H245_AudioCapability::e_g728:
    //case H245_AudioCapability::e_g729:
    //case H245_AudioCapability::e_g729AnnexA;
    //case H245_AudioCapability::e_g728:
    //case H245_AudioCapability::e_g711Alaw64k:
    //case H245_AudioCapability::e_g711Alaw56k:
    //case H245_AudioCapability::e_g711Ulaw64k:
    //case H245_AudioCapability::e_g711Ulaw56k:
    //case H245_AudioCapability::e_g722_64k:
    //case H245_AudioCapability::e_g722_56k:
    //case H245_AudioCapability::e_g722_48k:
    default:
      break;
  }

  return TRUE;
}

/////////////////////////////////////////////////////////////////////////////

OpalDynaCodecStandardVideoCapability::OpalDynaCodecStandardVideoCapability(
      const OpalDLLCodecRec & _info,
      H323EndPoint & _endpoint,
      unsigned _subType)

  : H323VideoCapability(), 
    info(_info), endpoint(_endpoint), subType(_subType)
{
}

PObject * OpalDynaCodecStandardVideoCapability::Clone() const
{
  return new OpalDynaCodecStandardVideoCapability(*this);
}

PString OpalDynaCodecStandardVideoCapability::GetFormatName() const
{
  return *info.mediaFormat + H323EXT;
}

unsigned OpalDynaCodecStandardVideoCapability::GetSubType() const
{
  return subType;
}

H323Codec * OpalDynaCodecStandardVideoCapability::CreateCodec(H323Codec::Direction direction) const
{
  return new OpalDynaVideoCodec(info, direction);
}


BOOL OpalDynaCodecStandardVideoCapability::OnSendingPDU(H245_VideoCapability & /*pdu*/) const
{
  /*
  switch (subType) {
    default:
      break;
  }
  */
  return TRUE;
}

BOOL OpalDynaCodecStandardVideoCapability::OnSendingPDU(H245_VideoMode & /*pdu*/) const
{
  /*
  switch (subType) {
    default:
      break;
  }
  */  
  return TRUE;
}

BOOL OpalDynaCodecStandardVideoCapability::OnReceivedPDU(const H245_VideoCapability & /*pdu*/)
{
  /*
  switch (subType) {
    default:
      break;
  }
  */
  return TRUE;
}

/////////////////////////////////////////////////////////////////////////////

OpalDynaVideoCodec::OpalDynaVideoCodec(const OpalDLLCodecRec & _info, Direction dir)
  : H323VideoCodec(*_info.mediaFormat, dir), info(_info)
{
  context = info.CreateContext();
}

OpalDynaVideoCodec::~OpalDynaVideoCodec()
{
  info.DestroyContext(context);
}

BOOL OpalDynaVideoCodec::Read(BYTE * /*buffer*/, unsigned & /*length*/, RTP_DataFrame & /*rtpFrame*/)
{
  return FALSE;
}

BOOL OpalDynaVideoCodec::Write(const BYTE * /*buffer*/, unsigned /*length*/, const RTP_DataFrame & /*rtp*/, unsigned & /*written*/)
{
  return FALSE;
}

/////////////////////////////////////////////////////////////////////////////