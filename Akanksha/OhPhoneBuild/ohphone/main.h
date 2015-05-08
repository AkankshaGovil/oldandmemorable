/*
 * main.h
 *
 * PWLib application header file for OhPhone
 *
 * A H.323 "net telephone" application.
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
 * Portions of this code were written with the assisance of funding from
 * Vovida Networks, Inc. http://www.vovida.com.
 *
 * Contributor(s): ______________________________________.
 *                 Derek J Smithies (derek@indranet.co.nz)
 *
 * $Log: main.h,v $
 * Revision 1.97  2003/05/14 02:49:52  dereksmithies
 * Add videolose option, so X percentage of video packets are dropped when in --videotest mode
 *
 * Revision 1.96  2003/05/07 02:45:58  dereks
 * Alter ohphone to use the PSDLVideoOutputDevice class, which is now part of pwlib.
 *
 * Revision 1.95  2002/12/16 09:27:25  robertj
 * Added new video bit rate control, thanks Walter H. Whitlock
 *
 * Revision 1.94  2002/10/31 00:53:38  robertj
 * Enhanced jitter buffer system so operates dynamically between minimum and
 *   maximum values. Altered API to assure app writers note the change!
 *
 * Revision 1.93  2002/10/15 10:46:43  rogerh
 * Add tweak by Sahai to support operation behind a NAT that forwards ports.
 * This uses TranslateTCPAddress to change the address reported to connections
 * that occur from outside the 192.x.x.x subnet. Copied from OpenMCU.
 *
 * Revision 1.92  2002/08/07 00:46:42  dereks
 * Report statistics for video RTP packets. (No output if no video session)
 *
 * Revision 1.91  2002/08/05 01:33:34  robertj
 * Fixed incorrect override of the SetupTransfer() function that stopped the
 *   ability to do H.250 call transfer, thanks Vladimir Toncar
 *
 * Revision 1.90  2002/05/06 02:55:47  dereks
 * Fix operation of --autodisconnect n , so works when video enabled.
 *
 * Revision 1.89  2002/04/26 03:33:32  dereks
 * Major upgrade. All calls to SDL library are now done by one thread.
 *
 * Revision 1.88  2002/04/18 07:46:28  craigs
 * Added new functions to remove H245 in SETUP, and to allow removal of
 * user input indication capabilities
 *
 * Revision 1.87  2002/01/28 10:43:57  rogerh
 * Wrap some code with HAS_LIDDEVICE so it compiles on systems without
 * IxJ and VPBlaster
 *
 * Revision 1.86  2002/01/24 07:42:37  robertj
 * Added ability to turn off H.245 negotiations in SETUP option
 *
 * Revision 1.85  2002/01/15 05:50:07  craigs
 * Added support for VoIPBlaster
 *
 * Revision 1.84  2002/01/14 03:21:12  robertj
 * Added ability to set capture caolour format, thanks Walter Whitlock
 *
 * Revision 1.83  2002/01/04 04:17:52  dereks
 * Add code from Walter Whitlock to flip video, and improve the
 * --videotest mode, which displays local video (without a call).  Many thanks.
 *
 * Revision 1.82  2001/10/23 02:21:39  dereks
 * Initial release CU30 video codec.
 * Add --videotest option, to display raw video, but not invoke a call.
 *
 * Revision 1.81  2001/09/25 03:18:09  dereks
 * Add code from Tiziano Morganti to set bitrate for H261 video codec.
 * Use --videobitrate n         Thanks for your code - good work!!
 *
 * Revision 1.80  2001/05/09 04:59:02  robertj
 * Bug fixes in H.450.2, thanks Klein Stefan.
 *
 * Revision 1.79  2001/03/12 03:52:09  dereks
 * Tidy up fake video user interface. use --videodevice fake now.
 *
 * Revision 1.78  2001/03/07 01:47:45  dereks
 * Initial release of SDL (Simple DirectMedia Layer, a cross-platform multimedia library),
 * a video library code.
 *
 * Revision 1.77  2001/02/23 00:34:45  robertj
 * Added ability to add/display non-standard data in setup PDU.
 *
 * Revision 1.76  2001/01/24 05:41:53  robertj
 * Altered volume control range to be percentage, ie 100 is max volume.
 *
 * Revision 1.75  2001/01/05 15:30:31  rogerh
 * Move SendDTMF() outside HAS_IXJ section to match its location in main.cxx
 *
 * Revision 1.74  2000/12/19 22:35:53  dereks
 * Install revised video handling code, so that a video channel is used.
 * Code now better handles the situation where the video grabber could not be opened.
 *
 * Revision 1.73  2000/12/16 21:54:31  eokerson
 * Added DTMF generation when User Input Indication received.
 *
 * Revision 1.72  2000/10/13 01:47:59  dereks
 * Include command line option for setting the number of transmitted video
 * frames per second.   use --videotxfps n  (default n is 10)
 *
 * Revision 1.71  2000/09/27 03:06:13  dereks
 * Added lots of PTRACE statements to xlib code.
 * Removed X videoMutex from main.cxx & main.h
 * Removed some weird display issues from X code.
 *
 * Revision 1.70  2000/09/22 00:30:52  craigs
 * Enhanced autoDisconnect and autoRepeat functions
 *
 * Revision 1.69  2000/09/20 21:27:01  craigs
 * Fixed problem with default connection options
 *
 * Revision 1.68  2000/09/08 06:50:06  craigs
 * Added ability to set per-speed dial options
 * Fixed problem with transmit-only endpoints
 *
 * Revision 1.67  2000/08/30 01:52:53  craigs
 * New IXJ volume code with pseudo-log scaling
 *
 * Revision 1.66  2000/08/21 06:01:35  craigs
 * Added call lists and redial capabilities
 * Updated documentation
 *
 * Revision 1.65  2000/08/21 04:41:58  dereks
 * Add parameter to set a)transmitted video quality and b)number of unchanged
 * blocks that are sent with every frame.
 * Fix some problems introduced with --videopip option.
 *
 * Revision 1.64  2000/08/07 03:47:42  dereks
 * Add picture in picture option (only for  X window display), better handling
 * of X windows. Handles situation where user selects cross on a X window.
 *
 * Revision 1.63  2000/07/31 14:08:22  robertj
 * Added fast start and H.245 tunneling flags to the H323Connection constructor so can
 *    disabled these features in easier manner to overriding virtuals.
 *
 * Revision 1.62  2000/07/08 19:50:15  craigs
 * Added options to set ports used for listening and connecting
 *
 * Revision 1.61  2000/07/03 09:14:17  craigs
 * Seperated vide receive and transmit options
 *
 * Revision 1.60  2000/06/13 22:41:20  craigs
 * Added last called party dialling
 *
 * Revision 1.59  2000/06/07 05:50:22  robertj
 * Added call forwarding.
 *
 * Revision 1.58  2000/05/25 12:06:20  robertj
 * Added PConfigArgs class so can save program arguments to config files.
 *
 * Revision 1.57  2000/05/24 12:27:46  craigs
 * Added new code to changeing of sound driver on the fly
 *
 * Revision 1.56  2000/05/18 07:02:47  craigs
 * Adde extra mixer stuff
 *
 * Revision 1.55  2000/05/10 05:46:35  craigs
 * Another try at fixing the problem
 *
 * Revision 1.54  2000/05/10 02:12:31  craigs
 * Added ability to play a file when ringing handset
 *
 * Revision 1.53  2000/05/09 11:20:52  craigs
 * Fixed statistics display and help message
 * Started adding mixer code
 *
 * Revision 1.52  2000/05/02 04:32:25  robertj
 * Fixed copyright notice comment.
 *
 * Revision 1.51  2000/04/19 02:05:39  robertj
 * BeOS port changes.
 *
 * Revision 1.50  2000/04/05 16:28:27  craigs
 * Added caller ID functions
 *
 * Revision 1.49  2000/03/25 01:34:46  craigs
 * Changed name from voxilla to ohphone
 *
 * Revision 1.48  2000/03/20 20:21:32  craigs
 * Completely rewrote the state engine!
 *
 * Revision 1.47  2000/03/17 03:43:49  craigs
 * New state machine and extra features
 *
 * Revision 1.46  2000/02/25 13:39:51  craigs
 * Added ability to disable local video window via null video device
 *
 * Revision 1.45  2000/02/25 13:10:03  craigs
 * Added abioty to disable menu, and to dial after hangup
 *
 * Revision 1.44  2000/02/17 07:02:33  craigs
 * Moved declaration of HAS_IXJ, HAS_VPB and LINUX_TELEPHONY into common Makefile
 *
 * Revision 1.43  2000/02/17 05:31:21  craigs
 * Added H245 tunnelling disable
 *
 * Revision 1.42  2000/02/10 03:08:03  craigs
 * Added ability to specify NTSC or PAL video format
 *
 * Revision 1.41  2000/02/04 05:17:31  craigs
 * New changes for video transmission from Derek Smithies
 *
 * Revision 1.40  2000/01/05 08:32:04  craigs
 * Added DTMF to user indication message conversion
 *
 * Revision 1.39  2000/01/04 00:21:21  craigs
 * Added additional calling tones, and updated for new Opal classes
 *
 * Revision 1.38  1999/12/29 01:20:17  craigs
 * Added ring tones and the ability to create and list speed dials
 *
 * Revision 1.37  1999/12/23 23:02:36  robertj
 * File reorganision for separating RTP from H.323 and creation of LID for VPB support.
 *
 * Revision 1.36  1999/11/29 09:03:42  craigs
 * Added X11 video capability
 *
 * Revision 1.35  1999/11/23 05:15:46  craigs
 * Added dialtone and speed dialling
 *
 * Revision 1.34  1999/11/19 14:02:26  craigs
 * Added flag to disable silence detection on G.711 and GSM codecs
 *
 * Revision 1.33  1999/11/19 04:42:01  craigs
 * Fixed problem with user interface and added speed dials
 *
 * Revision 1.32  1999/11/10 23:30:49  robertj
 * Changed OnAnswerCall() call back function  to allow for asyncronous response.
 *
 * Revision 1.31  1999/11/07 04:44:27  robertj
 * Fixed Win32 compatibility issues.
 *
 * Revision 1.30  1999/11/07 03:43:06  craigs
 * Added ifdef around IXJ routines, and added "--interface" flag
 *
 * Revision 1.29  1999/11/05 08:54:42  robertj
 * Rewrite of ixj interface code to fix support for arbitrary codecs.
 *
 * Revision 1.28  1999/10/28 12:21:34  robertj
 * Added AEC support and speakerphone switching button.
 *
 * Revision 1.27  1999/10/27 06:33:49  robertj
 * Changes to use library platform independent Quicknet xJACK cards.
 *
 * Revision 1.26  1999/10/22 05:46:25  craigs
 * Fixed for changes to AudioChannel/VideoDevice attachment
 *
 * Revision 1.25  1999/10/10 14:09:26  robertj
 * Added auto-answer flag
 *
 * Revision 1.24  1999/10/09 01:17:06  craigs
 * Added codecs to OpenAudioChannel and OpenVideoDevice functions
 *
 * Revision 1.23  1999/09/23 07:25:12  robertj
 * Added open audio and video function to connection and started multi-frame codec send functionality.
 *
 * Revision 1.22  1999/09/21 08:39:01  craigs
 * Added complete support for QuickNet G.723.1
 * Added support for Linux video
 *
 * Revision 1.21  1999/09/08 05:16:51  robertj
 * Made H.261 "fake" codec selectable with command line option.
 *
 * Revision 1.20  1999/09/08 04:05:49  robertj
 * Added support for video capabilities & codec, still needs the actual codec itself!
 *
 * Revision 1.19  1999/08/31 12:34:19  robertj
 * Added gatekeeper support.
 *
 * Revision 1.18  1999/08/25 05:17:44  robertj
 * Simplified application structure (better for tutorial purposes)
 *
 * Revision 1.17  1999/07/26 07:06:12  craigs
 * Added support for QuickNet Cards
 *
 * Revision 1.16  1999/07/16 16:05:14  robertj
 * Added more run time options.
 *
 * Revision 1.15  1999/07/13 09:53:24  robertj
 * Fixed some problems with jitter buffer and added more debugging.
 *
 * Revision 1.14  1999/07/13 02:50:58  craigs
 * Changed semantics of SetPlayDevice/SetRecordDevice, only descendent
 *    endpoint assumes PSoundChannel devices for audio codec.
 *
 * Revision 1.13  1999/07/09 06:09:52  robertj
 * Major implementation. An ENORMOUS amount of stuff added everywhere.
 *
 * Revision 1.12  1999/06/25 16:21:02  robertj
 * Restructure of directories
 *
 * Revision 1.11  1999/06/22 13:42:31  robertj
 * Added user question on listener version to accept incoming calls.
 *
 * Revision 1.10  1999/06/09 05:26:19  robertj
 * Major restructuring of classes.
 *
 * Revision 1.9  1999/06/06 06:06:35  robertj
 * Changes for new ASN compiler and v2 protocol ASN files.
 *
 * Revision 1.8  1999/05/28 12:39:58  craigs
 * Added ability to select sound device at run time
 *
 * Revision 1.7  1999/05/22 12:51:58  craigs
 * Fixed to work with new Linux implementation
 *
 * Revision 1.6  1999/04/26 06:14:46  craigs
 * Initial implementation for RTP decoding and lots of stuff
 * As a whole, these changes are called "First Noise"
 *
 * Revision 1.5  1999/02/23 11:04:28  robertj
 * Added capability to make outgoing call.
 *
 * Revision 1.4  1999/01/16 08:05:00  robertj
 * Moved h323 code to a library
 *
 * Revision 1.3  1999/01/16 01:31:36  robertj
 * Major implementation.
 *
 * Revision 1.2  1998/12/14 10:15:30  robertj
 * Fixed leak of sockets
 *
 * Revision 1.1  1998/12/14 09:13:23  robertj
 * Initial revision
 *
 */

