/*
 * main.cxx
 *
 * PWLib application source file for OhPhone
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
 *                 Walter H Whitlock (twohives@nc.rr.com)
 *
 * $Log: main.cxx,v $
 * Revision 1.315  2003/08/04 04:07:54  dereksmithies
 * Put H261 Capability back in the source
 *
 * Revision 1.314  2003/07/24 05:14:52  dereksmithies
 * Support for vich263 added
 *
 * Revision 1.313  2003/06/12 19:39:11  shawn
 * Added shared memory video input/output devices.  Video frames of these two
 * devices are stored in a named shared memory region and can be accessed by
 * other applications.
 *
 * Revision 1.312  2003/06/04 19:03:58  shawn
 * realtime scheduling for OSX is replaced by fixed priority scheduling in pwlib
 *
 * Revision 1.311  2003/05/23 05:19:03  rjongbloed
 * Added extra #define for H263 codec
 *
 * Revision 1.310  2003/05/15 01:00:14  rjongbloed
 * Fixed use of correct autoconf variable to include H.263 codec
 *
 * Revision 1.309  2003/05/14 13:58:39  rjongbloed
 * Removed hack of using special payload type for H.263 for a method which
 *   would be less prone to failure in the future.
 *
 * Revision 1.308  2003/05/14 02:49:52  dereksmithies
 * Add videolose option, so X percentage of video packets are dropped when in --videotest mode
 *
 * Revision 1.307  2003/05/07 02:45:58  dereks
 * Alter ohphone to use the PSDLVideoOutputDevice class, which is now part of pwlib.
 *
 * Revision 1.306  2003/04/16 04:31:22  dereks
 * Initial release of h263 video codec, which utilises the ffmpeg library.
 * Thanks to Guilhem Tardy, and to AliceStreet
 *
 * Revision 1.305  2003/04/15 21:16:53  dereks
 * Patch for firewire video applied - thanks to Goergi Georgiev.
 *
 * Revision 1.304  2003/04/04 02:14:34  robertj
 * Fixed IPv6 support for ports on interfaces, pointed out by Kostas Stamos
 *
 * Revision 1.303  2003/03/31 00:22:32  dereks
 * Can now read 20 digits, instead of 10, from the IXJ card. Thanks Jorge Minassian.
 *
 * Revision 1.302  2003/03/28 15:10:52  rogerh
 * Add 127.0.0.1 to IP addresses which are not translated in NAT mode.
 *
 * Revision 1.301  2003/03/24 23:15:25  robertj
 * Fixed change of variable name
 *
 * Revision 1.300  2003/03/21 04:21:30  robertj
 * Fixed missing set of colour format in video output device.
 *
 * Revision 1.299  2003/03/20 23:49:14  dereks
 * Improve formatting.
 *
 * Revision 1.298  2003/03/17 10:07:20  robertj
 * Removed openh323 versions of videoio.h classes as PVideoOutputDevice
 *   descendants for NULL and PPM files added to PWLib.
 * Moved window PVideoOutputDevice descendant to PWlib.
 *
 * Revision 1.297  2003/03/12 23:14:49  rogerh
 * Changes to Mac OS X scheduling.
 * Move Speex mode 2 codec to the end of the list (as it is poor quality).
 * Changes to console to ignore new lines.
 *
 * Revision 1.296  2003/03/05 20:29:21  rogerh
 * Enable realtime priority on Mac OS X. Submitted by Shawn.
 *
 * Revision 1.295  2003/02/28 08:48:44  rogerh
 * Change the few instances of cerr to cout. This helps Shawn's Mac OS X
 * XMeeting application (Approved by Robert).
 *
 * Revision 1.294  2003/02/25 03:49:09  dereks
 * Fix spelling error.
 *
 * Revision 1.293  2003/02/18 03:58:55  dereks
 * IEEE1394 AVC patch from Georgi Georgiev. Thanks!
 *
 * Revision 1.292  2003/01/11 05:35:43  robertj
 * Added support for IEEE 1394 AV/C cameras, thanks Georgi Georgiev
 *
 * Revision 1.291  2003/01/06 21:23:54  rogerh
 * Add NetBSD changes
 * Submitted by Andreas Wrede (taken in part from NetBSD's package system)
 *
 * Revision 1.290  2002/12/16 09:27:38  robertj
 * Added new video bit rate control, thanks Walter H. Whitlock
 *
 * Revision 1.289  2002/11/13 10:18:03  rogerh
 * Speex is included by default. So remove the HAS_SPEEX test.
 *
 * Revision 1.288  2002/11/10 08:12:42  robertj
 * Moved constants for "well known" ports to better place (OPAL change).
 *
 * Revision 1.287  2002/11/05 04:54:48  robertj
 * Fixed test for jitter buffer size adjustment
 *
 * Revision 1.286  2002/10/31 00:54:13  robertj
 * Enhanced jitter buffer system so operates dynamically between minimum and
 *   maximum values. Altered API to assure app writers note the change!
 *
 * Revision 1.285  2002/10/25 01:58:21  dereks
 * Tidy up capability setting for Cu30
 *
 * Revision 1.284  2002/10/23 17:55:01  rogerh
 * Check for all RFC1918 private IP addresses in the NAT transslation code
 *
 * Revision 1.283  2002/10/15 10:46:43  rogerh
 * Add tweak by Sahai to support operation behind a NAT that forwards ports.
 * This uses TranslateTCPAddress to change the address reported to connections
 * that occur from outside the 192.x.x.x subnet. Copied from OpenMCU.
 *
 * Revision 1.282  2002/09/16 23:43:37  robertj
 * Fixed typo in setting user input capabilities, thanks Simon Heron
 *
 * Revision 1.281  2002/08/29 00:22:27  craigs
 * Fixed cut and past error PR#78, thanks to zbyszek@mazurkiewicz.org
 *
 * Revision 1.280  2002/08/15 02:30:39  craigs
 * Added G726 codec capabilities
 *
 * Revision 1.279  2002/08/14 04:24:16  craigs
 * Added Speex codecs
 *
 * Revision 1.278  2002/08/07 00:46:42  dereks
 * Report statistics for video RTP packets. (No output if no video session)
 *
 * Revision 1.277  2002/08/05 01:33:13  robertj
 * Fixed incorrect override of the SetupTransfer() function that stopped the
 *   ability to do H.250 call transfer, thanks Vladimir Toncar
 *
 * Revision 1.276  2002/07/18 03:04:34  robertj
 * Use function interface for port setting.
 *
 * Revision 1.275  2002/07/16 04:53:57  dereks
 * Fix type in setting port ranges.
 *
 * Revision 1.274  2002/07/04 07:57:30  robertj
 * Removed the strange #ifdef which prevented OhPhone from using H.235 RAS.
 *
 * Revision 1.273  2002/05/30 22:50:28  dereks
 * All available video input devices are now reported in the trace file, level 1.
 *
 * Revision 1.272  2002/05/26 23:28:38  rogerh
 * Fix videobitrate comment.
 *
 * Revision 1.271  2002/05/20 08:49:30  rogerh
 * Add note that for NetMeeting use --videotxquality 4
 *
 * Revision 1.270  2002/05/06 02:55:47  dereks
 * Fix operation of --autodisconnect n , so works when video enabled.
 *
 * Revision 1.269  2002/05/03 05:39:31  robertj
 * Added Q.931 Keypad IE mechanism for user indications (DTMF).
 *
 * Revision 1.268  2002/04/26 03:33:32  dereks
 * Major upgrade. All calls to SDL library are now done by one thread.
 *
 * Revision 1.267  2002/04/18 07:46:28  craigs
 * Added new functions to remove H245 in SETUP, and to allow removal of
 * user input indication capabilities
 *
 * Revision 1.266  2002/04/05 01:39:56  dereks
 * Format change of output from TestVideoGrabber routine.
 *
 * Revision 1.265  2002/04/05 00:55:02  dereks
 * Modify TestVideoGrabber so it displays the raw image, and the decoded
 * form of the encoded raw image. Thanks to Walter Whitlock - good work.
 *
 * Revision 1.264  2002/04/01 18:40:30  robertj
 * Fixed MSVC warnings.
 *
 * Revision 1.263  2002/03/27 06:17:28  robertj
 * Added ability to set base of dynamic TCP/UDP ports, thanks Mark Cooke.
 *
 * Revision 1.262  2002/03/14 07:07:58  robertj
 * Fixed missing new line if call time not printed.
 *
 * Revision 1.261  2002/03/05 05:44:48  robertj
 * Fixed lincorrect message on bandwidth, thanks Ryutaroh Matsumoto
 *
 * Revision 1.260  2002/02/27 14:28:45  rogerh
 * Fix typo in error report. Thanks to Andreas Wrede <awrede@mac.com>
 *
 * Revision 1.259  2002/02/25 08:05:32  robertj
 * Changed to utilise preferred colour format, thanks Martijn Roest
 *
 * Revision 1.258  2002/02/21 01:26:38  dereks
 * With --videotest,  there is now no need to select --videotransmit
 *
 * Revision 1.257  2002/02/20 02:41:26  dereks
 * Remove a PTRACE statement, as it is not needed.
 *
 * Revision 1.256  2002/02/20 02:39:37  dereks
 * Initial release of Firewire camera support for linux.
 * Many thanks to Ryutaroh Matsumoto <ryutaroh@rmatsumoto.org>.
 *
 * Revision 1.255  2002/02/14 22:36:30  robertj
 * Added display of user input send mode.
 *
 * Revision 1.254  2002/01/28 10:43:57  rogerh
 * Wrap some code with HAS_LIDDEVICE so it compiles on systems without
 * IxJ and VPBlaster
 *
 * Revision 1.253  2002/01/26 00:13:40  robertj
 * Fixed MSVC warning
 *
 * Revision 1.252  2002/01/24 13:19:08  rogerh
 * Gnomemeeting is using UserInputStrings to send text messages between users.
 * Strings are sent with a "MSG" header to identify them. Add 'M' menu
 * option to send text message. Received messages are displayed on screen.
 *
 * Revision 1.251  2002/01/24 07:42:37  robertj
 * Added ability to turn off H.245 negotiations in SETUP option
 *
 * Revision 1.250  2002/01/23 14:18:31  rogerh
 * Allow * and # user input indications from the menu
 *
 * Revision 1.249  2002/01/20 23:41:34  craigs
 * Fix crash if UserInputIndication received when not using LID device
 *
 * Revision 1.248  2002/01/18 03:05:59  robertj
 * Added ability to set the mode for sending user input (DTMF)
 *
 * Revision 1.247  2002/01/16 00:47:49  craigs
 * Changed to remove PCM-based capabilities when device cannot do PCM
 *
 * Revision 1.246  2002/01/15 05:50:07  craigs
 * Added support for VoIPBlaster
 *
 * Revision 1.245  2002/01/14 04:43:00  robertj
 * Added preferred colour format selection, thanks Walter Whitlock (really!)
 *
 * Revision 1.244  2002/01/14 03:21:12  robertj
 * Added ability to set capture caolour format, thanks Walter Whitlock
 *
 * Revision 1.243  2002/01/11 03:09:31  robertj
 * Fixed display of call duration, now only "charged" part of call (from the
 *    CONNECT pdu) and does not include ringing time.
 *
 * Revision 1.242  2002/01/04 04:17:52  dereks
 * Add code from Walter Whitlock to flip video, and improve the
 * --videotest mode, which displays local video (without a call).  Many thanks.
 *
 * Revision 1.241  2001/12/04 03:03:51  dereks
 * Copy command line to log file.
 *
 * Revision 1.240  2001/11/28 22:55:32  robertj
 * Fixed setting of silence detect from command line parameter.
 *
 * Revision 1.239  2001/11/28 00:11:31  dereks
 * Update to cope with revised video frame rate code
 * Additional debug information when run in --videotest mode.
 *
 * Revision 1.238  2001/10/27 07:04:46  rogerh
 * Fix a bug which prevented ohphone exiting after a call in --disable-menu
 * mode and which prevented autorepeat mode from working.
 *
 * Revision 1.237  2001/10/23 02:40:46  dereks
 * Fix bracket problem in Cu30 release of code.
 *
 * Revision 1.236  2001/10/23 02:21:39  dereks
 * Initial release CU30 video codec.
 * Add --videotest option, to display raw video, but not invoke a call.
 *
 * Revision 1.235  2001/09/25 03:18:09  dereks
 * Add code from Tiziano Morganti to set bitrate for H261 video codec.
 * Use --videobitrate n         Thanks for your code - good work!!
 *
 * Revision 1.234  2001/09/14 06:02:40  robertj
 * Added ability for number that does not match a speed dial to be passed
 *   to the gatekeeper for processing, thanks Chih-Wei Huang
 *
 * Revision 1.233  2001/08/24 13:57:37  rogerh
 * Delete the listener if StartListener() fails.
 *
 * Revision 1.232  2001/08/22 01:30:21  robertj
 * Resolved confusion with YUV411P and YUV420P video formats, thanks Mark Cooke.
 *
 * Revision 1.231  2001/08/10 10:06:10  robertj
 * No longer need SSL to have H.235 security.
 *
 * Revision 1.230  2001/08/08 05:09:09  dereks
 * Add test for presence/absence of SDL if the --videoreceive sdl option is used.
 * Thanks for the suggestion Greg Hosler
 * Break up the creation of the video grabber into individual components.
 * Add PTRACE commands to report on failures.
 *
 * Revision 1.229  2001/08/07 05:02:58  robertj
 * Added command line argument for H.235 gatekeeper password.
 *
 * Revision 1.228  2001/07/12 06:25:08  rogerh
 * create seperate variables for ulaw and alaw codecs
 *
 * Revision 1.227  2001/07/06 01:50:10  robertj
 * Changed memory check code to be conditionally compiled by
 *   PMEMORY_CHECK and not just _DEBUG.
 *
 * Revision 1.226  2001/05/17 07:11:29  robertj
 * Added more call end types for common transport failure modes.
 *
 * Revision 1.225  2001/05/10 23:47:45  robertj
 * Added trim to transfer command so can have leading spaces.
 *
 * Revision 1.224  2001/05/09 04:59:02  robertj
 * Bug fixes in H.450.2, thanks Klein Stefan.
 *
 * Revision 1.223  2001/05/09 04:07:53  robertj
 * Added more call end codes for busy and congested.
 *
 * Revision 1.222  2001/05/02 16:30:35  rogerh
 * Tidy up comments
 *
 * Revision 1.221  2001/05/01 17:07:32  rogerh
 * Allow CIF images to be transmitted by ordering the capabilities correctly
 * The previous re-ordering code did not work as the codec names had changed
 *
 * Revision 1.220  2001/05/01 05:00:38  robertj
 * Added command to do H.450.x call transfer and hold functions.
 *
 * Revision 1.219  2001/03/20 23:42:55  robertj
 * Used the new PTrace::Initialise function for starting trace code.
 *
 * Revision 1.218  2001/03/12 03:52:09  dereks
 * Tidy up fake video user interface. use --videodevice fake now.
 *
 * Revision 1.217  2001/03/08 23:53:26  robertj
 * Changed the fake video test pattern numbers from -1, -2, -3 to 0, 1 & 2 due
 *   to -1 now being a default channel value for all video devices.
 *
 * Revision 1.216  2001/03/07 01:47:45  dereks
 * Initial release of SDL (Simple DirectMedia Layer, a cross-platform multimedia library),
 * a video library code.
 *
 * Revision 1.215  2001/03/03 05:59:16  robertj
 * Major upgrade of video conversion and grabbing classes.
 *
 * Revision 1.214  2001/02/23 00:34:44  robertj
 * Added ability to add/display non-standard data in setup PDU.
 *
 * Revision 1.213  2001/02/06 07:44:20  robertj
 * Removed ACM codecs.
 *
 * Revision 1.212  2001/01/25 07:16:28  robertj
 * Fixed spurious memory leak. It is OK for the trace file to never be deleted.
 *
 * Revision 1.211  2001/01/24 06:25:46  robertj
 * Altered volume control range to be percentage, ie 100 is max volume.
 *
 * Revision 1.210  2001/01/18 12:24:19  rogerh
 * Fix bug which prevented lookback being selected on OSs without IXJ (eg BSD)
 *
 * Revision 1.209  2001/01/16 13:52:19  rogerh
 * Fix bug when reordering or deleting codecs. Found by "gnome" <gnome@21cn.com>
 *
 * Revision 1.208  2001/01/09 02:09:11  craigs
 * Added extra logging
 * Fixed problem with autodisconnect mode
 *
 * Revision 1.207  2001/01/05 14:55:53  rogerh
 * remove a warning from non ixj systems
 *
 * Revision 1.206  2000/12/19 22:35:53  dereks
 * Install revised video handling code, so that a video channel is used.
 * Code now better handles the situation where the video grabber could not be opened.
 *
 * Revision 1.205  2000/12/16 21:54:31  eokerson
 * Added DTMF generation when User Input Indication received.
 *
 * Revision 1.204  2000/11/13 22:31:38  craigs
 * Fixed per connection options
 *
 * Revision 1.203  2000/11/10 04:09:43  craigs
 * Changed to display AEC settings as text
 * Fixed improved CIDCW support
 * Removed misleading G728 defines
 *
 * Revision 1.202  2000/11/06 02:10:50  eokerson
 * Added support for AGC on IXJ devices.
 *
 * Revision 1.201  2000/10/26 21:29:20  dereks
 * Add --gsmframes parameter, for setting the number of gsmframes in one ethernet packet.
 * Default value is 4. Lower audio latency can be achieved with a value of 1
 *
 * Revision 1.200  2000/10/22 20:27:39  rogerh
 * Add more HAVE_IXJ #ifdefs to make code build on non-linux systems (eg FreeBSD)
 * Submittd by Blaz Zupan <blaz@amis.net>
 *
 * Revision 1.199  2000/10/16 08:50:12  robertj
 * Added single function to add all UserInput capability types.
 *
 * Revision 1.198  2000/10/13 01:47:59  dereks
 * Include command line option for setting the number of transmitted video
 * frames per second.   use --videotxfps n  (default n is 10)
 *
 * Revision 1.197  2000/09/29 00:07:38  craigs
 * Added G711 frame size options
 *
 * Revision 1.196  2000/09/27 03:06:13  dereks
 * Added lots of PTRACE statements to xlib code.
 * Removed X videoMutex from main.cxx & main.h
 * Removed some weird display issues from X code.
 *
 * Revision 1.195  2000/09/24 23:30:18  craigs
 * Removed debugging messages
 *
 * Revision 1.194  2000/09/23 07:20:49  robertj
 * Fixed problem with being able to distinguish between sw and hw codecs in LID channel.
 *
 * Revision 1.193  2000/09/22 01:35:55  robertj
 * Added support for handling LID's that only do symmetric codecs.
 *
 * Revision 1.192  2000/09/22 01:30:14  robertj
 * MSVC compatibility.
 *
 * Revision 1.191  2000/09/22 00:30:52  craigs
 * Enhanced autoDisconnect and autoRepeat functions
 *
 * Revision 1.190  2000/09/21 00:42:50  craigs
 * Changed play volume on sound cards to use PCM mixer channel
 *
 * Revision 1.189  2000/09/20 21:27:01  craigs
 * Fixed problem with default connection options
 *
 * Revision 1.188  2000/09/13 23:58:11  dereks
 * Corrected bug in video display. Now correctly handles 8, 16, 32 bit colour
 * Correctly handles 8 bit grayscale.
 *
 * Revision 1.187  2000/09/08 06:50:06  craigs
 * Added ability to set per-speed dial options
 * Fixed problem with transmit-only endpoints
 *
 * Revision 1.186  2000/09/01 02:13:08  robertj
 * Added ability to select a gatekeeper on LAN via it's identifier name.
 *
 * Revision 1.185  2000/08/30 23:43:27  robertj
 * Added -C option to set IXJ country code.
 * Added -c option for caller id, was documented in help but only had long version.
 *
 * Revision 1.184  2000/08/30 23:21:20  robertj
 * Fixed MSVC warnings.
 *
 * Revision 1.183  2000/08/30 05:14:49  craigs
 * Really fixed problem with setting quicknet volumes on startup
 *
 * Revision 1.182  2000/08/30 04:55:11  craigs
 * Added ability to bind to discrete interfaces
 * Fixed problem with initial audio settings
 *
 * Revision 1.181  2000/08/30 04:16:50  robertj
 * Fixed MSVC warning.
 *
 * Revision 1.180  2000/08/30 01:52:53  craigs
 * New IXJ volume code with pseudo-log scaling
 *
 * history deleted
 *
 * Revision 1.1  1998/12/14 09:13:19  robertj
 * Initial revision
 *
 */

