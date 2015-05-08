/*
 * mediafmt.cxx
 *
 * Media Format descriptions
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
 * $Log: mediafmt.cxx,v $
 * Revision 1.11  2002/12/03 09:20:01  craigs
 * Fixed problem with RFC2833 and a dynamic RTP type using the same RTP payload number
 *
 * Revision 1.10  2002/12/02 03:06:26  robertj
 * Fixed over zealous removal of code when NO_AUDIO_CODECS set.
 *
 * Revision 1.9  2002/10/30 05:54:17  craigs
 * Fixed compatibilty problems with G.723.1 6k3 and 5k3
 *
 * Revision 1.8  2002/08/05 10:03:48  robertj
 * Cosmetic changes to normalise the usage of pragma interface/implementation.
 *
 * Revision 1.7  2002/06/25 08:30:13  robertj
 * Changes to differentiate between stright G.723.1 and G.723.1 Annex A using
 *   the OLC dataType silenceSuppression field so does not send SID frames
 *   to receiver codecs that do not understand them.
 *
 * Revision 1.6  2002/01/22 07:08:26  robertj
 * Added IllegalPayloadType enum as need marker for none set
 *   and MaxPayloadType is a legal value.
 *
 * Revision 1.5  2001/12/11 04:27:28  craigs
 * Added support for 5.3kbps G723.1
 *
 * Revision 1.4  2001/09/21 02:51:45  robertj
 * Implemented static object for all "known" media formats.
 * Added default session ID to media format description.
 *
 * Revision 1.3  2001/05/11 04:43:43  robertj
 * Added variable names for standard PCM-16 media format name.
 *
 * Revision 1.2  2001/02/09 05:13:56  craigs
 * Added pragma implementation to (hopefully) reduce the executable image size
 * under Linux
 *
 * Revision 1.1  2001/01/25 07:27:16  robertj
 * Major changes to add more flexible OpalMediaFormat class to normalise
 *   all information about media types, especially codecs.
 *
 */

#include <ptlib.h>

#ifdef __GNUC__
#pragma implementation "mediafmt.h"
#endif

#include "mediafmt.h"

#include "rtp.h"


/////////////////////////////////////////////////////////////////////////////