#ifndef _OhPhone_MAIN_H
#define _OhPhone_MAIN_H

#include <h323.h>

#ifdef _WIN32
#include <vblasterlid.h>
#endif

#ifdef HAS_IXJ
#include <ixjlid.h>
#endif

#if defined(HAS_IXJ) || defined(HAS_VBLASTER)
#define HAS_LIDDEVICE
#endif

#if P_SDL
class PSDLDisplayThread;
#endif

#ifdef __BEOS__

#ifndef _APPLICATION_H
#include <Application.h>
#endif


class OhPhoneApplication : public BApplication 
{
  public:
    OhPhoneApplication()
      : BApplication("application/x-vnd.BeOhPhone") { }
};

OhPhoneApplication OhPhoneApp;

#endif


class OhPhone : public PProcess
{
    PCLASSINFO(OhPhone, PProcess)
  public:
    OhPhone();
    ~OhPhone();

    void Main();
};

class CallOptions : public PObject
{
  PCLASSINFO(CallOptions, PObject);

  public:
    BOOL Initialise(PArgList & args);
    void PrintOn(ostream & str) const;

    BOOL     noFastStart;
    BOOL     noH245Tunnelling;
    BOOL     noH245InSetup;
    BOOL     noSilenceSuppression;
    unsigned minJitter;
    unsigned maxJitter;
    PINDEX   connectRing;
    WORD     connectPort;
};