#include <ptlib.h>
#include <ptclib/random.h>

#include "main.h"
#include "gsmcodec.h"
#include "lpc10codec.h"
#include "mscodecs.h"
#include <speexcodec.h>
#include "h261codec.h"
#include "h263codec.h"
#include "ffh263codec.h"
#include "h323pdu.h"
#include "g726codec.h"
//#include "h323t120.h"
//#include "t120proto.h"

#ifdef DEPRECATED_CU30
#include "cu30codec.h"
#endif


#ifdef P_LINUX
#include "vidlinux.h"
#include <sys/resource.h>
#endif

#define FICTITOUS_VIDEO "fake"

#if defined(P_FREEBSD) || defined(P_OPENBSD) || defined(P_NETBSD)
#define  DEFAULT_VIDEO  "/dev/bktr0"
#endif

#ifndef DEFAULT_VIDEO
#define  DEFAULT_VIDEO  "/dev/video0"
#endif

#ifdef HAS_X11
#include "xlibvid.h"
#endif

#ifdef P_SDL
#include <ptclib/vsdl.h>
#endif

#ifdef USE_SHM_VIDEO_DEVICES
#include "shmvideo.h"
#endif

#ifdef HAS_OSS
#define  DEFAULT_MIXER  "/dev/mixer"
#ifdef P_LINUX
#include  <linux/soundcard.h>
#endif

#ifdef P_FREEBSD
#if P_FREEBSD >= 500000
#include <sys/soundcard.h>
#else
#include <machine/soundcard.h>
#endif
#endif

#if defined(P_OPENBSD) || defined(P_NETBSD)
#include <soundcard.h>
#endif

#endif // HAS OSS

// uncomment below if to include xJack G729 code
#ifdef _WIN32
#define  G729
#endif

#ifdef HAS_LIDDEVICE
static const char * AECLevelNames[] = { "Off", "Low", "Medium", "High", "Auto AEC", "Auto AEC/AGC" };
#endif

#include "version.h"

PCREATE_PROCESS(OhPhone);

#define  DEFAULT_TIMEOUT  60000
#define  LAST_CALL_COUNT  16
#define POTS_LINE       0

class RingThread : public PThread
{
  PCLASSINFO(RingThread, PThread);

  public:
    RingThread(MyH323EndPoint & ep)
      : PThread(1000, NoAutoDeleteThread),
        endpoint(ep)
      { Resume(); }

    void Main()
      { endpoint.HandleRinging(); }

  protected:
    MyH323EndPoint & endpoint;
};

#define new PNEW


///////////////////////////////////////////////////////////////

OhPhone::OhPhone()
  : PProcess("Open H323 Project", "OhPhone",
             MAJOR_VERSION, MINOR_VERSION, BUILD_TYPE, BUILD_NUMBER)
{
}


OhPhone::~OhPhone()
{
}


void OhPhone::Main()
{
  //PArgList & args = GetArguments();
  PConfigArgs args(GetArguments());

  args.Parse(
             "a-auto-answer."        "-no-auto-answer."
             "b-bandwidth:"          "-no-bandwidth."
             "B-forward-busy:"       "-no-forward-busy."
#ifdef HAS_LIDDEVICE
             "c-callerid."           "-no-callerid."
             "C-country:"            "-no-country."
#endif
             "d-autodial:"           "-no-autodial."
             "D-disable:"
             "e-silence."            "-no-silence."
             "f-fast-disable."       "-no-fast-disable."
             "F-forward-always:"     "-no-forward-always."
             "g-gatekeeper:"
             "G-gatekeeper-id:"
             "h-help."
             "I-input-mode:"
             "i-interface:"          "-no-interface."
             "j-jitter:"             "-no-jitter."
             "l-listen."
             "n-no-gatekeeper."
             "N-forward-no-answer:"  "-no-forward-no-answer."
             "-answer-timeout:"      "-no-answer-timeout."
#if PTRACING
             "o-output:"             "-no-output."
#endif
             "p-proxy:"              "-no-proxy."
             "-password:"            "-no-password."
             "-listenport:"          "-no-listenport."
             "-connectport:"         "-no-connectport."
             "-connectring:"         "-no-connectring."
             "-port:"                "-no-port."
             "P-prefer:"
#ifdef HAS_IXJ
             "q-quicknet:"           "-no-quicknet."
#endif
#ifdef HAS_VBLASTER
             "V-voipblaster:"        "-no-voipblaster."
#endif
             "r-require-gatekeeper." "-no-require-gatekeeper."
	     "S-disable-h245-in-setup." "-no-disable-h245-in-setup."
             "-save."
             "-setup-param:"         "-no-setup-param."
             "s-sound:"              "-no-sound."
             "-sound-in:"            "-no-sound-in."
             "-sound-out:"           "-no-sound-out."
             "-sound-buffers:"       "-no-sound-buffers."

#ifdef HAS_OSS
             "-sound-mixer:"         "-no-sound-mixer."
             "-sound-recchan:"       "-no-sound-recchan."
             "-sound-recvol:"        "-no-sound-recvol."
             "-sound-playvol:"       "-no-sound-playvol."
#endif
#ifdef PMEMORY_CHECK
       "-setallocationbreakpoint:"
#endif
             "T-h245tunneldisable."  "-no-h245tunneldisable."
#if PTRACING
             "t-trace."              "-no-trace."
#endif
             "-tos:"                 "-no-tos."
             "-translate:"
             "u-user:"               "-no-user."
	     "U-userinputcap:"       "-no-user-input-cap."
             "v-verbose:"            "-no-verbose."
             "-disable-menu."        "-no-disable-menu."
#ifdef HAS_IXJ
             "-aec:"                 "-no-aec."
             "-dial-after-hangup."   "-no-dial-after-hangup."
             "-callerid."            "-no-callerid."
             "-calleridcw."          "-no-calleridcw."
             "-autohook."            "-no-autohook."
             "-quicknet-recvol:"     "-no-quicknet-recvol."
             "-quicknet-playvol:"    "-no-quicknet-playvol."
#endif

             "-g728."                "-no-g728."
#ifdef  G729
             "-g729."                "-no-g729."
#endif
             "-gsm."                 "-no-gsm."
             "-gsmframes:"           "-no-gsmframes."
             "-g711-ulaw."           "-no-g711-ulaw."
             "-g711-alaw."           "-no-g711-alaw."
             "-g711frames:"          "-no-g711frames."
             "-g7231."               "-no-g7231."
             "-h261:"                "-no-h261."
             "-playvol:"             "-no-playvol."
             "-recvol:"              "-no-recvol."
             "-ringfile:"
             "-ringdelay:"

             "-videotransmit."       "-no-videotransmit."
             "-videolocal."          "-no-videolocal."
             "-videosize:"           "-no-videosize."
             "-videoformat:"         "-no-videoformat."
             "-videocolorfmt:"       "-no-videocolorfmt."
             "-videoinput:"          "-no-videoinput."
             "-videodevice:"         "-no-videodevice."

             "-videoreceive:"        "-no-videoreceive."
             "-videoquality:"        "-no-videoquality."
             "-videotxquality:"      "-no-videotxquality."
             "-videotxminquality:"   "-no-videotxminquality."
             "-videoidle:"           "-no-videoidle."
             "-videopip."            "-no-videopip."
             "-videofill:"           "-no-videofill."
             "-videotxfps:"          "-no-videotxfps."
             "-videobitrate:"        "-no-videobitrate."
             "-videotest."           "-no-videotest."
	     "-videolose:"           "-no-videolose."
#ifdef DEPRECATED_CU30
             "-videocu30stats:"      "-no-videocu30stats."
             "-videocu30."           "-no-videocu30."
#endif
             "-autodisconnect:"
             "-autorepeat:"

             "-portbase:"
             "-portmax:"

          , FALSE);

#if PMEMORY_CHECK
  if (args.HasOption("setallocationbreakpoint"))
    PMemoryHeap::SetAllocationBreakpoint(args.GetOptionString("setallocationbreakpoint").AsInteger());
#endif


  int verbose = 255;
  if (args.HasOption('v'))
    verbose = args.GetOptionString('v').AsInteger();

  if (verbose >= 3)
    cout << GetName()
         << " Version " << GetVersion(TRUE)
         << " by " << GetManufacturer()
         << " on " << GetOSClass() << ' ' << GetOSName()
         << " (" << GetOSVersion() << '-' << GetOSHardware() << ")\n\n";

#if PTRACING
  PTrace::Initialise(args.GetOptionCount('t'),
                     args.HasOption('o') ? (const char *)args.GetOptionString('o') : NULL,
         PTrace::Blocks | PTrace::Timestamp | PTrace::Thread | PTrace::FileAndLine);
#endif

  if (args.HasOption('h') || (!args.HasOption('l') && args.GetCount() == 0)) {
    cout << "Usage : " << GetName() << " [options] -l\n"
            "      : " << GetName() << " [options] [-p host] hostname/alias\n"
      "\n   where:  hostname/alias = Remote host/alias to call\n"
            "\nOptions:\n"
            "  -a --auto-answer        : Automatically answer incoming calls\n"
            "  -d --autodial host      : Autodial host if phone off hook\n"
            "  -h --help               : Display this help message.\n"
            "  -l --listen             : Only listen for incoming calls\n"
            "  -v --verbose n          : Set amount of information displayed (0=none)\n"
            "  --disable-menu          : Disable internal menu\n"
            "  --ringfile filename     : Set sound file for \"ring\" annunciation\n"
            "  --ringdelay seconds     : Set delay between playing above file\n"
            "  --save                  : Save parameters in configuration file.\n"

            "\nGatekeeper options:\n"
            "  -g --gatekeeper host    : Specify gatekeeper host.\n"
            "  -G --gatekeeper-id name : Specify gatekeeper by ID.\n"
            "  -n --no-gatekeeper      : Disable gatekeeper discovery.\n"
            "  -r --require-gatekeeper : Exit if gatekeeper discovery fails.\n"
            "     --password pwd       : Password for gatekeeper H.235 authentication.\n"
            "  -p --proxy host         : Proxy/Gateway hostname/ip address\n"

            "\nDivert options:\n"
            "  -F --forward-always party    : Forward to remote party.\n"
            "  -B --forward-busy party      : Forward to remote party if busy.\n"
            "  -N --forward-no-answer party : Forward to remote party if no answer.\n"
            "     --answer-timeout time     : Time in seconds till forward on no answer.\n"

            "\nProtocol options:\n"
            "  -i --interface ipaddr   : Select interface to bind to for incoming connections (default is all interfaces)\n"
            "  --listenport            : Port to listen on for incoming connections (default 1720)\n"
            "  --no-listenport         : No listen port\n"
            "  --connectport port      : Port to connect to for outgoing connections (default 1720)\n"
            "  --connectring num       : Distinctive ring number to send to remote - 0 (default) to 7\n"
            "  -b --bandwidth n        : Limit bandwidth usage to (n * 100) bits/second\n"
            "  -f --fast-disable       : Disable fast start\n"
            "  -T --h245tunneldisable  : Disable H245 tunnelling.\n"
            "  -u --user name          : Set local alias name(s) (defaults to login name)\n"
	    "  -S --disable-h245-in-setup Disable H245 in setup\n"
            "  --tos n                 : Set IP Type of Service byte to n\n"
            "  --setup-param string    : Arbitrary data to be put into H.225 Setup PDU\n"
            "  --portbase port         : Base port for H.245 and RTP data\n"
            "  --portmax port          : Maximum port for H.245 and RTP data\n"
            "  --translate ip          : Set external IP address to ip if masQueraded\n"

            "\nAudio options:\n"
            "  -e --silence            : Disable silence detection for GSM and software G.711\n"
            "  -j --jitter [min-]max   : Set minimum (optional) and maximum jitter buffer (in milliseconds).\n"
            "  --recvol n              : Set record volume\n"
            "  --playvol n             : Set play volume\n"

            "\nVideo transmit options:\n"
            "  --videodevice dev       : Select video capture device (default " DEFAULT_VIDEO ")\n"
            "  --videotransmit         : Enable video transmission\n"
            "  --videolocal            : Enable local video window\n"
            "  --videosize size        : Sets size of transmitted video window\n"
            "                             size can be small (default) or large\n"
            "  --videoformat type      : Set capture video format\n"
            "                             can be auto (default) pal or ntsc\n"
            "  --videocolorfmt format  : Set the preferred capture device color format\n"
            "                             can be RGB24, RGB24F, RGB32, ...\n"
            "  --videoinput num        : Select capture video input (default is 0)\n"
            "  --videotxquality n      : Select sent video quality,(def 9). 1(best)<=n<=31\n"
            "  --videotxminquality n   : Select video quality lower limit,(def 1). 1(best)<=n<=31\n"
            "                             A value of 4 works best for NetMeeting\n" 
            "  --videofill n           : Select number of updated background blocks per frame 2(def)<=n<=99\n"
            "  --videotxfps n          : Maximum number of video frames grabbed per sec 2<10(def)<30\n"
            "  --videosendfps n        : Target minimum number of video frames sent per sec 0.001<6(def)<30\n"
            "  --videobitrate n        : Enable bitrate control.   16< n <2048 kbit/s (net bw)\n"
            "\nVideo receive options:\n"
            "  --videoquality n        : Set received video quality hint - 0 <= n <= 31\n"
            "  --videoreceive viddev   : Receive video to following device\n"
            "                          :      null     do nothing\n"
            "                          :      ppm      create sequence of PPM files\n"
#ifdef HAS_VGALIB
            "                          :      svga256  256 colour VGA (Linux only)\n"
            "                          :      svga     full colour VGA (Linux only)\n"
#endif
#ifdef P_SDL
            "                          :      sdl      Use Simple DirectMedia Library\n"
            " --videopip               : Local video is displayed in adjacent smaller window\n"
#endif
#ifdef HAS_X11
            "                          :      x11       automatically pick best X11 mode\n"
            "                          :      x1124     X11 using 24 bit colour\n"
            "                          :      x1116     X11 using 16 bit colour\n"
            "                          :      x118      X11 using 8 bit grey scale\n"
            "  --videopip              : Local video is displayed in corner of received video\n"
#endif // HAS_X11

            "\nVideo options:\n"
            "  --videotest             : Display local video. Exit after 10 seconds. NO h323 call\n"
            "  --videolose             : Delete this percentage of the video rtp packets.- For videotest only. Default 0\n"
#ifdef DEPRECATED_CU30
            "  --videocu30             : Enable Cu30 codec\n"
            "  --videocu30stats n      : Collect stats for n frames, to optimise subsequent calls. (100-10000)\n"
#endif

            "\nSound card options:\n"
            "  -s --sound device       : Select sound card input/output device\n"
            "  --sound-in device       : Select sound card input device (overrides --sound)\n"
            "  --sound-out device      : Select sound card output device (overrides --sound)\n"
            "  --sound-buffers n       : Set sound buffer depth (default=2)\n"

#ifdef HAS_OSS
            "  --sound-mixer device    : Select sound mixer device (default is " DEFAULT_MIXER ")\n"
            "  --sound-recchan device  : Select sound mixer channel (default is mic)\n"
            "  --sound-recvol n        : Set record volume for sound card only (overrides --recvol)\n"
            "  --sound-playvol n       : Set play volume for sound card only (overrides --playvol)\n"
#endif

#ifdef HAS_IXJ
            "\nQuicknet card options:\n"
            "  -q -quicknet dev        : Use device (number or full device name)\n"
            "  -C --country name       : Set the country code for Quicknet device\n"
            "  --aec n                 : Set Audio Echo Cancellation level (0..3)\n"
            "  --autohook              : Don't use hook switch (for PhoneCard)\n"
            "  -c --callerid           : Enable caller id display\n"
            "  --calleridcw            : Enable caller id on call waiting display\n"
            "  --dial-after-hangup     : Present dial tone after remote hang up\n"
            "  --quicknet-recvol n     : Set record volume for Quicknet card only (overrides recvol)\n"
            "  --quicknet-playvol n    : Set play volume for Quicknet card only (overrides playvol)\n"
#endif

#ifdef HAS_VBLASTER
            "\nVoIPBlaster options:\n"
            "  -V --voipblaster num    : Use device number\n"
#endif

            "\nAudio Codec options:\n"
            "  -D --disable codec      : Disable the specified codec (may be used multiple times)\n"
            "  -P --prefer codec       : Prefer the specified codec (may be used multiple times)\n"
            "  --g711frames count      : Set the number G.711 frames in capabilities (default 30)\n"
            "  --gsmframes count       : Set the number GSM frames in capabilities (default 4)\n"

#if defined(HAS_LIDDEVICE)
            "  --g7231                 : Set G.723.1 as preferred codec\n"
#endif
            "  --gsm                   : Set GSM 06.10 as preferred codec (default)\n"
            "  --g711-ulaw             : Set G.711 uLaw as preferred codec\n"
            "  --g711-alaw             : Set G.711 ALaw as preferred codec\n"
            "  --g728                  : Set G.728 as preferred codec\n"
#ifdef  G729
            "  --g729                  : Set G.729 as preferred codec\n"
#endif
            "  --g7231                 : Set G.723.1 as preferred codec\n"
            "  -I --input-mode mode    : Set the mode for sending User Input Indications (DTMF)\n"
            "                             can be string, signal, q931 or rfc2833 (default is string)\n"
            "  -U --user-input-cap mode : Set the mode for User Input Capabilities\n"
            "                             can be string, signal, rfc2833 or none (default is all)\n"

#if PTRACING || PMEMORY_CHECK
            "\nDebug options:\n"
#endif
#if PTRACING
            "  -t --trace              : Enable trace, use multiple times for more detail\n"
            "  -o --output             : File for trace output, default is stderr\n"
#endif
#ifdef PMEMORY_CHECK
      "  --setallocationbreakpoint n : Enable breakpoint on memory allocation n\n"
#endif
            << endl;
    return;
  }

  BOOL hasMenu = !args.HasOption("disable-menu");

  int autoRepeat;
  if (!args.HasOption("autorepeat"))
    autoRepeat = -1;
  else {
    autoRepeat = args.GetOptionString("autorepeat").AsInteger();
    if (autoRepeat < 1) {
      cout << "autorepeat must be >= 1" << endl;
      return;
    }
    hasMenu = FALSE;
  }

  args.Save("save");

  MyH323EndPoint * endpoint = new MyH323EndPoint;
  if (endpoint->Initialise(args, verbose, hasMenu)) {
    if (!args.HasOption("videotest")) {
      if (autoRepeat < 0) {
  if (args.HasOption('l')) {
    if (verbose >= 2)
      cout << "Waiting for incoming calls for \"" << endpoint->GetLocalUserName() << "\"\n";
  } else
    endpoint->MakeOutgoingCall(args[0], args.GetOptionString('p'));
  endpoint->AwaitTermination();
      } else {
  int i;
  endpoint->terminateOnHangup = TRUE;
  for (i = 1; i <= autoRepeat; i++) {
    if (!args.HasOption('l')) {
      cout << "Making automatic call " << i << endl;
      endpoint->MakeOutgoingCall(args[0], args.GetOptionString('p'));
    }
    endpoint->AwaitTermination();

    cout << "Call #" << i;
#ifdef P_LINUX
    struct rusage usage;
    if (getrusage(RUSAGE_SELF, &usage) == 0)
      cout << ": memory = " << usage.ru_ixrss << ", " << usage.ru_idrss;
#endif
    cout << endl;
    if (i == autoRepeat)
      break;
  }
      }
    }else
      endpoint->TestVideoGrabber(args);
  } //initialised OK

  endpoint->WaitForSdlTermination();

  delete endpoint;

  if (verbose >= 3)
    cout << GetName() << " ended." << endl;
}