OpalMediaFormat const OpalPCM16(
  OPAL_PCM16,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::L16_Mono,
  TRUE,   // Needs jitter
  128000, // bits/sec
  16, // bytes/frame
  8, // 1 millisecond
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG711uLaw(
  OPAL_G711_ULAW_64K,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::PCMU,
  TRUE,   // Needs jitter
  64000, // bits/sec
  8, // bytes/frame
  8, // 1 millisecond/frame
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG711ALaw(
  OPAL_G711_ALAW_64K,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::PCMA,
  TRUE,   // Needs jitter
  64000, // bits/sec
  8, // bytes/frame
  8, // 1 millisecond/frame
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG728(  
  OPAL_G728,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::G728,
  TRUE, // Needs jitter
  16000,// bits/sec
  5,    // bytes
  20,   // 2.5 milliseconds
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG729( 
  OPAL_G729,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::G729,
  TRUE, // Needs jitter
  8000, // bits/sec
  10,   // bytes
  80,   // 10 milliseconds
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG729A( 
  OPAL_G729A,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::G729,
  TRUE, // Needs jitter
  8000, // bits/sec
  10,   // bytes
  80,   // 10 milliseconds
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG729B(
  OPAL_G729B,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::G729,
  TRUE, // Needs jitter
  8000, // bits/sec
  10,   // bytes
  80,   // 10 milliseconds
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG729AB(
  OPAL_G729AB,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::G729,
  TRUE, // Needs jitter
  8000, // bits/sec
  10,   // bytes
  80,   // 10 milliseconds
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG7231_6k3(
  OPAL_G7231_6k3,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::G7231,
  TRUE, // Needs jitter
  6400, // bits/sec
  24,   // bytes
  240,  // 30 milliseconds
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG7231_5k3(
  OPAL_G7231_5k3,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::G7231,
  TRUE, // Needs jitter
  5300, // bits/sec
  24,   // bytes
  240,  // 30 milliseconds
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG7231A_6k3(
  OPAL_G7231A_6k3,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::G7231,
  TRUE, // Needs jitter
  6400, // bits/sec
  24,   // bytes
  240,  // 30 milliseconds
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalG7231A_5k3(
  OPAL_G7231A_5k3,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::G7231,
  TRUE, // Needs jitter
  5300, // bits/sec
  24,   // bytes
  240,  // 30 milliseconds
  OpalMediaFormat::AudioTimeUnits
);

OpalMediaFormat const OpalGSM0610(
  OPAL_GSM0610,
  OpalMediaFormat::DefaultAudioSessionID,
  RTP_DataFrame::GSM,
  TRUE,  // Needs jitter
  13200, // bits/sec
  33,    // bytes
  160,   // 20 milliseconds
  OpalMediaFormat::AudioTimeUnits
);


/////////////////////////////////////////////////////////////////////////////

OpalMediaFormat::OpalMediaFormat()
{
  rtpPayloadType = RTP_DataFrame::IllegalPayloadType;

  needsJitter = FALSE;
  bandwidth = 0;
  frameSize = 0;
  frameTime = 0;
  timeUnits = 0;
}


OpalMediaFormat::OpalMediaFormat(const char * search, BOOL exact)
  : PCaselessString(search)
{
  rtpPayloadType = RTP_DataFrame::MaxPayloadType;

  needsJitter = FALSE;
  bandwidth = 0;
  frameSize = 0;
  frameTime = 0;
  timeUnits = 0;

  const List & registeredFormats = GetRegisteredMediaFormats();
  for (PINDEX i = 0; i < registeredFormats.GetSize(); i++) {
    if (exact ? (registeredFormats[i] == search)
              : (registeredFormats[i].Find(search) != P_MAX_INDEX)) {
      *this = registeredFormats[i];
      return;
    }
  }
}


OpalMediaFormat::OpalMediaFormat(const char * fullName,
                                 unsigned dsid,
                                 RTP_DataFrame::PayloadTypes pt,
                                 BOOL     nj,
                                 unsigned bw,
                                 PINDEX   fs,
                                 unsigned ft,
                                 unsigned tu)
  : PCaselessString(fullName)
{
  rtpPayloadType = pt;
  defaultSessionID = dsid;
  needsJitter = nj;
  bandwidth = bw;
  frameSize = fs;
  frameTime = ft;
  timeUnits = tu;

  PINDEX i;
  List & registeredFormats = GetMediaFormatsList();

  if ((i = registeredFormats.GetValuesIndex(*this)) != P_MAX_INDEX) {
    *this = registeredFormats[i]; // Already registered, use previous values
    return;
  }

  // assume non-dynamic payload types are correct and do not need deconflicting
  if (rtpPayloadType < RTP_DataFrame::DynamicBase) {
    registeredFormats.Append(this);
    return;
  }

  // find the next unused dynamic number, and find anything with the new 
  // rtp payload type if it is explicitly required
  OpalMediaFormat * match = NULL;
  RTP_DataFrame::PayloadTypes nextUnused = RTP_DataFrame::DynamicBase;
  do {
    for (i = 0; i < registeredFormats.GetSize(); i++) {
      if (registeredFormats[i].GetPayloadType() == nextUnused) {
        nextUnused = (RTP_DataFrame::PayloadTypes)(nextUnused + 1);
        break;
      }
      if ((rtpPayloadType >= RTP_DataFrame::DynamicBase) && 
          (registeredFormats[i].GetPayloadType() == rtpPayloadType))
        match = &registeredFormats[i];
    }
  } while (i < registeredFormats.GetSize());

  // if new format requires a specific payload type in the dynamic range, 
  // then move the old format to the next unused format
  if (match != NULL)
    match->rtpPayloadType = nextUnused;
  else
    rtpPayloadType = nextUnused;

  registeredFormats.Append(this);
}


OpalMediaFormat::List & OpalMediaFormat::GetMediaFormatsList()
{
  static List registeredFormats;
  registeredFormats.DisallowDeleteObjects();
  return registeredFormats;
}


// End of File ///////////////////////////////////////////////////////////////