class MyH323EndPoint : public H323EndPoint
{
    PCLASSINFO(MyH323EndPoint, H323EndPoint);
  public:
    // overrides from H323EndPoint
    virtual H323Connection * CreateConnection(unsigned callReference);
    virtual BOOL OnIncomingCall(H323Connection &, const H323SignalPDU &, H323SignalPDU &);
    virtual BOOL OnConnectionForwarded(H323Connection &, const PString &, const H323SignalPDU &);
    virtual void OnConnectionEstablished(H323Connection &, const PString &);
    virtual void OnConnectionCleared(H323Connection &, const PString &);
    virtual BOOL OpenAudioChannel(H323Connection &, BOOL, unsigned, H323AudioCodec &);
    virtual BOOL OpenVideoChannel(H323Connection &, BOOL, H323VideoCodec &);
    virtual H323Connection * SetupTransfer(const PString &, const PString &, const PString &, PString &, void * userData = NULL);
    virtual void TranslateTCPAddress(PIPSocket::Address &localAddr, const PIPSocket::Address &remoteAddr);


    // new functions
    BOOL Initialise(PConfigArgs & args, int verbose, BOOL hasMenu);
    void MakeOutgoingCall(const PString &, const PString &);
    void MakeOutgoingCall(const PString &, const PString &, CallOptions callOptions);
    void AwaitTermination();
    void TriggerDisconnect();