///////////////////////////////////////////////////////////////


BOOL MyH323EndPoint::Initialise(PConfigArgs & args, int _verbose, BOOL _hasMenu)
{
  PTRACE(3, "H323ep\tInitialise program. Arguments are " << args);

  PINDEX i;

  verbose = _verbose;
  hasMenu = _hasMenu;
  uiState = uiDialtone;

  channelsOpenLimit = 2;   //Guaranteed to have 2 open audio channels.

  localVideoChannel = NULL;

  if (!InitialiseSdl(args))
    return FALSE;

  // get local username
  if (args.HasOption('u')) {
    PStringArray aliases = args.GetOptionString('u').Lines();
    SetLocalUserName(aliases[0]);
    for (i = 1; i < aliases.GetSize(); i++)
      AddAliasName(aliases[i]);
  }

  // Let the user override it
  if (args.HasOption("portbase"))
    SetRtpIpPorts(args.GetOptionString("portbase").AsInteger(),
                  args.GetOptionString("portmax").AsInteger());
  
  if (verbose >= 3)
    cout << "Incoming channel port ranges "
	 << GetRtpIpPortBase() << " to " << GetRtpIpPortMax()<<endl;
  
  // get ports
  WORD port = H323EndPoint::DefaultTcpPort;
  WORD listenPort = port;
  if (!args.GetOptionString("port").IsEmpty())
    port = (WORD)args.GetOptionString("port").AsInteger();


#if 0
  PSoundChannel::writeDebug = TRUE;
  PSoundChannel::readDebug  = TRUE;
  OpalIxJDevice::writeDebug = TRUE;
  OpalIxJDevice::readDebug  = TRUE;
#endif

  defaultCallOptions.minJitter   = GetMinAudioJitterDelay();
  defaultCallOptions.maxJitter   = GetMaxAudioJitterDelay();
  defaultCallOptions.connectPort = port;
  defaultCallOptions.connectRing = 0;

  if (!defaultCallOptions.Initialise(args))
    return FALSE;

  currentCallOptions = defaultCallOptions;

  //////////

  terminateOnHangup    = !args.HasOption('l');
  autoAnswer           = args.HasOption('a');
  alwaysForwardParty   = args.GetOptionString('F');
  busyForwardParty     = args.GetOptionString('B');
  noAnswerForwardParty = args.GetOptionString('N');
  noAnswerTime         = args.GetOptionString("answer-timeout", "30").AsUnsigned();
  dialAfterHangup      = args.HasOption("dial-after-hangup");
  setupParameter       = args.GetOptionString("setup-param");

  noAnswerTimer.SetNotifier(PCREATE_NOTIFIER(OnNoAnswerTimeout));

  if (args.HasOption("tos"))
    SetRtpIpTypeofService(args.GetOptionString("tos").AsUnsigned());

  if (args.HasOption('b')) {
    initialBandwidth = args.GetOptionString('b').AsUnsigned();
    if (initialBandwidth == 0) {
      cout << "Illegal bandwidth specified." << endl;
      return FALSE;
    }
  }

  if (args.HasOption("sound-buffers")) {
    soundChannelBuffers = args.GetOptionString("sound-buffers", "2").AsUnsigned();
    if (soundChannelBuffers < 2 || soundChannelBuffers > 99) {
      cout << "Illegal sound buffers specified." << endl;
      return FALSE;
    }
  }

  if (verbose >= 3) {
    cout << "Local username: " << GetLocalUserName() << "\n"
         << "TerminateOnHangup is " << terminateOnHangup << "\n"
         << "Auto answer is " << autoAnswer << "\n"
         << "DialAfterHangup is " << dialAfterHangup << "\n"
         << defaultCallOptions
         << endl;

  }

  if (args.HasOption("autodial")) {
    autoDial = args.GetOptionString("autodial");
    if (verbose >= 3)
      cout << "Autodial is set to "  << autoDial << "\n";
  }

  if (args.HasOption("h261")) {
    cout << "warning: --h261 option has been replaced by --videoreceive and --videotransmit" << endl;
    videoReceiveDevice = args.GetOptionString("h261");
  } else if (args.HasOption("videoreceive"))
    videoReceiveDevice = args.GetOptionString("videoreceive");

  if (!videoReceiveDevice.IsEmpty()) {
    channelsOpenLimit ++;     //we expect to have another channel open, for video receive.
    if (  !(videoReceiveDevice *= "ppm")
        && !(videoReceiveDevice *= "null")
#ifdef HAS_VGALIB
        && !(videoReceiveDevice *= "svga")
        && !(videoReceiveDevice *= "svga256")
#endif
#ifdef P_SDL
        && !(videoReceiveDevice *= "sdl")
#endif
#ifdef HAS_X11
        && !(videoReceiveDevice *= "x1132")
        && !(videoReceiveDevice *= "x1124")
        && !(videoReceiveDevice *= "x1116")
        && !(videoReceiveDevice *= "x118")
        && !(videoReceiveDevice *= "x11")
        && !(videoReceiveDevice *= "x1132s")
        && !(videoReceiveDevice *= "x1124s")
        && !(videoReceiveDevice *= "x1116s")
        && !(videoReceiveDevice *= "x118s")
        && !(videoReceiveDevice *= "x11s")
#endif
#ifdef USE_SHM_VIDEO_DEVICES
	&& !(videoReceiveDevice *= "shm")
#endif
        ) {
        cout << "Unknown video receive device \"" << videoReceiveDevice << "\"" << endl;
        return FALSE;
    }
  
    if (!args.HasOption("videoquality")) 
      videoQuality = -1;
    else {
      videoQuality = args.GetOptionString("videoquality").AsInteger();
      videoQuality = PMAX(0, PMIN(31, videoQuality));
    }
  }

  videoPIP   = FALSE;
  videoSize = 0; //Default is small.

  autoStartTransmitVideo = args.HasOption("videotransmit") || args.HasOption("videotest");

  if (autoStartTransmitVideo) {
    channelsOpenLimit ++;     //we expect to have another channel open, for video transmit.

    videoDevice = DEFAULT_VIDEO;
    videoFake = FALSE;    
    if (args.HasOption("videodevice")) {      
      videoDevice = args.GetOptionString("videodevice");
      if (videoDevice == FICTITOUS_VIDEO)
        videoFake = TRUE;
    }

    if (args.GetOptionString("videosize") *= "large")
      videoSize = 1;
    if (verbose >= 3)
      cout << "Set video size to be " << (videoSize == 0 ? "small" : "large") << endl;

    videoInput = 0;
    if (args.HasOption("videoinput")) {
      videoInput = args.GetOptionString("videoinput").AsInteger();
      if (videoInput<0) {
        cout << "User interface has changed.\n"
             << "Select fictitous video device with --videodevice "FICTITOUS_VIDEO"\n"
             << "Use videoinput argument of 0, 1, 2, ...\n"
             << "For backwards compatability, negative inputs are currently supported\n";
        videoFake = TRUE;
        videoInput= -1 - videoInput; //-1 ==> 0, -2 ==>1, etc
      }
    }

    videoIsPal = TRUE;
    if (args.HasOption("videoformat"))
      videoIsPal = args.GetOptionString("videoformat") *= "pal";

    if (args.HasOption("videocolorfmt"))
      pfdColourFormat = args.GetOptionString("videocolorfmt");

    videoLocal = args.HasOption("videolocal");
    if (args.HasOption("videopip")) {
       videoPIP   = TRUE;
       videoLocal = TRUE;
    }

    videoTxQuality = 0; // disable setting video quality
    if (args.HasOption("videotxquality"))
      videoTxQuality = args.GetOptionString("videotxquality").AsInteger();

    videoTxMinQuality = 0; // disable setting minimum video quality
    if (args.HasOption("videotxminquality"))
      videoTxMinQuality = args.GetOptionString("videotxminquality").AsInteger();

    videoFill = 2; // default video fill value
    if (args.HasOption("videofill")) {
      videoFill = args.GetOptionString("videofill").AsInteger();
      videoFill = PMAX(2, PMIN(99, videoFill));
    }

    if (args.HasOption("videocu30stats")) {
      videoCu30Stats = args.GetOptionString("videocu30stats").AsInteger();
      videoCu30Stats = PMAX(10, PMIN(10000, videoCu30Stats));
    } else
      videoCu30Stats = 0; // Dont record stats.

    if (args.HasOption("videotxfps")) {
      videoFramesPS = args.GetOptionString("videotxfps").AsInteger();
      videoFramesPS = PMAX(0, PMIN(30,videoFramesPS));
    } else
      videoFramesPS=0; //default value.

    frameTimeMs = 0; //disable setting frameTimeMs.
    if (args.HasOption("videosendfps")) {
      double videoSendFPS;
      videoSendFPS = args.GetOptionString("videosendfps").AsReal();
      if (0.0 < videoSendFPS) {
        frameTimeMs = (unsigned)(1000.0/videoSendFPS);
        frameTimeMs = PMAX(33, PMIN(1000000,frameTimeMs)); // 5 ms to 16.7 minutes
      }
    }

    videoBitRate = 0; //disable setting videoBitRate.
    if (args.HasOption("videobitrate")) {
      videoBitRate = args.GetOptionString("videobitrate").AsInteger();
      videoBitRate = 1024 * PMAX(16, PMIN(2048, videoBitRate));
    }
  }

  if (verbose >= 3) {
    if (videoReceiveDevice.IsEmpty())
      cout << "Video receive disabled" << endl << endl;
    else {
      cout << "Video receive using device : " << videoReceiveDevice << endl;
      cout << "Video receive quality hint : " << videoQuality << endl << endl;
    }
    if (!autoStartTransmitVideo)
      cout << "Video transmit disabled" << endl << endl;
    else {
      cout << "Video transmit enabled with local video window " << (videoLocal ? "en" : "dis") << "abled" << endl;
      cout << "Video transmit size is " << ((videoSize == 1) ? "large" : "small") << endl;
      cout << "Video capture using input " << videoInput << endl;
      cout << "Video capture using format " << (videoIsPal ? "PAL" : "NTSC") << endl;
      cout << "Video picture in picture of local video "<< (videoPIP ? "en" : "dis") << "abled" << endl;
      cout << "Video transmit quality is "<< videoTxQuality<<endl;
      cout << "Video background fill blocks "<< videoFill<<endl;
      cout << "Video transmit frames per sec "<< videoFramesPS<< (videoFramesPS==0 ? " (default) " : "") <<endl;
      cout << "Video bitrate "<<videoBitRate<<" bps" << endl;
    }
#ifdef DEPRECATED_CU30
    if (args.HasOption("videocu30") || args.HasOption("videocu30stats")) {
      cout << "Video codec Cu30 enabled."<<endl;
      cout << "Video Cu30 statitistics " ;
      if (videoCu30Stats>0)
        cout << "enabled. " << videoCu30Stats << " frames." << endl;
      else
  cout << "disabled" << endl;
    }
#endif
    cout << endl;
  }

#ifdef HAS_LIDDEVICE
  isXJack = FALSE;
  lidDevice = NULL;
#endif

#ifdef HAS_VBLASTER
  if (args.HasOption('V')) {
    PString vbDevice = args.GetOptionString('V');
    lidDevice = new OpalVoipBlasterDevice;
    if (lidDevice->Open(vbDevice)) {
      if (verbose >= 3)
        cout << "Using VoIPBlaster " << lidDevice->GetName() << '\n';
    }
    autoHook = FALSE;
  }
#endif

#ifdef HAS_IXJ
  if (args.HasOption('q')) {
    lidDevice = new OpalIxJDevice;
    PString ixjDevice = args.GetOptionString('q');
    if (lidDevice->Open(ixjDevice)) {
      if (verbose >= 3)
        cout << "Using Quicknet " << lidDevice->GetName() << '\n';
      isXJack = TRUE;
      lidDevice->SetLineToLineDirect(0, 1, FALSE);
      lidDevice->EnableAudio(0, TRUE);

      callerIdEnable = args.HasOption("callerid");
      if (verbose >= 3)
        cout << "Caller ID set to " << callerIdEnable << endl;

      callerIdCallWaitingEnable = args.HasOption("calleridcw");
      if (verbose >= 3)
        cout << "Caller ID on call waiting set to " << callerIdCallWaitingEnable << endl;

      if (args.HasOption('C'))
        lidDevice->SetCountryCodeName(args.GetOptionString('C'));
      if (verbose >= 3)
        cout << "Country set to " << lidDevice->GetCountryCodeName() << endl;

      int aec = 0;
      if (args.HasOption("aec")) {
        aec = args.GetOptionString("aec").AsUnsigned();
        lidDevice->SetAEC(0, (OpalLineInterfaceDevice::AECLevels)aec);
        if (verbose >= 3)
          cout << "AEC set to " << AECLevelNames[aec] << endl;
      } else {
        lidDevice->SetAEC(0, OpalLineInterfaceDevice::AECMedium);
        if (verbose >= 3)
          cout << "AEC set to default" << endl;
      }

      PString volStr;

      if ((OpalLineInterfaceDevice::AECLevels)aec != OpalLineInterfaceDevice::AECAGC) {
        if (args.HasOption("quicknet-recvol"))
          volStr = args.GetOptionString("quicknet-recvol");
        else if (args.HasOption("recvol"))
          volStr = args.GetOptionString("recvol");

        unsigned recvol;
        if (!volStr.IsEmpty()) {
          recvol = volStr.AsInteger();
          lidDevice->SetRecordVolume(0, recvol);
        } else {
          lidDevice->GetRecordVolume(0, recvol);
        }
        if (verbose >= 3) {
          cout << "Recording volume set to " << recvol << endl;
        }
      }
      if (args.HasOption("quicknet-playvol"))
        volStr = args.GetOptionString("quicknet-playvol");
      else if (args.HasOption("playvol"))
        volStr = args.GetOptionString("playvol");

      unsigned playvol;
      if (!volStr.IsEmpty()) {
        playvol = volStr.AsInteger();
        lidDevice->SetPlayVolume(0, playvol);
      } else {
        lidDevice->GetPlayVolume(0, playvol);
      }

      if (verbose >= 3) {
        cout << "Playing volume set to " << playvol << endl;
      }

      autoHook = args.HasOption("autohook");
      if (autoHook)
        lidDevice->StopTone(0);
      if (verbose >= 3)
        cout << "Autohook set to " << autoHook << endl;
    }
    else {
      cout << "Could not open " << ixjDevice << ": ";
      int code = lidDevice->GetErrorNumber();
      if (code == EBADF)
        cout << "check that the Quicknet driver is installed correctly" << endl;
      else if (code == EBUSY)
        cout << "check that the Quicknet driver is not in use" << endl;
      else {
        PString errStr = lidDevice->GetErrorText();
        if (errStr.IsEmpty())
          errStr = psprintf("error code %i", code);
        cout << errStr << endl;
      }
      return FALSE;
    }
  }

#endif

  if (args.HasOption("ringfile"))
    ringFile = args.GetOptionString("ringfile");
  if (args.HasOption("ringdelay"))
    ringDelay = args.GetOptionString("ringdelay").AsInteger();
  else
    ringDelay = 5;

#if defined(HAS_LIDDEVICE)
  if ((lidDevice == NULL) || !lidDevice->IsOpen()) {
#endif

    if (!SetSoundDevice(args, "sound", PSoundChannel::Recorder))
      return FALSE;
    if (!SetSoundDevice(args, "sound", PSoundChannel::Player))
      return FALSE;
    if (!SetSoundDevice(args, "sound-in", PSoundChannel::Recorder))
      return FALSE;
    if (!SetSoundDevice(args, "sound-out", PSoundChannel::Player))
      return FALSE;

    if (verbose >= 3)
      cout << "Sound output device: \"" << GetSoundChannelPlayDevice() << "\"\n"
              "Sound  input device: \"" << GetSoundChannelRecordDevice() << "\"\n";

#ifdef HAS_OSS
    if (!InitialiseMixer(args, verbose))
      return FALSE;
#endif

#if defined(HAS_LIDDEVICE)
  } // endif
#endif

  // by default, assume we can do PCM codec
  BOOL canDoPCM = TRUE;

  // The order in which capabilities are added to the capability table
  // determines which one is selected by default.

#if defined(HAS_LIDDEVICE)
  if ((lidDevice != NULL) && lidDevice->IsOpen()) {
    H323_LIDCapability::AddAllCapabilities(*lidDevice, capabilities, 0, 0);
    canDoPCM = lidDevice->GetMediaFormats().GetValuesIndex(OpalMediaFormat(OPAL_PCM16)) != P_MAX_INDEX;
  }
#endif

  if (canDoPCM) {

    int g711Frames = 30;
    if (args.HasOption("g711frames")) {
      g711Frames = args.GetOptionString("g711frames").AsInteger();
      if (g711Frames <= 10 || g711Frames > 240) {
        cout << "error: G.711 frame size must be in range 10 to 240" << endl;
        g711Frames = 30;
      }
    }

    int gsmFrames = 4;
    if (args.HasOption("gsmframes")) {
      gsmFrames = args.GetOptionString("gsmframes").AsInteger();
      if (gsmFrames < 1 || gsmFrames > 7) {
        cout << "error: GSM frame size must be in range 1 to 7" << endl;
        gsmFrames = 4;
      }
    }
    if (verbose >= 3) {
      cout <<"G.711 frame size: " << g711Frames << endl;
      cout <<"GSM frame size: " << gsmFrames << endl;
    }

    H323_GSM0610Capability * gsmCap;
    SetCapability(0, 0, gsmCap = new H323_GSM0610Capability);
    gsmCap->SetTxFramesInPacket(gsmFrames);

    MicrosoftGSMAudioCapability * msGsmCap;
    SetCapability(0, 0, msGsmCap = new MicrosoftGSMAudioCapability);
    msGsmCap->SetTxFramesInPacket(gsmFrames);

    H323_G711Capability * g711uCap;
    SetCapability(0, 0, g711uCap = new H323_G711Capability(H323_G711Capability::muLaw));
    g711uCap->SetTxFramesInPacket(g711Frames);

    H323_G711Capability * g711aCap;
    SetCapability(0, 0, g711aCap = new H323_G711Capability(H323_G711Capability::ALaw));
    g711aCap->SetTxFramesInPacket(g711Frames);

    SetCapability(0, 0, new SpeexNarrow3AudioCapability());
    SetCapability(0, 0, new SpeexNarrow4AudioCapability());
    SetCapability(0, 0, new SpeexNarrow5AudioCapability());
    SetCapability(0, 0, new SpeexNarrow6AudioCapability());
    SetCapability(0, 0, new SpeexNarrow2AudioCapability());

    SetCapability(0, 0, new H323_G726_Capability(*this, H323_G726_Capability::e_16k));
    SetCapability(0, 0, new H323_G726_Capability(*this, H323_G726_Capability::e_24k));
    SetCapability(0, 0, new H323_G726_Capability(*this, H323_G726_Capability::e_32k));
    SetCapability(0, 0, new H323_G726_Capability(*this, H323_G726_Capability::e_40k));

    SetCapability(0, 0, new H323_LPC10Capability(*this));
  }


  //AddCapability puts the codec into the list of codecs we can send
  //SetCapability puts the codec into the list of codecs we can send and receive
#ifdef DEPRECATED_CU30
  PFilePath  fileName= PProcess::Current().GetConfigurationFile();
  PString statsDir = fileName.GetDirectory(); //Statistics files ("y" "u" "v" and "mc") have to be here.
  INT _width,_height;
  _width= 176 << videoSize;
  _height= 144 << videoSize;
  cout<<"SetVideo size to "<<_width<<" x " <<_height<<endl;

  if (args.HasOption("videocu30") || args.HasOption("videocu30stats")) {
    if (!videoReceiveDevice.IsEmpty())      SetCapability(0, 1, new H323_Cu30Capability(*this, statsDir, _width, _height, videoCu30Stats));
    else 
      if (autoStartTransmitVideo)
        AddCapability(new H323_Cu30Capability(*this, statsDir, _width, _height, videoCu30Stats));
  }

#endif

  //Make sure the CIF and QCIF capabilities are in the correct order
#define ADD_VIDEO_CAPAB(a)                                                       \
  if (!videoReceiveDevice.IsEmpty()) {                                           \
    if (videoSize == 1) {                                                         \
      SetCapability(0, 1, new  a(0, 0, 1, 0, 0, videoBitRate, videoFramesPS)); \
      SetCapability(0, 1, new  a(0, 1, 0, 0, 0, videoBitRate, videoFramesPS)); \
    } else {                                                                     \
      SetCapability(0, 1, new  a(0, 1, 0, 0, 0, videoBitRate, videoFramesPS)); \
      SetCapability(0, 1, new  a(0, 0, 1, 0, 0, videoBitRate, videoFramesPS)); \
    }                                                                            \
  } else if (autoStartTransmitVideo) {                                          \
    if (videoSize == 1) {                                                        \
      AddCapability(new  a(0, 0, 1, 0, 0, videoBitRate, videoFramesPS));       \
      AddCapability(new  a(0, 1, 0, 0, 0, videoBitRate, videoFramesPS));       \
    } else {                                                                     \
      AddCapability(new  a(0, 1, 0, 0, 0, videoBitRate, videoFramesPS));       \
      AddCapability(new  a(0, 0, 1, 0, 0, videoBitRate, videoFramesPS));       \
    }                                                                            \
  }                                                                              \

#if H323_AVCODEC
  ADD_VIDEO_CAPAB (H323_FFH263Capability);
#endif
#if H323_VICH263
  ADD_VIDEO_CAPAB (H323_H263Capability);
#endif

  if (!videoReceiveDevice.IsEmpty()) {
    if (videoSize == 1) {
      SetCapability(0, 1, new H323_H261Capability(0, 4, FALSE, FALSE, 6217));
      SetCapability(0, 1, new H323_H261Capability(2, 0, FALSE, FALSE, 6217));
    } else {
      SetCapability(0, 1, new H323_H261Capability(2, 0, FALSE, FALSE, 6217));
      SetCapability(0, 1, new H323_H261Capability(0, 4, FALSE, FALSE, 6217));
    }
  } else if (autoStartTransmitVideo) {
    if (videoSize == 1) {
      AddCapability(new H323_H261Capability(0, 4, FALSE, FALSE, 6217)); //CIF
      AddCapability(new H323_H261Capability(2, 0, FALSE, FALSE, 6217)); //QCIF
    } else { 
      AddCapability(new H323_H261Capability(2, 0, FALSE, FALSE, 6217)); //QCIF
      AddCapability(new H323_H261Capability(0, 4, FALSE, FALSE, 6217)); //CIF
    }
  }

  PStringArray toRemove = args.GetOptionString('D').Lines();
  PStringArray toReorder = args.GetOptionString('P').Lines();

  static const char * const oldArgName[] = {
    "g7231",   "g729",  "g728",  "gsm", "g711-ulaw", "g711-alaw",   "g.726", "speex"
  };
  static const char * const capName[] = {
    "G.723.1", "G.729", "G.728", "GSM", "G.711-uLaw", "G.711-ALaw", "G.726", "Speex"
  };

  for (i = 0; i < PARRAYSIZE(oldArgName); i++) {
    if (args.HasOption(PString("no-")+oldArgName[i]))
      toRemove[toRemove.GetSize()] = capName[i];
    if (args.HasOption(oldArgName[i]))
      toReorder[toReorder.GetSize()] = capName[i];
  }

  capabilities.Remove(toRemove);
  capabilities.Reorder(toReorder);


  PCaselessString uiMode = args.GetOptionString('I');
  if (uiMode == "q931")
    SetSendUserInputMode(H323Connection::SendUserInputAsQ931);
  else if (uiMode == "signal")
    SetSendUserInputMode(H323Connection::SendUserInputAsTone);
  else if (uiMode == "rfc2833")
    SetSendUserInputMode(H323Connection::SendUserInputAsInlineRFC2833);
  else
    SetSendUserInputMode(H323Connection::SendUserInputAsString);

  PCaselessString uiCap = args.GetOptionString('U');
  if (uiCap == "signal") 
    capabilities.SetCapability(0, P_MAX_INDEX, new H323_UserInputCapability(H323_UserInputCapability::SignalToneH245));
  else if (uiCap == "rfc2833")
    capabilities.SetCapability(0, P_MAX_INDEX, new H323_UserInputCapability(H323_UserInputCapability::SignalToneRFC2833));
  else if (uiCap == "string") {
    PINDEX num = capabilities.SetCapability(0, P_MAX_INDEX, new H323_UserInputCapability(H323_UserInputCapability::HookFlashH245));
    capabilities.SetCapability(0, num+1, new H323_UserInputCapability(H323_UserInputCapability::BasicString));
  } else if (uiCap != "none")
    AddAllUserInputCapabilities(0, P_MAX_INDEX);

  if (verbose >= 3) {
    cout << "User Input Send Mode: as ";
    switch (GetSendUserInputMode()) {
    case H323Connection::SendUserInputAsQ931 :
      cout << "Q.931 Keypad Information Element";
      break;
    case H323Connection::SendUserInputAsString :
      cout << "H.245 string";
      break;
    case H323Connection::SendUserInputAsTone :
      cout << "H.245 tone";
      break;
    case H323Connection::SendUserInputAsInlineRFC2833 :
      cout << "RFC2833";
      break;
    default :
      cout << "Unknown!";
    }
    cout << '\n';
  }

  //SetCapability(0, P_MAX_INDEX, new H323_T120Capability);

  if (verbose >= 4)
    cout <<  "Codecs (in preference order):\n" << setprecision(2) << capabilities << endl << endl;


  if (!args.GetOptionString("listenport").IsEmpty())
    listenPort = (WORD)args.GetOptionString("listenport").AsInteger();

  PStringArray interfaceList;
  if (!args.GetOptionString('i').IsEmpty())
    interfaceList = args.GetOptionString('i').Lines();

  PString interfacePrintable;

  // if no interfaces specified, then bind to all interfaces with a single Listener
  // otherwise, bind to specific interfaces
  if (interfaceList.GetSize() == 0) {
    PIPSocket::Address interfaceAddress(INADDR_ANY);
    H323ListenerTCP * listener = new H323ListenerTCP(*this, interfaceAddress, listenPort);
    if (!StartListener(listener)) {
      cout <<  "Could not open H.323 listener port on "
           << listener->GetListenerPort() << endl;
      delete listener;
      return FALSE;
    }
    interfacePrintable = psprintf("ALL:%i", listenPort);
  } else {
    for (i = 0; i < interfaceList.GetSize(); i++) {

      PString interfaceStr = interfaceList[i];
      WORD interfacePort = listenPort;

      // Allow for [ipaddr]:port form, especially for IPv6
      PINDEX pos = interfaceStr.Find(']');
      if (pos == P_MAX_INDEX)
        pos = 0;
      pos = interfaceStr.Find(':', pos);
      if (pos != P_MAX_INDEX) {
        interfacePort = (WORD)interfaceStr.Mid(pos+1).AsInteger();
        interfaceStr = interfaceStr.Left(pos);
      }
      interfacePrintable &= interfaceStr + ":" + PString(PString::Unsigned, interfacePort);
      PIPSocket::Address interfaceAddress(interfaceStr);

      H323ListenerTCP * listener = new H323ListenerTCP(*this, interfaceAddress, interfacePort);
      if (!StartListener(listener)) {
        cout << "Could not open H.323 listener port on "
             << interfaceAddress << ":" << interfacePort << endl;
        delete listener;
        return FALSE;
      }
    }
  }

  if (verbose >= 3)
    cout << "Listening interfaces : " << interfacePrintable << endl;

  if (args.HasOption("translate")) {
    masqAddressPtr = new PIPSocket::Address(args.GetOptionString("translate"));
    behind_masq = TRUE;
    cout << "Masquerading as address " << *(masqAddressPtr) << endl;
  } else {
    behind_masq = FALSE;
  }

  // Initialise the security info
  if (args.HasOption("password")) {
    SetGatekeeperPassword(args.GetOptionString("password"));
    cout << "Enabling H.235 security access to gatekeeper." << endl;
  }

  if (args.HasOption('g')) {
    PString gkName = args.GetOptionString('g');
    H323TransportUDP * rasChannel;
    if (args.GetOptionString('i').IsEmpty())
      rasChannel  = new H323TransportUDP(*this);
    else {
      PIPSocket::Address interfaceAddress(args.GetOptionString('i'));
      rasChannel  = new H323TransportUDP(*this, interfaceAddress);
    }
    if (SetGatekeeper(gkName, rasChannel)) {
      if (verbose >= 3)
        cout << "Gatekeeper set: " << *gatekeeper << endl;
    } else {
      cout << "Error registering with gatekeeper at \"" << gkName << '"' << endl;
      return FALSE;
    }
  }
  else if (args.HasOption('G')) {
    PString gkIdentifier = args.GetOptionString('G');
    if (verbose >= 2)
      cout << "Searching for gatekeeper with id \"" << gkIdentifier << "\" ..." << flush;
    if (LocateGatekeeper(gkIdentifier)) {
      if (verbose >= 3)
        cout << "Gatekeeper set: " << *gatekeeper << endl;
    } else {
      cout << "Error registering with gatekeeper at \"" << gkIdentifier << '"' << endl;
      return FALSE;
    }
  }
  else if (!args.HasOption('n') || args.HasOption('r')) {
    if (verbose >= 2)
      cout << "Searching for gatekeeper..." << flush;
    if (DiscoverGatekeeper(new H323TransportUDP(*this))) {
      if (verbose >= 2)
        cout << "\nGatekeeper found: " << *gatekeeper << endl;
    } else {
      if (verbose >= 2)
        cout << "\nNo gatekeeper found." << endl;
      if (args.HasOption("require-gatekeeper"))
        return FALSE;
    }
  }

  ringThread = NULL;

  if (!args.HasOption("autodisconnect"))
    autoDisconnect = 0;
  else {
    autoDisconnect = args.GetOptionString("autodisconnect").AsInteger();
    if (autoDisconnect < 0) {
      cout << "autodisconnect must be > 0" << endl;
      return FALSE;
    }
  }

  return TRUE;
}


#ifdef HAS_OSS
BOOL MyH323EndPoint::InitialiseMixer(PConfigArgs & args, int _verbose)
{
  mixerDev = -1;

  // make sure mixer isn't disabled
  if (args.HasOption("no-sound-mixer"))
    return TRUE;

  PString mixerDeviceName = DEFAULT_MIXER;
  if (args.HasOption("sound-mixer"))
    mixerDeviceName = args.GetOptionString("sound-mixer");

  mixerDev = ::open(mixerDeviceName, O_RDWR);
  if (mixerDev < 0) {
    cout << "warning: Cannot open mixer device " << mixerDeviceName
         << ": " << ::strerror(errno) << endl;
    return TRUE;
  }

  char * mixerChanNames[] = SOUND_DEVICE_NAMES;
  int numMixerChans = SOUND_MIXER_NRDEVICES;

  // get the current record channel setting, and save it
  if (::ioctl(mixerDev, SOUND_MIXER_READ_RECSRC, &savedMixerRecChan) < 0) {
    cout << "warning: cannot get current mixer record channels" << endl;
    savedMixerRecChan = -1;
  }

  // if the user specified a record channel, then find it
  // otherwise, find the currently select record channel
  if (args.HasOption("sound-recchan")) {
    PCaselessString mixerRecChanName = args.GetOptionString("sound-recchan");
    int i;
    for (i = 0; i < numMixerChans; i++)
      if (mixerRecChanName *= mixerChanNames[i])
        break;
    if (i == numMixerChans) {
      cout << "error: Cannot find record mixer channel " << mixerDeviceName << endl;
      return FALSE;
    }
    mixerRecChan = i;
  } else {
    int i;
    for (i = 0; i < numMixerChans; i++)
      if (savedMixerRecChan & (1 << i))
        break;
    if (i == numMixerChans)
      mixerRecChan = SOUND_MIXER_MIC;
    else
      mixerRecChan = i;
  }

  PString volStr;
  if (args.HasOption("sound-recvol"))
    volStr = args.GetOptionString("sound-recvol");
  else if (args.HasOption("recvol"))
    volStr = args.GetOptionString("recvol");

  if (volStr.IsEmpty()) {
    ::ioctl(mixerDev, MIXER_READ(mixerRecChan), &ossRecVol);
    ossRecVol &= 0xff;
  } else {
    ossRecVol = (unsigned)volStr.AsReal();
    int volVal = ossRecVol | (ossRecVol << 8);
    ::ioctl(mixerDev, MIXER_WRITE(mixerRecChan), &volVal);
  }

  if (args.HasOption("sound-playvol"))
    volStr = args.GetOptionString("sound-playvol");
  else if (args.HasOption("playvol"))
    volStr = args.GetOptionString("playvol");

  if (volStr.IsEmpty()) {
    ::ioctl(mixerDev, SOUND_MIXER_READ_VOLUME, &ossPlayVol);
    ossPlayVol &= 0xff;
  } else {
    ossPlayVol = (unsigned)volStr.AsReal();
    int volVal = ossPlayVol | (ossPlayVol << 8);
    ::ioctl(mixerDev, SOUND_MIXER_WRITE_PCM, &volVal);
  }

  if (verbose >= 3) {
    cout << "Recording using mixer channel " << mixerChanNames[mixerRecChan] << endl;
    cout << "Record volume is " << ossRecVol << endl;
    cout << "Play volume is " << ossPlayVol << endl;
  }

  return TRUE;
}
#endif