    void HandleUserInterface();
    void StartRinging();
    void StopRinging();
    void HandleRinging();

    void TestVideoGrabber(PConfigArgs &args);
    void TestHandleUserInterface();


#ifdef HAS_LIDDEVICE
    void HandleStateChange(BOOL onHook);
    void HandleHandsetOffHook();
    void HandleHandsetOnHook();
    void HandleHandsetDTMF(PString & digits);
    void HandleHandsetTimeouts(const PTime & offHookTime);
#endif

    void SendDTMF(const char * tone);

    void StartCall(const PString & str);
    void NewSpeedDial(const PString & str);
    void ListSpeedDials();

    PDECLARE_NOTIFIER(PTimer, MyH323EndPoint, OnAutoDisconnect);

    PString GetCurrentCallToken() const
      { return currentCallToken; }

    BOOL       terminateOnHangup;

    void WaitForSdlTermination();
    BOOL InitialiseSdl(PConfigArgs & args);

    int GetChannelsOpenLimit() const
      { return channelsOpenLimit; }

  protected:
    // only used internally
    BOOL SetSoundDevice(PConfigArgs &, const char *, PSoundChannel::Directions);
    void AnswerCall(H323Connection::AnswerCallResponse response);

    void ReportSessionStatistics(H323Connection *connection, unsigned sessionID);