BOOL MyH323EndPoint::SetSoundDevice(PConfigArgs & args,
                                    const char * optionName,
                                    PSoundChannel::Directions dir)
{
  if (!args.HasOption(optionName))
    return TRUE;

  PString dev = args.GetOptionString(optionName);

  if (dir == PSoundChannel::Player) {
    if (SetSoundChannelPlayDevice(dev))
      return TRUE;
  }
  else {
    if (SetSoundChannelRecordDevice(dev))
      return TRUE;
  }

  cout << "Device for " << optionName << " (\"" << dev << "\") must be one of:\n";

  PStringArray names = PSoundChannel::GetDeviceNames(dir);
  for (PINDEX i = 0; i < names.GetSize(); i++)
    cout << "  \"" << names[i] << "\"\n";

  return FALSE;
}


H323Connection * MyH323EndPoint::CreateConnection(unsigned callReference)
{
  unsigned options = 0;

  if (currentCallOptions.noFastStart)
    options |= H323Connection::FastStartOptionDisable;

  if (currentCallOptions.noH245Tunnelling)
    options |= H323Connection::H245TunnelingOptionDisable;

  if (currentCallOptions.noH245InSetup)
    options |= H323Connection::H245inSetupOptionDisable;

  return new MyH323Connection(*this, callReference,
                              options,
                              currentCallOptions.minJitter,
                              currentCallOptions.maxJitter,
                              verbose);
}


BOOL MyH323EndPoint::OnIncomingCall(H323Connection & connection,
                                    const H323SignalPDU & setupPDU,
                                    H323SignalPDU &)
{
  // get the default call options
  currentCallOptions = defaultCallOptions;

  // get remote address so we can call back later
  PString lastCallingParty = connection.GetSignallingChannel()->GetRemoteAddress().GetHostName();

  PConfig config("Callers");
  int index = config.GetInteger("index");
  PString lastLastCallingParty = config.GetString(PString(PString::Unsigned, index));
  index = (index + 1) % LAST_CALL_COUNT;
  PTime now;
  PString indexStr = PString(PString::Unsigned, index);
  config.SetString(indexStr,           lastCallingParty);
  config.SetString(indexStr + "_Time", now.AsString());
  config.SetString("index",            indexStr);

  // Check for setup parameter
  if (setupPDU.m_h323_uu_pdu.HasOptionalField(H225_H323_UU_PDU::e_nonStandardData)) {
    PString param = setupPDU.m_h323_uu_pdu.m_nonStandardData.m_data.AsString();
    if (!param)
      cout << "Received non-standard parameter data in Setup PDU: \"" << param << "\"." << endl;
  }


  if (!alwaysForwardParty.IsEmpty()) {
    cout << "Forwarding call to \"" << alwaysForwardParty << "\"." << endl;
    return !connection.ForwardCall(alwaysForwardParty);
  }

  // incoming call is accepted if no call in progress
  // unless the xJack is open and phone is off onhook

  if (!currentCallToken.IsEmpty())
    cout << "WARNING: current call token not empty" << endl;

  if (currentCallToken.IsEmpty()
#if defined(HAS_LIDDEVICE)
        && !((lidDevice != NULL) && lidDevice->IsOpen() && (!autoHook && lidDevice->IsLineOffHook(POTS_LINE)))
#endif
  ) {
    // get the current call token
    currentCallToken = connection.GetCallToken();
    return TRUE;
  }

  if (busyForwardParty.IsEmpty()) {
    PTime now;
    cout << "Incoming call from \"" << connection.GetRemotePartyName() << "\" rejected at " << now << ", line busy!" << endl;
    connection.ClearCall(H323Connection::EndedByLocalBusy);
#ifdef HAS_LIDDEVICE
    if (isXJack) {
#ifdef IXJCTL_VMWI
      if (callerIdCallWaitingEnable) {
        PString callerId = ((MyH323Connection &)connection).GetCallerIdString();
        cout << "Sending caller on call waiting ID " << callerId << endl;
        lidDevice->SendCallerIDOnCallWaiting(OpalIxJDevice::POTSLine, callerId);
      }
#endif
    }
#endif
    return FALSE;
  }

  cout << "Forwarding call to \"" << busyForwardParty << "\"." << endl;
  return !connection.ForwardCall(busyForwardParty);
}


void MyH323EndPoint::TranslateTCPAddress(PIPSocket::Address &localAddr, const PIPSocket::Address &remoteAddr)
{

  if (this->behind_masq) {
    /* Check if the remote address is a private IP address.
     * RFC 1918 specifies the following private IP addresses
     * 10.0.0.0    - 10.255.255.255.255
     * 172.16.0.0  - 172.31.255.255
     * 192.168.0.0 - 192.168.255.255
     */

     BOOL remote_address_private =
       ( ((remoteAddr.Byte1() == 10))
       ||((remoteAddr.Byte1() == 172) 
           && (remoteAddr.Byte2() >= 16)
           && (remoteAddr.Byte2() <= 31) )
       ||((remoteAddr.Byte1() == 192) 
           && (remoteAddr.Byte2() == 168))
       ||((remoteAddr.Byte1() == 127)
           && (remoteAddr.Byte2() == 0)
           && (remoteAddr.Byte3() == 0)
           && (remoteAddr.Byte4() == 1))  );
     /*
      * If the remote address is outside our LAN, replace the local address
      * with the IP address of the NAT box.
      */
     if (!remote_address_private) { 
       localAddr = *(this->masqAddressPtr);
     }
  }
  return;
}


BOOL MyH323EndPoint::OnConnectionForwarded(H323Connection & /*connection*/,
                                           const PString & forwardParty,
                                           const H323SignalPDU & /*pdu*/)
{
  if (MakeCall(forwardParty, currentCallToken)) {
    cout << GetLocalUserName() << " is being forwarded to host " << forwardParty << endl;
    return TRUE;
  }

  cout << "Error forwarding call to \"" << forwardParty << '"' << endl;
  return FALSE;
}


void MyH323EndPoint::OnNoAnswerTimeout(PTimer &, INT)
{
  H323Connection * connection = FindConnectionWithLock(currentCallToken);
  if (connection != NULL) {
    cout << "Forwarding call to \"" << noAnswerForwardParty << "\"." << endl;
    connection->ForwardCall(noAnswerForwardParty);
    connection->Unlock();
  }
}

void MyH323EndPoint::OnConnectionEstablished(H323Connection & connection,
                                             const PString & /*token*/)
{
  cout << "Call with \"" << connection.GetRemotePartyName() << "\" established." << endl;
  uiState = uiCallInProgress;
}

void MyH323EndPoint::OnAutoDisconnect(PTimer &, INT)
{
  PTRACE(3, "main\tOnAutoDisconnect callback. Call=" << currentCallToken);
  if (currentCallToken.IsEmpty())
    cout << "Autodisconnect occurred without current call token" << endl;
  else {
    ClearCall(currentCallToken);
    cout << "Autodisconnect triggered" << endl;
  }
}

void MyH323EndPoint::TriggerDisconnect()
{
  // we have an autodisconnect timer specified, start the timer
  if (autoDisconnect <= 0)
    PTRACE(2, "Main\tAuto disconnect not triggered");
  else {
    PTRACE(2, "Main\tAuto disconnect triggered");
    autoDisconnectTimer.SetNotifier(PCREATE_NOTIFIER(OnAutoDisconnect));
    autoDisconnectTimer = PTimeInterval(autoDisconnect * 100);
  }
}


void MyH323EndPoint::OnConnectionCleared(H323Connection & connection, const PString & clearedCallToken)
{
  // stop any ringing that is occurring
  StopRinging();

  // ignore connections that are not the current connection
  if (clearedCallToken != currentCallToken)
    return;

  // update values for current call token and call forward call token:
  if (!callTransferCallToken) {
    // after clearing the first call during a call proceeding,
    // the call transfer call token becomes the new call token
    currentCallToken = callTransferCallToken;
    callTransferCallToken = PString();
  }
  else
    currentCallToken = PString(); // indicate that our connection is now cleared

  // indicate call has hungup
  uiState = uiCallHungup;

  if (verbose != 0) {

    BOOL printDuration = TRUE;

    PString remoteName = '"' + connection.GetRemotePartyName() + '"';

    switch (connection.GetCallEndReason()) {
      case H323Connection::EndedByCallForwarded :
        printDuration = FALSE; // Don't print message here, was printed when forwarded
        break;
      case H323Connection::EndedByRemoteUser :
        cout << remoteName << " has cleared the call";
        break;
      case H323Connection::EndedByCallerAbort :
        cout << remoteName << " has stopped calling";
        break;
      case H323Connection::EndedByRefusal :
        cout << remoteName << " did not accept your call";
        break;
      case H323Connection::EndedByRemoteBusy :
        cout << remoteName << " was busy";
        break;
      case H323Connection::EndedByRemoteCongestion :
        cout << "Congested link to " << remoteName;
        break;
      case H323Connection::EndedByNoAnswer :
        cout << remoteName << " did not answer your call";
        break;
      case H323Connection::EndedByTransportFail :
        cout << "Call with " << remoteName << " ended abnormally";
        break;
      case H323Connection::EndedByCapabilityExchange :
        cout << "Could not find common codec with " << remoteName;
        break;
      case H323Connection::EndedByNoAccept :
        cout << "Did not accept incoming call from " << remoteName;
        break;
      case H323Connection::EndedByAnswerDenied :
        cout << "Refused incoming call from " << remoteName;
        break;
      case H323Connection::EndedByNoUser :
        cout << "Gatekeeper could not find user " << remoteName;
        break;
      case H323Connection::EndedByNoBandwidth :
        cout << "Call to " << remoteName << " aborted, insufficient bandwidth.";
        break;
      case H323Connection::EndedByUnreachable :
        cout << remoteName << " could not be reached.";
        break;
      case H323Connection::EndedByHostOffline :
        cout << remoteName << " is not online.";
        break;
      case H323Connection::EndedByNoEndPoint :
        cout << "No phone running for " << remoteName;
        break;
      case H323Connection::EndedByConnectFail :
        cout << "Transport error calling " << remoteName;
        break;
      default :
        cout << "Call with " << remoteName << " completed";
    }

    PTime connectTime = connection.GetConnectionStartTime();
    if (printDuration && connectTime.GetTimeInSeconds() != 0)
      cout << ", duration "
           << setprecision(0) << setw(5)
           << (PTime() - connectTime);

    cout << endl;
  }

  if (!hasMenu && terminateOnHangup) {
    exitFlag.Signal();
  }
}


BOOL MyH323EndPoint::OpenAudioChannel(H323Connection & connection,
                                         BOOL isEncoding,
                                         unsigned bufferSize,
                                         H323AudioCodec & codec)
{
#if defined(HAS_LIDDEVICE)
  if ((lidDevice != NULL) && lidDevice->IsOpen()) {
    PTRACE(2, "xJack\tAttaching channel to codec");
    if (!codec.AttachChannel(new OpalLineChannel(*lidDevice, POTS_LINE, codec)))
      return FALSE;
  }
  else
#endif

  if (!H323EndPoint::OpenAudioChannel(connection, isEncoding, bufferSize, codec)) {
    cout << "Could not open sound device ";
    if (isEncoding)
      cout << GetSoundChannelRecordDevice();
    else
      cout << GetSoundChannelPlayDevice();
    cout << " - Check permissions or full duplex capability." << endl;

    return FALSE;
  }

  codec.SetSilenceDetectionMode(currentCallOptions.noSilenceSuppression ?
                                   H323AudioCodec::NoSilenceDetection :
                                   H323AudioCodec::AdaptiveSilenceDetection);

  return TRUE;
}


BOOL MyH323EndPoint::OpenVideoChannel(H323Connection & connection,
                                     BOOL isEncoding,
                                     H323VideoCodec & codec)
{
  PVideoChannel      * channel = new PVideoChannel;
  PVideoOutputDevice * display = NULL;
  PVideoInputDevice  * grabber = NULL;

  PString nameStr = isEncoding ? PString("Local") :
                                 connection.GetRemotePartyName();

  if (isEncoding) {
    PAssert(autoStartTransmitVideo, "video encoder created without enable");
    if (0 != videoTxMinQuality) // set MinQuality first so TxQuality cannot be set lower
      codec.SetTxMinQuality(videoTxMinQuality);
    if (0 != videoTxQuality)
      codec.SetTxQualityLevel(videoTxQuality);
    codec.SetBackgroundFill(videoFill);
    if (0 != videoBitRate) {
      codec.SetMaxBitRate(videoBitRate);
      codec.SetVideoMode(
        H323VideoCodec::DynamicVideoQuality | 
        H323VideoCodec::AdaptivePacketDelay |
        codec.GetVideoMode());
    }
    if (0 != frameTimeMs) {
      codec.SetTargetFrameTimeMs(frameTimeMs);
      codec.SetVideoMode(
        H323VideoCodec::DynamicVideoQuality | 
        H323VideoCodec::AdaptivePacketDelay |
        codec.GetVideoMode());
    }

    unsigned newFrameWidth,newFrameHeight;
    newFrameWidth =  352 >> (1 - videoSize);                
    newFrameHeight = 288 >> (1 - videoSize);                

    if (videoFake)
      grabber = new PFakeVideoInputDevice();
    else
      grabber = new PVideoInputDevice();
   
    PStringList posDevNames = PVideoInputDevice::GetInputDeviceNames() +
                              PFakeVideoInputDevice::GetInputDeviceNames();
#ifdef TRY_1394DC
    posDevNames += PVideoInput1394DcDevice::GetInputDeviceNames();
    // Don't forget /dev/video1394/0  (DEVFS naming).
    if (videoDevice == "/dev/raw1394" ||
  strncmp(videoDevice, "/dev/video1394", 14) == 0) {
      delete grabber;
      grabber = new PVideoInput1394DcDevice();
    }

#endif
#ifdef TRY_1394AVC
    posDevNames += PVideoInput1394AvcDevice::GetInputDeviceNames();
    // Don't forget /dev/video1394/0  (DEVFS naming).
    if (videoDevice == "/dev/raw1394" ||
  strncmp(videoDevice, "/dev/video1394", 14) == 0) {
      delete grabber;
      grabber = new PVideoInput1394AvcDevice();
    }
#endif

#ifdef USE_SHM_VIDEO_DEVICES
    // posDevNames += ShmVideoInputDevice::GetInputDeviceNames();
    if (videoDevice == "shm") {
      delete grabber;
      grabber = new ShmVideoInputDevice();
    }
#endif

    for (PINDEX iName = 0; iName < posDevNames.GetSize(); iName++)
      PTRACE(1, "Available video input device:  " << posDevNames[iName]);

    if (!(pfdColourFormat.IsEmpty()))
      grabber->SetPreferredColourFormat(pfdColourFormat);

    PTRACE(3, "Attempt to open videoDevice " << videoDevice << " for reading."); 
    if (!grabber->Open(videoDevice, FALSE)) {
      PTRACE(3, "Failed to open the camera device");
      goto errVideo;
    }
    if ( !grabber->SetVideoFormat(
        videoIsPal ? PVideoDevice::PAL : PVideoDevice::NTSC)) {
      PTRACE(3, "Failed to set format to " << (videoIsPal ? "PAL" : "NTSC"));
      goto errVideo;
    }
    if (!grabber->SetChannel(videoInput)) {
      PTRACE(3, "Failed to set channel to " << videoInput);
      goto errVideo;
    }
    if ( !grabber->SetColourFormatConverter("YUV420P") ) {
      PTRACE(3,"Failed to set format to yuv420p");
      goto errVideo;
    }
    if ( !grabber->SetFrameRate(videoFramesPS)) {
      PTRACE(3, "Failed to set framerate to " << videoFramesPS);
      goto errVideo;
    }
    if  (!grabber->SetFrameSizeConverter(newFrameWidth,newFrameHeight,FALSE)) {
      PTRACE(3, "Failed to set framesize to " << newFrameWidth << "x" << newFrameHeight);
      goto errVideo;
    }
    PTRACE(3,"OpenVideoChannel\t done. Successfully opened a video camera");
    goto exitVideo;

  errVideo:
    delete grabber;
    grabber = (PVideoInputDevice *) new PFakeVideoInputDevice(); //This one never fails.
    grabber->SetColourFormat("YUV420P");
    grabber->SetVideoFormat(PVideoDevice::PAL);  // not actually used for fake video.
    grabber->SetChannel(100);                    //NTSC test image.
    grabber->SetFrameRate(0);                    //Select default frame rate.
    grabber->SetFrameSize(newFrameWidth, newFrameHeight);
    PTRACE(3,"Made a fictitious video camera showing NTSC test frame");

  exitVideo:
    grabber->Start();
    channel->AttachVideoReader(grabber);
  }

  if ((!isEncoding) || videoLocal) {
    PAssert(!videoReceiveDevice.IsEmpty(), "video display created without device type");

#ifdef P_SDL
     // Dump received video to SDL 
    if (videoReceiveDevice *= "sdl") 
      display = new PSDLVideoDevice(nameStr, isEncoding, sdlThread);
#endif

#ifdef HAS_X11
    // Dump received video to X11 window
    if (videoReceiveDevice.Left(3) *= "x11") {
      PString str = videoReceiveDevice;
      BOOL shared = str.Right(1) *= "s";
      str = str.Mid(3);
      if (!shared)
         display = new XlibVideoDevice(nameStr,isEncoding,videoPIP);
      else {
        str = str.Left(str.GetLength()-1);
        display = new ShmXlibVideoDevice(nameStr,isEncoding,videoPIP);
      }
      int depth = str.AsInteger();
      if (depth > 0)
        ((GenericXlibVideoDevice *)display)->ForceDepth(depth);
    }
#endif
#ifdef WIN32
    // code to specify windows 32 display device,
    // which uses MS windows conversion routines.
#endif
    // Dump video to PPM files
    //can have two ppm video devices.
    if (videoReceiveDevice *= "ppm") {
      display = new PVideoOutputDevicePPM();
      display->Open(isEncoding ? "local" : "remote");
    }
  }
#ifdef HAS_VGALIB //vgalib can only do receive video device.
  if (!isEncoding) {
     // Dump received video to VGA
     if (videoReceiveDevice *= "svga")
       display = new LinuxSVGAFullOutputDevice();

     else if (videoReceiveDevice *= "svga256")
       display = new LinuxSVGA256OutputDevice();
  }
#endif

#ifdef USE_SHM_VIDEO_DEVICES
  if (videoReceiveDevice *= "shm") {
    display = new ShmVideoOutputDevice();
    display->Open("shm");
  }
#endif

  // Dump video to nowhere
  if ((videoReceiveDevice *= "null") || (isEncoding&&(!videoLocal)))
    display = new PVideoOutputDeviceNULL();

  if (display == NULL)
    PError << "unknown video output device \"" << videoReceiveDevice << "\"" << endl;
  PAssert(display != NULL, "NULL video device");

  PTRACE(3,"display->SetFrameSize("
         << codec.GetWidth() << "," << codec.GetHeight() << ") from codec");
  //NB cannot resize receive video window if the following line is used
  //display->SetFrameSize(352>>(1-videoSize), 288>>(1-videoSize));
  display->SetFrameSize(codec.GetWidth(), codec.GetHeight()); // needed to enable resize
  display->SetColourFormatConverter("YUV420P");

  channel->AttachVideoPlayer(display);

  //Select true, delete video chanel on closing codec.
  return codec.AttachChannel(channel,TRUE);
}


H323Connection * MyH323EndPoint::SetupTransfer(const PString & token,
                                               const PString & callIdentity,
                                               const PString & remoteParty,
                                               PString & newToken,
                                               void * /*userData*/)
{
  H323Connection * conn = H323EndPoint::SetupTransfer(token,
                                                      callIdentity,
                                                      remoteParty,
                                                      newToken);
  callTransferCallToken = newToken;
  return conn;
}


//
//  if gateway is empty, then dest is assumed to be a IP address and optional port
//  if gateway is non-empty, then gateway is assumed to be an IP address and optional port, and
//  dest is passed to the gateway as the e164 address
//
void MyH323EndPoint::MakeOutgoingCall(const PString & dest,
                                      const PString & gateway)
{
  MakeOutgoingCall(dest, gateway, defaultCallOptions);
}

void MyH323EndPoint::MakeOutgoingCall(const PString & dest,
                                      const PString & gateway,
                                      CallOptions callOptions)
{
  currentCallOptions = callOptions;

  PString fullAddress;

  if (!gateway)
    fullAddress = gateway;
  else
    fullAddress = dest;

  if ((fullAddress.Find(':') == P_MAX_INDEX) && (callOptions.connectPort != H323EndPoint::DefaultTcpPort))
    fullAddress += psprintf(":%i", currentCallOptions.connectPort);

  if (!gateway)
    fullAddress = dest.Trim() + '@' + fullAddress;


  if (!MakeCall(fullAddress, currentCallToken)) {
    cout << "Error making call to \"" << fullAddress << '"' << endl;
    return;
  }

  PConfig config("Calls");
  int index = config.GetInteger("index");
  PString lastCalledParty = config.GetString(PString(PString::Unsigned, index));
  index = (index + 1) % LAST_CALL_COUNT;
  PTime now;
  PString indexStr = PString(PString::Unsigned, index);
  config.SetString(indexStr,           fullAddress);
  config.SetString(indexStr + "_Time", now.AsString());
  config.SetString("index",            indexStr);

  cout << GetLocalUserName() << " is calling host " << fullAddress << endl;
  uiState = uiConnectingCall;
}

void MyH323EndPoint::NewSpeedDial(const PString & ostr)
{
  PString str = ostr;
  PINDEX idx = str.Find(' ');
  if (str.IsEmpty() || (idx == P_MAX_INDEX)) {
    cout << "Must specify speedial number and string" << endl;
    return;
  }

  PString key  = str.Left(idx).Trim();
  PString data = str.Mid(idx).Trim();

  PConfig config("Speeddial");
  config.SetString(key, data);

  cout << "Speedial " << key << " set to " << data << endl;
}

void MyH323EndPoint::ListSpeedDials()
{
  PConfig config("Speeddial");
  PStringList keys = config.GetKeys();
  if (keys.GetSize() == 0) {
    cout << "No speed dials defined" << endl;
    return;
  }

  PINDEX i;
  for (i = 0; i < keys.GetSize(); i++)
    cout << keys[i] << ":   " << config.GetString(keys[i]) << endl;
}

//
// StartCall accepts any of the following types of arguments
//    speedial '#'      lookup the string in the registry, and continue processing
//    ipaddress         dial this IP address or hostname
//    num ' ' gateway   dial the number using the specified gateway
//

void MyH323EndPoint::StartCall(const PString & ostr)
{
  PString str = ostr.Trim();
  if (str.IsEmpty())
    cout << "Must supply hostname to connect to!\n";

  CallOptions callOptions = defaultCallOptions;

  // check for speed dials, and match wild cards as we go
  PString key, prefix;
  if ((str.GetLength() > 1) && (str[str.GetLength()-1] == '#')) {

    key = str.Left(str.GetLength()-1).Trim();

    str = PString();
    PConfig config("Speeddial");
    PINDEX p;
    for (p = key.GetLength(); p > 0; p--) {

      PString newKey = key.Left(p);
      prefix = newKey;
      PINDEX q;

      // look for wild cards
      str = config.GetString(newKey + '*').Trim();
      if (!str.IsEmpty())
        break;

      // look for digit matches
      for (q = p; q < key.GetLength(); q++)
        newKey += '?';
      str = config.GetString(newKey).Trim();
      if (!str.IsEmpty())
        break;
    }
    if (str.IsEmpty()) {
      cout << "Speed dial \"" << key << "\" not defined";
      if (gatekeeper != NULL) {
        cout << ", trying gatekeeper ..." << endl;
        MakeOutgoingCall(key, PString(), callOptions);
        return;
      }
      else
        cout << endl;
    }
    else if ((p = str.Find('(')) != P_MAX_INDEX) {
      PString argStr = str.Mid(p);
      if (argStr.GetLength() > 0 && argStr[argStr.GetLength()-1] == ')')
        argStr = argStr.Mid(1, argStr.GetLength()-2);
      PArgList strArgs(argStr,
                       "f-fast-disable."
                       "T-h245tunneldisable."
                       "e-silence."
                       "j-jitter:"
                       "-connectport:"
                       "-connectring:");
      callOptions.Initialise(strArgs);
      str = str.Left(p);
      cout << "Per connection call options set: " << argStr << endl
           << callOptions
           << endl;
    }
  }

  if (!str.IsEmpty()) {
    PINDEX idx = str.Find(' ');
    if (idx == P_MAX_INDEX) {
      if (!key && (str[0] == '@'))
        MakeOutgoingCall(key, str.Mid(1), callOptions);
      else if (!key && !prefix && (str[0] == '%')) {
        if (key.Left(prefix.GetLength()) == prefix)
          key = key.Mid(prefix.GetLength());
        MakeOutgoingCall(key, str.Mid(1), callOptions);
      } else
        MakeOutgoingCall(str, PString(), callOptions);
    } else {
      PString host = str.Left(idx).Trim();
      PString gw   = str.Mid(idx).Trim();
      MakeOutgoingCall(host, gw, callOptions);
    }
    return;
  }

  uiState = MyH323EndPoint::uiCallHungup;
}

void MyH323EndPoint::AwaitTermination()
{
  PThread * userInterfaceThread = NULL;
  if (hasMenu)
    userInterfaceThread = new UserInterfaceThread(*this);

#if ! defined(HAS_LIDDEVICE)

  exitFlag.Wait();

#else

  if ((lidDevice == NULL) || !lidDevice->IsOpen())
    exitFlag.Wait();
  else {

    speakerphoneSwitch = FALSE;
    BOOL oldOnHook     = TRUE;
    BOOL oldRealOnHook = TRUE;
    int  olduiState    = uiStateIllegal;
    PTime offHookTime;

    PString digits;

    // poll the handset every 100ms looking for state changes
    while (!exitFlag.Wait(100)) {

      // lock the user interface state whilst we change it
      uiStateMutex.Wait();

      // get real hook state
      BOOL realOnHook = !lidDevice->IsLineOffHook(POTS_LINE);
      BOOL onHook     = realOnHook;

      // if in speakerphone mode,
      if (speakerphoneSwitch) {

        // if the phone is onhook then don't look at the real hook state
        if (realOnHook)
          onHook = FALSE;

        // if the handset just went offhook, then get out of speakerphone mode
        else if (realOnHook != oldRealOnHook) {
          speakerphoneSwitch = FALSE;
          lidDevice->EnableAudio(0, TRUE);
          if (verbose > 1)
            cout << "Speakerphone off" << endl;
        }
      }

      // handle onhook/offhook transitions
      if (onHook != oldOnHook) {
        if (onHook) {
          digits = PString();
          HandleHandsetOnHook();
        } else {
          HandleHandsetOffHook();
          offHookTime = PTime();
        }
        HandleStateChange(onHook);
        olduiState = uiState;
      }

      // handle timeouts and DTMF digits
      if (!onHook) {
        HandleHandsetTimeouts(offHookTime);
        HandleHandsetDTMF(digits);
      }

      // handle any state changes
      if (uiState != olduiState) {
        offHookTime = PTime();
        HandleStateChange(onHook);
      }

      // save hook state so we can detect changes
      oldOnHook     = onHook;
      oldRealOnHook = realOnHook;

      // save the old UI state so we can detect changes
      olduiState = uiState;

      uiStateMutex.Signal();
    }
  }
#endif

  if (userInterfaceThread != NULL) {
    userInterfaceThread->Terminate();
    userInterfaceThread->WaitForTermination();
    delete userInterfaceThread;
  }
}

#if defined(HAS_LIDDEVICE)

#if 0
static char * stateNames[] = {
  "Dialtone",
  "AnsweringCall",
  "ConnectingCall",
  "WaitingForAnswer",
  "CallInProgress",
  "CallHungup",
  "StateIllegal"
};
#endif


void MyH323EndPoint::HandleStateChange(BOOL onHook)
{
  switch (uiState) {

    // dialtone whilst no call active
    case uiDialtone:
      if (onHook)
        lidDevice->RingLine(0, 0);
      else if (autoHook) {
        lidDevice->StopTone(0);
      } else {
        cout << "Playing dialtone" << endl;
        lidDevice->PlayTone(0, OpalLineInterfaceDevice::DialTone);
      }
      break;

    // no tone whilst waiting for remote party to connect
    case uiConnectingCall:
      if (onHook)
        lidDevice->RingLine(0, 0);
      else
        lidDevice->StopTone(0);
      break;

    // when connected, play ring tone
    case uiWaitingForAnswer:
      if (onHook)
        lidDevice->RingLine(0, 0);
      else {
        cout << "Playing ringtone" << endl;
        lidDevice->PlayTone(0, OpalLineInterfaceDevice::RingTone);
      }
      break;

    // when a call is in progress, stop all tones and remove DTMF tones from the stream
    case uiCallInProgress:
      if (onHook)
        lidDevice->RingLine(0, 0);
      else {
        lidDevice->StopTone(0);
        lidDevice->SetRemoveDTMF(0, TRUE);
      }
      break;

    // remote end has hungup
    case uiCallHungup:
      if (terminateOnHangup)
        exitFlag.Signal();

      if (autoHook || onHook) {
        uiState = uiDialtone;
        lidDevice->RingLine(0, 0);
      } else {
        if (dialAfterHangup)
          uiState = uiDialtone;
        else
          lidDevice->PlayTone(POTS_LINE, OpalLineInterfaceDevice::BusyTone);
      }
      break;

    case uiAnsweringCall:
      if (autoHook || !onHook)
        lidDevice->StopTone(0);
      else {
        lidDevice->SetCallerID(POTS_LINE, "");
        if (callerIdEnable) {
          MyH323Connection * connection = (MyH323Connection *)FindConnectionWithLock(currentCallToken);
          if (connection != NULL) {
            lidDevice->SetCallerID(POTS_LINE, connection->GetCallerIdString());
            connection->Unlock();
          }
        }
        lidDevice->RingLine(0, 0x33);
      }
      break;

   default:
      if (!onHook || autoHook)
        lidDevice->StopTone(0);
      else
        lidDevice->RingLine(0, 0);
      break;
  }
}

void MyH323EndPoint::HandleHandsetOffHook()
{
  if (verbose > 1)
    cout << "Offhook - ";

//  if (speakerphoneSwitch) {
//    if (verbose > 1)
//      cout << "speakerphone off - ";
//    speakerphoneSwitch = FALSE;
//    lidDevice->EnableAudio(0, TRUE);
//  }

  switch (uiState) {

    case uiDialtone:
      if (!autoDial) {
        if (verbose > 1)
          cout << "auto-dialing " << autoDial << endl;
        StartCall(autoDial);
      } else {
        if (verbose > 1)
          cout << "dialtone" << endl;
      }
    break;

    case uiConnectingCall:
      if (verbose > 1)
        cout << "call connecting" << endl;
      break;

    case uiAnsweringCall:
      if (verbose > 1)
        cout << "answering call" << endl;
      AnswerCall(H323Connection::AnswerCallNow);
      break;

    case uiWaitingForAnswer:
      if (verbose > 1)
        cout << "waiting for remote answer" << endl;
      break;

    case uiCallInProgress: // should never occur!
      if (verbose > 1)
        cout << "call in progress" << endl;
      break;

    default:
      if (verbose > 1)
        cout << "not sure!" << endl;
      break;
  }
}

void MyH323EndPoint::HandleHandsetOnHook()
{
  if (uiState == uiCallHungup)
    uiState = uiDialtone;

  if (verbose > 1)
    cout << "Onhook - ";

//#ifndef OLD_IXJ_DRIVER
//  if (speakerphoneSwitch) {
//    lidDevice->EnableAudio(0, FALSE);
//    if (verbose > 1)
//      cout << "speakerphone on." << endl;
//  } else
//#endif
//  {
    if (verbose > 1)
      cout << "ending call." << endl;
    ClearCall(currentCallToken);
//  }
  speakerphoneSwitch = FALSE;
}