    CallOptions defaultCallOptions;
    CallOptions currentCallOptions;


    int  verbose;
    BOOL autoAnswer;

    PString  alwaysForwardParty;
    PString  busyForwardParty;
    PString  noAnswerForwardParty;
    unsigned noAnswerTime;
    PTimer   noAnswerTimer;
    PDECLARE_NOTIFIER(PTimer, MyH323EndPoint, OnNoAnswerTimeout);

    PString videoReceiveDevice;
    int  videoQuality;
    int  videoTxQuality;
    int  videoTxMinQuality;

    int  videoSize;       //0=small, 1=large.
    int  videoInput;
    int  videoQ;           
    int  videoFill;
    int  videoFramesPS;
    int  videoBitRate;
    int  frameTimeMs;

    BOOL    videoIsPal;
    BOOL    videoFake;    
    BOOL    videoLocal;
    BOOL    videoPIP;
    PString videoDevice;
    PString pfdColourFormat;
    int     videoCu30Stats;
    PString configDirectory;

// used for testing the video (no connection made).
    PVideoChannel *localVideoChannel; 

    PString autoDial;
    BOOL    dialAfterHangup;
    BOOL    callerIdEnable;
    BOOL    callerIdCallWaitingEnable;
    PString setupParameter;

    PFilePath ringFile;
    int ringDelay;
    PSyncPoint ringFlag;
    PThread * ringThread;

    int autoDisconnect;
    PTimer autoDisconnectTimer;

    int recordVolume;
    int playVolume;

#ifdef HAS_OSS
    BOOL InitialiseMixer(PConfigArgs & args, int _verbose);
    int  mixerDev;
    int  mixerRecChan;
    int  savedMixerRecChan;
    int  ossRecVol;
    int  ossPlayVol;
#endif

    PString currentCallToken;
    PString callTransferCallToken;

    enum {
      uiDialtone,
      uiAnsweringCall,
      uiConnectingCall,
      uiWaitingForAnswer,
      uiCallInProgress,
      uiCallHungup,
      uiStateIllegal,
    } uiState;

    PMutex uiStateMutex;

    PSyncPoint exitFlag;
    BOOL       speakerphoneSwitch;
    BOOL       hasMenu;
#ifdef HAS_LIDDEVICE
    BOOL autoHook;

    OpalLineInterfaceDevice * lidDevice;
    BOOL isXJack;
#endif

#if P_SDL
    PSDLDisplayThread *sdlThread;
    PMutex           sdlThreadLock;
#endif
    int channelsOpenLimit;

    BOOL behind_masq;
    PIPSocket::Address *masqAddressPtr;

  friend class MyH323Connection;
};


class MyH323Connection : public H323Connection
{
    PCLASSINFO(MyH323Connection, H323Connection);

  public:
    MyH323Connection(
      MyH323EndPoint & ep,
      unsigned callRef,
      unsigned options,
      unsigned minJitter,
      unsigned maxJitter,
      int verbose
    );

    // overrides from H323Connection
    BOOL OnSendSignalSetup(H323SignalPDU & setupPDU);
    AnswerCallResponse OnAnswerCall(const PString &, const H323SignalPDU &, H323SignalPDU &);
    BOOL OnStartLogicalChannel(H323Channel &);
    void OnClosedLogicalChannel(H323Channel &);
    BOOL OnAlerting(const H323SignalPDU &, const PString &);
    void OnUserInputString(const PString &);
    PString GetCallerIdString() const;

  protected:
    MyH323EndPoint & myEndpoint;
    int verbose;
    int channelsOpen;
};

//////////////////////////////////////////////

class UserInterfaceThread : public PThread
{
    PCLASSINFO(UserInterfaceThread, PThread);
  public:
    UserInterfaceThread(MyH323EndPoint & end)
      : PThread(1000, NoAutoDeleteThread), endpoint(end) { Resume(); }
    void Main()
      { endpoint.HandleUserInterface(); }
  protected:
    MyH323EndPoint & endpoint;
};

//////////////////////////////////////////////

class TestUserInterfaceThread : public PThread
{
    PCLASSINFO(TestUserInterfaceThread, PThread);
  public:
    TestUserInterfaceThread(MyH323EndPoint & end)
      : PThread(1000, NoAutoDeleteThread), endpoint(end) { Resume(); }
    void Main()
      { endpoint.TestHandleUserInterface(); }
  protected:
    MyH323EndPoint & endpoint;
};

#endif  // _OhPhone_MAIN_H


// End of File ///////////////////////////////////////////////////////////////