void MyH323EndPoint::HandleHandsetDTMF(PString & digits)
{
  char newDigit = lidDevice->ReadDTMF(0);
  if (newDigit != '\0') {
    digits += newDigit;
    if (!digits) {
      switch (uiState) {
        case uiCallInProgress:
          {
            if (verbose > 1)
              cout << "Sending user indication message " << digits << endl;
            H323Connection * connection = FindConnectionWithLock(currentCallToken);
            if (connection != NULL) {
              connection->SendUserInput(digits);
              connection->Unlock();
            }
            digits = PString();
          }
          break;

        case uiDialtone:
          lidDevice->StopTone(0);
          if (digits.GetLength() > 0) {
            PINDEX i;
            for (i = 0; i < digits.GetLength(); i++)
              if (!isdigit(digits[i]))
                break;
            BOOL allDigits = i == digits.GetLength();

            // handle strings ending in '#'
            if (digits[digits.GetLength()-1] == '#')  {

              // if pressed '#', then redial last number
              if (digits.GetLength() == 1) {
                PConfig config("Calls");
                int index = config.GetInteger("index");
                PString lastCalledParty = config.GetString(PString(PString::Unsigned, index));
                if (lastCalledParty.IsEmpty())
                  cout << "No last called party to dial" << endl;
                else {
                  if (!MakeCall(lastCalledParty, currentCallToken))
                    cout << "Error making call to \"" << lastCalledParty << '"' << endl;
                  else {
                    if (verbose > 1)
                      cout << "Redialling last number at " << lastCalledParty << endl;
                    uiState = uiConnectingCall;
                  }
                }
              }

              // if pressed '*#', then redial last caller
              else if ((digits.GetLength() == 2) && (digits[0] == '*')) {
                PConfig config("Callers");
                int index = config.GetInteger("index");
                PString lastCallingParty = config.GetString(PString(PString::Unsigned, index));
                if (lastCallingParty.IsEmpty())
                  cout << "No last calling party to dial" << endl;
                else {
                  if (!MakeCall(lastCallingParty, currentCallToken))
                    cout << "Error making call to \"" << lastCallingParty << '"' << endl;
                  else {
                    if (verbose > 1)
                      cout << "Calling back last party at " << lastCallingParty << endl;
                    uiState = uiConnectingCall;
                  }
                }
              }

              // if string starts with '*', then convert to IP address
              else if ((digits.GetLength() >= 9) && (digits[0] == '*')) {
                digits = digits.Mid(1, digits.GetLength()-2);
                digits.Replace('*', '.', TRUE);
                StartCall(digits);

              // if there are some digits, then use them as a speed dial
              } else if (digits.GetLength() > 1)
                StartCall(digits);

              // clear out the dialled digits
              digits = PString();

            } else if (allDigits && (digits.GetLength() == 20)) {
              while (digits[0] == '0')
                digits = digits.Mid(1);
              if (digits.GetLength() > 0) {
                StartCall(digits);
                digits = PString();
              }
            }
          }
          break;

        default:
          break;
      }
    }
  }
}


void MyH323EndPoint::HandleHandsetTimeouts(const PTime & offHookTime)
{
  int timeout = 0;

  switch (uiState) {

    case uiDialtone:
      timeout = DEFAULT_TIMEOUT;
      break;

    case uiConnectingCall:
      timeout = DEFAULT_TIMEOUT;
      break;

    case uiWaitingForAnswer:
      timeout = DEFAULT_TIMEOUT;
      break;

    default:
      break;
  }

  if (timeout > 0) {
    PTime now;
    if ((now - offHookTime) > timeout) {
      if (verbose > 1)
        cout << "Operation timed out" << endl;
      ClearCall(currentCallToken);
      uiState = uiCallHungup;
    }
  }
}

#endif

void MyH323EndPoint::HandleUserInterface()
{
  PConsoleChannel console(PConsoleChannel::StandardInput);

  PTRACE(2, "OhPhone\tUser interface thread started.");

  PStringStream help;
  help << "Select:\n"
          "  0-9 : send user indication message\n"
          "  *,# : send user indication message\n"
          "  M   : send text message to remote user\n"
          "  C   : connect to remote host\n"
          "  T   : Transfer to another host\n"
          "  O   : Hold call\n"
          "  S   : Display statistics\n"
          "  H   : Hang up phone\n"
          "  L   : List speed dials\n"
          "  I   : Show call history\n"
          "  D   : Create new speed dial\n"
          "  {}  : Increase/reduce record volume\n"
          "  []  : Increase/reduce playback volume\n"
          "  V   : Display current volumes\n"
#ifdef HAS_LIDDEVICE
          "  A   : turn AEC up/down\n"
#endif
          "  E   : Turn silence supression on/off\n"
          "  F   : Forward call calls to address\n"
          "  J   : Flip video input top to bottom\n";
         ;

#ifdef HAS_LIDDEVICE
  if (isXJack) {
#ifndef OLD_IXJ_DRIVER
    if ((lidDevice != NULL) && lidDevice->IsOpen())
      help << "  P   : Enter speakerphone mode\n";
#endif
  }
#endif

  help << "  X   : Exit program\n";

  for (;;) {

    // display the prompt
    cout << "Command ? " << flush;

    // terminate the menu loop if console finished
    char ch = (char)tolower(console.peek());
    if (console.eof()) {
      if (verbose)
        cout << "\nConsole gone - menu disabled" << endl;
      return;
    }
    if (ch == '\n') {
      console.ignore(INT_MAX, '\n');
      continue;
    }

    if ((isdigit(ch)) || (ch == '*') || (ch == '#') || (ch == 'm')) {
      H323Connection * connection = FindConnectionWithLock(currentCallToken);
      if (connection == NULL) {
        cout << "No call in progress\n";
        console.ignore(INT_MAX, '\n');
      } else {
        PString str;
        console >> str;

  if (ch == 'm') { // Send message
           str = str.Mid(1).Trim(); // strip 'm' and trim whitespace
           str = "MSG"+str.Trim(); // Add GnomeMeeting message header
        }
        cout << "Sending user indication: " << str << endl;
        connection->SendUserInput(str);
        connection->Unlock();
      }
    }
    else {
      console >> ch;
      switch (tolower(ch)) {
        case '?' :
          cout << help << endl;
          break;

        case 'x' :
        case 'q' :
          cout << "Exiting." << endl;
          ClearAllCalls();
          uiState = uiDialtone;
          exitFlag.Signal();
          console.ignore(INT_MAX, '\n');
          return;

        case 'h' :
          if (!currentCallToken) {
            cout << "Hanging up call." << endl;
            if (!ClearCall(currentCallToken))
              cout << "Could not hang up current call!\n";
            speakerphoneSwitch = FALSE;
          }
          console.ignore(INT_MAX, '\n');
          break;

        case 't' :
          if (!currentCallToken) {
            PString str;
            console >> str;
            cout << "Transferring call to " << str << endl;
            TransferCall(currentCallToken, str.Trim());
          }
          else
            console.ignore(INT_MAX, '\n');
          break;

        case 'o' :
          if (!currentCallToken) {
            cout << "Holding call." << endl;
            HoldCall(currentCallToken, TRUE);
          }
          console.ignore(INT_MAX, '\n');
          break;

        case 'y' :
          AnswerCall(H323Connection::AnswerCallNow);
          console.ignore(INT_MAX, '\n');
          break;

        case 'n' :
          AnswerCall(H323Connection::AnswerCallDenied);
          console.ignore(INT_MAX, '\n');
          break;

        case 'c' :
          if (!currentCallToken.IsEmpty())
            cout << "Cannot make call whilst call in progress\n";
          else {
            PString str;
            console >> str;
            StartCall(str.Trim());
          }
          break;

        case 'l' :
          ListSpeedDials();
          break;

        case 'd' :
          {
            PString str;
            console >> str;
            NewSpeedDial(str.Trim());
          }
          break;

        case 'e' :
          if (currentCallToken.IsEmpty())
            cout << "No call in progress" << endl;
          else {
            H323Connection * connection = FindConnectionWithLock(currentCallToken);
            if (connection == NULL)
              cout << "No connection active.\n";
            else {
              connection->Unlock();
              H323Channel * chan = connection->FindChannel(RTP_Session::DefaultAudioSessionID, FALSE);
              if (chan == NULL)
                cout << "Cannot find audio channel" << endl;
              else {
                H323Codec * rawCodec  = chan->GetCodec();
                if (!rawCodec->IsDescendant(H323AudioCodec::Class()))
                  cout << "Audio channel is not audio!" << endl;
                else {
                  H323AudioCodec * codec = (H323AudioCodec *)rawCodec;
                  H323AudioCodec::SilenceDetectionMode mode = codec->GetSilenceDetectionMode();
                  if (mode == H323AudioCodec::AdaptiveSilenceDetection) {
                    mode = H323AudioCodec::NoSilenceDetection;
                    cout << "Silence detection off" << endl;
                  } else {
                    mode = H323AudioCodec::AdaptiveSilenceDetection;
                    cout << "Silence detection on" << endl;
                  }
                  codec->SetSilenceDetectionMode(mode);
                }
              }
            //  connection->Unlock();
            }
          }
          break;

        case 's' :
          if (currentCallToken.IsEmpty())
            cout << "No call in progress" << endl;
          else {
            H323Connection * connection = FindConnectionWithLock(currentCallToken);
            if (connection == NULL)
              cout << "No connection statistics available.\n";
            else {
              PTime now;
              PTime callStart = connection->GetConnectionStartTime();
              cout << "Connection statistics:\n   "
                   << "Remote party     : " << connection->GetRemotePartyName() << "\n   "
                   << "Start            : " << callStart << "\n   "
                   << "Duration         : " << setw(5) << setprecision(0) << (now - callStart) << " mins\n   "
                   << "Round trip delay : " << connection->GetRoundTripDelay().GetMilliSeconds() << " msec"
                   << endl;
	      ReportSessionStatistics(connection, RTP_Session::DefaultAudioSessionID);
	      ReportSessionStatistics(connection, RTP_Session::DefaultVideoSessionID);
	      connection->Unlock();
            }
          }
	  console.ignore(INT_MAX, '\n');
          break;

#ifdef HAS_LIDDEVICE
#ifndef OLD_IXJ_DRIVER
        case 'p' :
          if (isXJack) {
            if ((lidDevice != NULL) && lidDevice->IsOpen()) {
              speakerphoneSwitch = !speakerphoneSwitch;
              lidDevice->EnableAudio(0, !speakerphoneSwitch);
              if (verbose > 1)
                cout << "Speakerphone "
                     << (speakerphoneSwitch ? "on" : "off")
                     << endl;
            }
            console.ignore(INT_MAX, '\n');
          }
          break;
#endif

        case 'a' :
          if ((lidDevice != NULL) && lidDevice->IsOpen()) {
            int aec = lidDevice->GetAEC(0);
            if (ch == 'a')
              aec--;
            else
              aec++;
            if (aec < 0)
              aec = OpalLineInterfaceDevice::AECAGC;
            else if (aec > OpalLineInterfaceDevice::AECAGC)
              aec = OpalLineInterfaceDevice::AECOff;

            lidDevice->SetAEC(0, (OpalLineInterfaceDevice::AECLevels)aec);

            if (aec == OpalLineInterfaceDevice::AECAGC ||
               (ch == 'a' && aec == OpalLineInterfaceDevice::AECHigh) ||
               (ch == 'A' && aec == OpalLineInterfaceDevice::AECOff)) {
              unsigned recvol;
              lidDevice->GetRecordVolume(0, recvol);
              if (verbose > 2)
                cout << "New volume level is " << recvol << endl;
            }
            if (verbose > 2)
              cout << "New AEC level is " << AECLevelNames[aec] << endl;
          } else
            cout <<"AEC change ignored as device closed"<<endl;
          break;
#endif

        case 'v' :
#if defined(HAS_LIDDEVICE)
          if ((lidDevice != NULL) && lidDevice->IsOpen()) {
            unsigned vol;
            lidDevice->GetPlayVolume(0, vol);
            cout << "Play volume is " << vol << endl;
            lidDevice->GetRecordVolume(0, vol);
            cout << "Record volume is " << vol << endl;
          }
#endif
#if defined(HAS_LIDDEVICE) && defined(HAS_OSS)
          else
#endif
#ifdef HAS_OSS
          {
            cout << "Play volume is " << ossPlayVol << endl;
            cout << "Record volume is " << ossRecVol << endl;
          }
#endif
          break;

        case '[' :
        case ']' :
        case '{' :
        case '}' :
#ifdef HAS_LIDDEVICE
          if ((lidDevice != NULL) && lidDevice->IsOpen()) {
            unsigned vol;
            if (ch == '{' || ch == '}')
              lidDevice->GetRecordVolume(0, vol);
            else
              lidDevice->GetPlayVolume(0, vol);

            // adjust volume up or down
            vol += ((ch == '[') || (ch == '{')) ? -5 : 5;
            if (vol < 0)
              vol = 0;
            else if (vol > 100)
              vol = 100;

            // write to hardware
            if (ch == '{' || ch == '}') {
              lidDevice->SetRecordVolume(0, vol);
              if (verbose > 2)
               cout << "Record volume is " << vol << endl;
            } else {
              lidDevice->SetPlayVolume(0, vol);
              if (verbose > 2)
               cout << "Play volume is " << vol << endl;
            }
          }
#endif

#if defined(HAS_LIDDEVICE) && defined(HAS_OSS)
          else
#endif
#ifdef HAS_OSS
          {
            int vol;
            if (ch == '{' || ch == '}')
              vol = ossRecVol;
            else
              vol = ossPlayVol;

            vol += ((ch == '[') || (ch == '{')) ? -5 : 5;
            if (vol < 0)
              vol = 0;
            else if (vol > 100)
              vol = 100;

            if (mixerDev >= 0)  {
              int volVal = vol | (vol << 8);
              if (ch == '{' || ch == '}') {
                ossRecVol = vol;
                ::ioctl(mixerDev, MIXER_WRITE(mixerRecChan), &volVal);
                cout << "Record volume is " << ossRecVol << endl;
              } else {
                ossPlayVol = vol;
                ::ioctl(mixerDev, SOUND_MIXER_WRITE_PCM, &volVal);
                cout << "Play volume is " << ossPlayVol << endl;
              }
            } else
              cout << "Audio setting change ignored as mixer device disabled"<<endl;
          }
#endif
          break;

        case 'f' :
          console >> alwaysForwardParty;
          alwaysForwardParty = alwaysForwardParty.Trim();
          if (!alwaysForwardParty)
            cout << "Forwarding all calls to \"" << alwaysForwardParty << '"' << endl;
          else
            cout << "Call forwarding of all calls disabled." << endl;
          break;

        case 'i' :
        case 'I' :
          {
            PString title;
            if (ch == 'i')
              title   = "Callers";
            else
              title   = "Calls";
            cout << title << endl;
            PConfig config(title);
            int index = config.GetInteger("index");
            PINDEX i;
            for (i = 0; i < LAST_CALL_COUNT; i++) {
              PString indexStr = PString(PString::Unsigned, index);
              PString number = config.GetString(indexStr);
              if (number.IsEmpty())
                continue;
              cout << indexStr
                   << ": "
                   << number
                   << " at "
                   << config.GetString(indexStr + "_Time")
                   << endl;
              if (index == 0)
                index = LAST_CALL_COUNT-1;
              else
                index--;
            }
          }
          break;

        case 'j' :
          if (currentCallToken.IsEmpty())
            cout << "No call in progress" << endl;
          else {
            H323Connection * connection = FindConnectionWithLock(currentCallToken);
            if (connection == NULL)
              cout << "No connection active.\n";
            else {
              connection->Unlock();
              H323Channel * chan = connection->FindChannel(RTP_Session::DefaultVideoSessionID, FALSE);
              if (chan == NULL)
                cout << "Cannot find sending video channel" << endl;
              else {
                H323Codec * rawCodec  = chan->GetCodec();
                if (!rawCodec->IsDescendant(H323VideoCodec::Class()))
                  cout << "Sending video codec is not video!" << endl;
                else {
                  H323VideoCodec * codec = (H323VideoCodec *)rawCodec;
                  PChannel * rawChan = codec->GetRawDataChannel();
                  if (NULL == rawChan)
                    cout << "Cannot find sending video channel" << endl;
                  else {
                    if (!rawChan->IsDescendant(PVideoChannel::Class()))
                      cout << "Sending video channel is not Class PVideoChannel!" << endl;
                    else {
                      PVideoChannel * videoChan = (PVideoChannel *)rawChan;
                      if (!videoChan->ToggleVFlipInput())
                        cout << "\nCould not toggle Vflip state of video input device" << endl;
                    }
                  }
                }
              }
            }
          }
          break;

        default:
          cout << "Unknown command " << ch << endl;
          console.ignore(INT_MAX, '\n');
          break;
      }
    }
  }
}

void MyH323EndPoint::ReportSessionStatistics(H323Connection *connection, unsigned sessionID)
{
  RTP_Session * session = connection->GetSession(sessionID);
  if ((session == NULL) && (sessionID == RTP_Session::DefaultAudioSessionID))
    cout << "No RTP Audio session statistics available." << endl;

  if (session == NULL)
    return;

  PInt64 elapsedMilliseconds = (PTime() - connection->GetConnectionStartTime()).GetMilliSeconds();  
  cout << "RTP " 
       << (sessionID == RTP_Session::DefaultAudioSessionID ? "audio" : "video") 
       << " session statistics \n   " 

       << session->GetPacketsSent() << '/'
       << session->GetOctetsSent() << '/'
       << 8 * 1.024 * session->GetOctetsSent() / elapsedMilliseconds
       << " packets/bytes/datarate sent\n   "
    
       << session->GetMaximumSendTime() << '/'
       << session->GetAverageSendTime() << '/'
       << session->GetMinimumSendTime() << " max/avg/min send time\n   "
    
       << session->GetPacketsReceived() << '/'
       << session->GetOctetsReceived() << '/'
       << 8* 1.024 * session->GetOctetsReceived() / elapsedMilliseconds
       << " packets/bytes/datarate received\n   "
		              
       << session->GetMaximumReceiveTime() << '/'
       << session->GetAverageReceiveTime() << '/'
       << session->GetMinimumReceiveTime() << " max/avg/min receive time\n   "
    
       << session->GetPacketsLost() << '/'
       << session->GetPacketsOutOfOrder() << '/'
       << session->GetPacketsTooLate() 
       << " packets dropped/out of order/late\n   "
    
       << endl;
}

void MyH323EndPoint::AnswerCall(H323Connection::AnswerCallResponse response)
{
  if (uiState != uiAnsweringCall)
    return;

  StopRinging();

  H323Connection * connection = FindConnectionWithLock(currentCallToken);
  if (connection == NULL)
    return;

  connection->AnsweringCall(response);
  connection->Unlock();

  if (response == H323Connection::AnswerCallNow) {
    cout << "Accepting call." << endl;
    uiState = uiCallInProgress;
  } else {
    cout << "Rejecting call." << endl;
    uiState = uiCallHungup;
  }
}


void MyH323EndPoint::HandleRinging()
{
  PSoundChannel dev(GetSoundChannelPlayDevice(), PSoundChannel::Player);
  if (!dev.IsOpen()) {
    PTRACE(2, "Cannot open sound device for ring");
    return;
  }

  if (ringDelay < 0) {
    PTRACE(2, "Playing " << ringFile);
    dev.PlayFile(ringFile, TRUE);
  } else {
    PTimeInterval delay(0, ringDelay);
    PTRACE(2, "Playing " << ringFile << " with repeat of " << delay << " ms");
    do {
      dev.PlayFile(ringFile, TRUE);
    } while (!ringFlag.Wait(delay));
  }
}


void MyH323EndPoint::StartRinging()
{
  PAssert(ringThread == NULL, "Ringing thread already present");

  if (!noAnswerForwardParty)
    noAnswerTimer = PTimeInterval(0, noAnswerTime);

  if (!ringFile)
    ringThread = new RingThread(*this);
}


void MyH323EndPoint::StopRinging()
{
  noAnswerTimer.Stop();

  if (ringThread == NULL)
    return;

  ringFlag.Signal();
  ringThread->WaitForTermination();
  delete ringThread;
  ringThread = NULL;
}

void MyH323EndPoint::SendDTMF(const char * tone)
{
#ifdef HAS_LIDDEVICE
  if (lidDevice != NULL && lidDevice->IsOpen())
    lidDevice->PlayDTMF(0, tone, 200, 100);
#endif
}

void MyH323EndPoint::WaitForSdlTermination()
{
#ifdef P_SDL
  PWaitAndSignal m(sdlThreadLock);

  if (sdlThread != NULL) {
    sdlThread->Terminate();
    sdlThread->WaitForTermination();
    delete sdlThread;
  }
#endif
}

BOOL MyH323EndPoint::InitialiseSdl(PConfigArgs & args)
{
#ifdef P_SDL
  PWaitAndSignal mutex(sdlThreadLock);
  sdlThread = NULL;
#endif
  PString videoDisplayDevice;

  if (args.HasOption("videoreceive"))
    videoDisplayDevice = args.GetOptionString("videoreceive");
  if (args.HasOption("h261"))
    videoDisplayDevice = args.GetOptionString("h261");
  
  if (videoDisplayDevice *= "sdl") {                        
#ifdef  P_SDL
    sdlThread = new PSDLDisplayThread(args.HasOption("videopip"));
    PTRACE(3, "SDL display thread has been created ");
#else
    cout << "Warning --videoreceive device is SDL, but SDL is not installed" << endl
	 << "       Install/Enable the SDL libraries, and then recompile " << endl
	 << "       pwlib/openh323 and ohphone." << endl;
    return FALSE;
#endif  
  }

  return TRUE;
}
  
void MyH323EndPoint::TestVideoGrabber(PConfigArgs & args)
{
  double lossRate = 0;
  if (args.HasOption("videolose"))
    lossRate = args.GetOptionString("videolose").AsReal();

  if (lossRate > 100)
    lossRate = 100;
  else if (lossRate < 0)
    lossRate = 0;
  lossRate = lossRate / 100.0;
  unsigned  maxint  = 0xffffffff; 
  unsigned  divisor = (unsigned)(lossRate * (double)maxint);
  PRandom rand;

  MyH323Connection tempConnection(*this, 2, 0, 0, FALSE, FALSE);

  PThread * userInterfaceThread = NULL;
  if (hasMenu)
    userInterfaceThread = new TestUserInterfaceThread(*this);

  H323Capability * cap;
  PString capName;

#ifdef DEPRECATED_CU30
  if (videoCu30Stats) 
    capName="Cu30";
  else
#endif 
  cap = GetCapabilities().FindCapability("H.26");
  if (cap == NULL) {
    cout << "Unable to find the codec associated with \"" << capName <<
           "\". Exiting"<<endl;
    return;
  }
  cerr << *cap << "found for use " << endl;

  H323Codec *EncodingCodec = cap->CreateCodec(H323Codec::Encoder);
  H323Codec *DecodingCodec = cap->CreateCodec(H323Codec::Decoder);

  autoStartTransmitVideo = TRUE; //Force these options to be on. Guarantees that OpenVideoChannel works.
  videoLocal = TRUE;
  OpenVideoChannel(tempConnection, TRUE,  *((H323VideoCodec *)EncodingCodec));  //Which creates local video display.
  OpenVideoChannel(tempConnection, FALSE, *((H323VideoCodec *)DecodingCodec));

  localVideoChannel =  (PVideoChannel *)EncodingCodec->GetRawDataChannel();

  int  packetCount, frameCount, skipCount;
  RTP_DataFrame frame(2048);
  unsigned length, written;

  if (cap->IsDescendant(H323_H261Capability::Class())) 
    frame.SetPayloadType(RTP_DataFrame::H261); 
#if H323_AVCODEC
  else if (cap->IsDescendant(H323_FFH263Capability::Class()))
    frame.SetPayloadType(RTP_DataFrame::DynamicBase);
#endif
  frameCount = 0;
  skipCount = 0;
  PINDEX bitsEncoded = 0;
  PTime startTime;
  unsigned sequenceMask = (1 << (8 * sizeof(WORD))) - 1;
  for(packetCount = 2; ; packetCount++) { //H323Codec::lastSequenceNumber starts at 1 so next is 2
    PTRACE(3,"Video\t Packet " << packetCount << " of test video program");

    EncodingCodec->Read(frame.GetPayloadPtr(), length, frame);
    frame.SetPayloadSize(length);
    bitsEncoded += length * 8;

    frame.SetSequenceNumber((WORD)(packetCount & sequenceMask));
    if (frame.GetMarker())
      frameCount++;

//#define ENABLE_FRAME_TESTING 1 // uncomment to enable out of order packet testing
#ifdef ENABLE_FRAME_TESTING
    {// test effect of same frame video packets arriving out of order
    static RTP_DataFrame testframe(2048);
    static unsigned testlength = 0;
    static BOOL tryTest = FALSE;

    if (0 == packetCount % 7) 
      tryTest = TRUE;

    if (tryTest) {
      if (0 == testlength) {
        if (!frame.GetMarker()) {
          testframe.SetMarker(frame.GetMarker());
          testframe.SetSequenceNumber(frame.GetSequenceNumber());
          memcpy(testframe.GetPayloadPtr(), frame.GetPayloadPtr(), length);
          testlength = length;
        }
        else // delay test if end of frame
          DecodingCodec->Write(frame.GetPayloadPtr(), length, frame, written);
      }
      else {
        if (frame.GetMarker()) { // send both packets in order and restart test
          DecodingCodec->Write(testframe.GetPayloadPtr(), testlength, testframe, written);
          DecodingCodec->Write(frame.GetPayloadPtr(), length, frame, written);
          testlength = 0;
        }
        else { // send packets out of order
          DecodingCodec->Write(frame.GetPayloadPtr(), length, frame, written);
          DecodingCodec->Write(testframe.GetPayloadPtr(), testlength, testframe, written);
          testlength = 0;
          tryTest = FALSE;
        }
      }
    }
    else
      DecodingCodec->Write(frame.GetPayloadPtr(), length, frame, written);
    }
#else //ENABLE_FRAME_TESTING
    if (divisor < rand)
      DecodingCodec->Write(frame.GetPayloadPtr(), length, frame, written);
    else
      skipCount++;
#endif //ENABLE_FRAME_TESTING

#ifdef DEPRECATED_CU30
    //    if (videoCu30Stats)
    //      ((H323_Cu30Codec *)Codec)->RecordStatistics(videoBuffer);
    if ((packetCount + 1)  ==  videoCu30Stats)
      break;
#endif
    if (!exitFlag.WillBlock())
      break;
  }

  PTimeInterval diffTime= PTime() - startTime;

  double data_rate = ((double)bitsEncoded) / (((double)diffTime.GetMilliSeconds()) * 1.024);

  PStringStream str;
  str  << "    Video frames per second: "<< setprecision(2) 
       << (double) 1000 * frameCount/diffTime.GetMilliSeconds()  << endl
       << "    Data rate " << setprecision(3) << data_rate  << " Kilo bits/second" << endl
       << "    Packets Tot " << packetCount << "  skipped packets " << skipCount;
  PTRACE(3, str);
  cout << endl << str << endl;

  str = "Elapsed time is ";
  str << diffTime << " seconds" ;
  PTRACE(3, str);
  cout << str << endl;

  delete EncodingCodec;
  delete DecodingCodec;

  if (NULL != userInterfaceThread) {
      userInterfaceThread->Terminate();
      userInterfaceThread->WaitForTermination();
      delete userInterfaceThread;
  }

  return;
}

void MyH323EndPoint::TestHandleUserInterface()
{
  PConsoleChannel console(PConsoleChannel::StandardInput);

  PTRACE(2, "OhPhone\tTESTING interface thread started.");

  PStringStream help;
  help << "Select:\n"
          "  J   : Flip video input top to bottom\n"
          "  Q   : Exit program\n"
          "  X   : Exit program\n";

  for (;;) {

    // display the prompt
    cout << "(testing) Command ? " << flush;

    // terminate the menu loop if console finished
    char ch = (char)console.peek();
    if (console.eof()) {
      if (verbose)
        cout << "\nConsole gone - menu disabled" << endl;
      return;
    }

    console >> ch;
    switch (tolower(ch)) {
    case 'j' :
      if (NULL == localVideoChannel) {
  cout << "\nNo video Channel" << endl;
  break;
      }
      if (!localVideoChannel->ToggleVFlipInput())
  cout << "\nCould not toggle Vflip state of video input device" << endl;
      break;

    case 'x' :
    case 'q' :
      cout << "Exiting." << endl;
      exitFlag.Signal();
      console.ignore(INT_MAX, '\n');
      return;
      break;
    case '?' :
    default:
      cout << help << endl;
      break;

    } // end switch
  } // end for
}


///////////////////////////////////////////////////////////////

BOOL CallOptions::Initialise(PArgList & args)
{
  // set default connection options
  noFastStart          = args.HasOption('f');
  noH245Tunnelling     = args.HasOption('T');
  noSilenceSuppression = args.HasOption('e');
  noH245InSetup        = args.HasOption('S');

  if (args.HasOption("connectring"))
    connectRing = args.HasOption("connectring");

  if (!args.GetOptionString("connectport").IsEmpty())
    connectPort = (WORD)args.GetOptionString("connectport").AsInteger();

  if (args.HasOption('j')) {
    unsigned minJitterNew;
    unsigned maxJitterNew;
    PStringArray delays = args.GetOptionString('j').Tokenise(",-");
    if (delays.GetSize() > 1) {
      minJitterNew = delays[0].AsUnsigned();
      maxJitterNew = delays[1].AsUnsigned();
    }
    else {
      maxJitterNew = delays[0].AsUnsigned();
      minJitterNew = PMIN(minJitter, maxJitterNew);
    }
    if (minJitterNew >= 20 && minJitterNew <= maxJitterNew && maxJitterNew <= 1000) {
      minJitter = minJitterNew;
      maxJitter = maxJitterNew;
    }
    else {
      cout << "Jitter should be between 20 milliseconds and 1 seconds, is "
           << minJitter << '-' << maxJitter << endl;
      return FALSE;
    }
  }

  return TRUE;
}

void CallOptions::PrintOn(ostream & strm) const
{
  strm << "FastStart is " << !noFastStart << "\n"
       << "H245Tunnelling is " << !noH245Tunnelling << "\n"
       << "SilenceSupression is " << !noSilenceSuppression << "\n"
       << "H245InSetup is " << !noH245InSetup << "\n"
       << "Jitter buffer: "  << minJitter << '-' << maxJitter << " ms\n"
       << "Connect port: " << connectPort << "\n";
}




///////////////////////////////////////////////////////////////

MyH323Connection::MyH323Connection(MyH323EndPoint & ep,
                                   unsigned callReference,
                                   unsigned options,
                                   unsigned minJitter,
                                   unsigned maxJitter,
                                   int _verbose)
  : H323Connection(ep, callReference, options),
    myEndpoint(ep),
    verbose(_verbose)
{
  SetAudioJitterDelay(minJitter, maxJitter);
  channelsOpen = 0;
}


BOOL MyH323Connection::OnSendSignalSetup(H323SignalPDU & setupPDU)
{
  if (!myEndpoint.setupParameter) {
    setupPDU.m_h323_uu_pdu.IncludeOptionalField(H225_H323_UU_PDU::e_nonStandardData);
    setupPDU.m_h323_uu_pdu.m_nonStandardData.m_nonStandardIdentifier.SetTag(H225_NonStandardIdentifier::e_h221NonStandard);
    endpoint.SetH221NonStandardInfo(setupPDU.m_h323_uu_pdu.m_nonStandardData.m_nonStandardIdentifier);
    setupPDU.m_h323_uu_pdu.m_nonStandardData.m_data = myEndpoint.setupParameter;
  }
  return TRUE;
}


H323Connection::AnswerCallResponse
     MyH323Connection::OnAnswerCall(const PString & caller,
                                    const H323SignalPDU & /*setupPDU*/,
                                    H323SignalPDU & /*connectPDU*/)
{
  PTRACE(1, "H225\tOnWaitForAnswer");

  PTime now;

  if (myEndpoint.autoAnswer) {
    cout << "Automatically accepting call at " << now << endl;
    return AnswerCallNow;
  }

  myEndpoint.currentCallToken = GetCallToken();
  myEndpoint.uiState = MyH323EndPoint::uiAnsweringCall;


  cout << "Incoming call from \""
       << caller
       << "\" at "
       << now
       << ", answer call (Y/n)? "
       << flush;

  myEndpoint.StartRinging();

  return AnswerCallPending;
}


BOOL MyH323Connection::OnStartLogicalChannel(H323Channel & channel)
{
  if (!H323Connection::OnStartLogicalChannel(channel))
    return FALSE;

  if (verbose >= 2) {
    cout << "Started logical channel: ";

    switch (channel.GetDirection()) {
      case H323Channel::IsTransmitter :
        cout << "sending ";
        break;

      case H323Channel::IsReceiver :
        cout << "receiving ";
        break;

      default :
        break;
    }

    cout << channel.GetCapability() << endl;
  }

  if (channel.GetDirection() == H323Channel::IsReceiver) {
    int videoQuality = myEndpoint.videoQuality;
    if (channel.GetCodec()->IsDescendant(H323VideoCodec::Class()) && (videoQuality >= 0)) {

      //const H323_H261Capability & h261Capability = (const H323_H261Capability &)channel.GetCapability();
      //if (!h261Capability.GetTemporalSpatialTradeOffCapability())
      //  cout << "Remote endpoint does not allow video quality configuration" << endl;
      //else {
        cout << "Requesting remote endpoint to send video quality " << videoQuality << "/31" << endl;

        // kludge to wait for channel to ACK to be sent
        PThread::Current()->Sleep(2000);

        H323ControlPDU pdu;
        H245_CommandMessage & command = pdu.Build(H245_CommandMessage::e_miscellaneousCommand);

        H245_MiscellaneousCommand & miscCommand = command;
        miscCommand.m_logicalChannelNumber = (unsigned)channel.GetNumber();
        miscCommand.m_type.SetTag(H245_MiscellaneousCommand_type::e_videoTemporalSpatialTradeOff);
        PASN_Integer & value = miscCommand.m_type;
        value = videoQuality;
        WriteControlPDU(pdu);
      //}
    }
  }

  // adjust the count of channels we have open
  channelsOpen++;

  PTRACE(2, "Main\tchannelsOpen = " << channelsOpen);

  // if we get to two channels (one open, one receive), then (perhaps) trigger a timeout for shutdown
  // have one channel for video receive, one for video transmit. channelsOpenLimit can be 2,3 or 4.
  if (channelsOpen == myEndpoint.GetChannelsOpenLimit())
    myEndpoint.TriggerDisconnect();

  return TRUE;
}

void MyH323Connection::OnClosedLogicalChannel(H323Channel & channel)
{
  channelsOpen--;
  H323Connection::OnClosedLogicalChannel(channel);
}

BOOL MyH323Connection::OnAlerting(const H323SignalPDU & /*alertingPDU*/,
                                  const PString & username)
{
  PAssert((myEndpoint.uiState == MyH323EndPoint::uiConnectingCall) ||
          (myEndpoint.uiState == MyH323EndPoint::uiWaitingForAnswer) ||
          !myEndpoint.callTransferCallToken,
     psprintf("Alerting received in state %i whilst not waiting for incoming call!", myEndpoint.uiState));

  if (verbose > 0)
    cout << "Ringing phone for \"" << username << "\" ..." << endl;

  myEndpoint.uiState = MyH323EndPoint::uiWaitingForAnswer;

  return TRUE;
}


void MyH323Connection::OnUserInputString(const PString & value)
{
  // GnomeMeeting uses UserInputStrings to send text messages between users.
  // If the string begins "MSG", do not send the string to the LID hardware.

  if (value.Left(3) == "MSG") {
    cout << "User message received: \"" << value.Mid(3) << '"' << endl;
    return;
  }

  cout << "User input received: \"" << value << '"' << endl;

#ifdef HAS_LIDDEVICE
  myEndpoint.SendDTMF(value);
#endif
}


PString MyH323Connection::GetCallerIdString() const
{
  H323TransportAddress addr = GetControlChannel().GetRemoteAddress();
  PIPSocket::Address ip;
  WORD port;
  addr.GetIpAndPort(ip, port);
  DWORD decimalIp = (ip[0] << 24) +
                    (ip[1] << 16) +
                    (ip[2] << 8) +
                     ip[3];
  PString remotePartyName = GetRemotePartyName();
  PINDEX bracket = remotePartyName.Find('[');
  if (bracket != P_MAX_INDEX)
    remotePartyName = remotePartyName.Left(bracket);
  bracket = remotePartyName.Find('(');
  if (bracket != P_MAX_INDEX)
    remotePartyName = remotePartyName.Left(bracket);
  return psprintf("%010li\t\t", decimalIp) + remotePartyName;
}

// End of File ///////////////////////////////////////////////////////////////
