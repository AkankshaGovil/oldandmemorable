OhPhone man page
================
 
 
NAME
  ohphone - initiate, or receive, a H.323 IP telephony call 

SYNOPSIS
  ohphone -l|--listen [options]... 

  ohphone [options]... address   

DESCRIPTION
  ohphone is a command line application that can be used to listen for
  incoming H.323 calls, or to initiate a call to a remote host. Although
  originally intended as a test harneess for the OpenH323 project (see
  http://www.openh323.org) it has developed into a fully functional H.323
  endpoint application. ohphone includes a simple menu that allows interactive
  control of functions, as well as allowing control of most dialling and
  answer functions via a phone handset when used with a Quicknet (see
  http://www.quicknet.com) LineJack or PhoneJack. 

  When used with the -l option, ohphone will wait for incoming calls. If this
  option is not specified, ohphone expects a hostname to be specified and will
  attempt to connect to a H.323 client at that address. 

OPTIONS
  All of the command line options to ohphone can be specified in long form, and
  the most commonly used options also have single character equivalents. The
  long forms can also be used in the ohphone configuration file. To disable or
  turn off a feature, use the long form of the name with the prefix --no-, i.e.
  --no-answer or --no-gsm. 


  -a, --auto-answer 
    Automatically answer incoming calls. 

  --aec, level 
    Set the AEC (audio echo cancellation) level when using a Quicknet card.
    level must be in the range 0 through 3. The default value is 2. 

  -b, --bandwidth bps 
    Limit bandwidth usage reported to gatekeeper to bps bits/second. 

  --callerid 
    Enable transmission of caller ID to phone handset 

  -d, --autodial host 
    Automatically dial host if phone goes off hook. 

  --dial-after-hangup 
    By default ohphone will present a busy tone when a connection is broken,
    requiring the handset to be put on hook before making another call. If
    this flag is specified, a new dialtone will be presented, allowing a new
    connection to be made without requiring an hook transition. 

  --disable-menu 
    Disable the internal menu. 

  -e, --silence 
    Disable silence detection and removal for GSM and software G.711. 

  -f, --fast-disable 
    Do not request H323V2 FastConnect when initiaiting a connection. 

  -h, --h245tunnel-disable 
    Do not perform H245 tunneling when initiating a connection. 

  -g, --gatekeeper host 
    Upon startup, register with only with the specified gatekeeper rather than
    attempting to find a gatekeeper by using UDP broadcast. 

  --g711-ulaw 
    Set G.711 uLaw as preferred codec. 

  --g711-Alaw 
    Set G.711 ALaw as preferred codec. 

  --g7231 
    Set G.723.1 as preferred codec, when using a Quicknet card. 

  --gsm 
    Use GSM 06.10 as preferred codec. 

  --h261 device 
    Enable reception of video data in H.261 format. The device specifies the
    device to be used to display the received video information. Permitted
    values of device are: 

      ppm 
        Create a numbered sequence of PPM files 
      svga256 
        Write directly to the console in 256 colour VGA mode (Linux only) 
      svga 
        Write directly to the console in full-colour VGA mode (Linux only) 
      x1132s 
        Create an X11 window using a TrueColor visual write to using using
        the XShm extensions (Unix systems only) 
      x1132 
        Create an X11 window using a TrueColor visual write to using using
        standard X11 pixmaps 

  -i, --interface interface 
    Only bind to the specified network interface address. By default, ohphone
    automatically listens for incoming calls on all TCP/IP network interfaces
    available on the host machine. This option is useful for running multiple
    copies of ohphone on the same multi-homed machine, or for ensuring that
    only calls from the external, or internal, network will be received on a
    particular handset. 

  -j, --jitter delay 
    Set jitter buffer to delay ms. By default, this is set to 50 ms. 

  -l, --listen 
    Listen for incoming calls. 

  -n, --no-gatekeeper 
    Do not attempt to find a gatetkeeper upon startup using UDP broadcast. 

  -o, --output filename 
    Write trace output (enabled with the -t option) to the specified file
    rather than to stdout. 

  -p, --proxy host 
    Connect to the remote endpoint using the specified H.323 proxy host,
    rather than attempting to connect directly. 

  -playvol vol 
    Set the playback (speaker) volume for Quicknet devices 

  -q, --quicknet num 
    Use the specified Linux telephony device (/dev/phonenum) rather than a
    sound card. This overrides the default of using the sound card. 

  -r, --require-gatekeeper 
    Exit if a gatekeeper cannot be found. 

  -recvol vol 
    Set the record (microphone) volume for Quicknet devices 

  -s, --sound device 
    Select the sound input and output device. The default value is /dev/dsp0. 

  --sound-in, --sound-out device 
    Select the sound input or output device seperately. Only needed if
    different sound devices are needed for input and output. 

  -t, --trace 
    Enable debug tracing, which displays messages at run-time to assist in
    debugging or problem identification. Specifying this option multiple time
    increases the amount of information displayed. ohphone has trace
    statements up to level 5. Use the -o option to write the trace
    information to a file rather than to stdout. 

  -u, --user name 
    Set local endpoint alias name. Can be used multiple times to add multiple
    aliases. By default, the alias list contains a single entry with the
    current user's login name. 

  --videoformat format 
    Set the video capture format. format must be the string pal (default) or ntsc 

  --videoinput input 
    Set input port used for video. The default value is 0 - the maximum value
    is determined by the video device 

  --videoquality quality 
    Set the video qualty requested from the remote endpoint. quality must be
    in the range 0 to 31. 

  --videosize size 
    Set the size of the transmitted video signal. size must be the string
    small (default) or large 


CONFIGURATION FILE
  ohphone options and speed dials can be set in the ohphone configuration
  file ~/.pwlib_config/ohphone.ini . This config file is divided into
  sections, with each section indentified by a header enclosed in square
  brackets. Options must be located in the section prefixed with [Options],
  whilst speed dials must be located in the section prefixed [Speedial]. The
  long form of any command line option specified above can be specified in
  the configuration file, in the format: 

    option = value 

SPEED DIALS
  ohphone can be configured to dial an IP address upon entering a speed
  dial code conisisting of an integer followed by the hash (#) character.
  Speed dial codes are available via the menu "C" command (see the MENU
  section) or via the phone handset (if a Quicknet card is used). ohphone
  Speed dials are configured using the menu "D" command, or can be added
  directly to the [SpeedDials] section of the configuration file (see below). 

DIALLING IP NUMBERS USING A HANDSET
  An IP number can be dialled using a phone handset connected to a Quicknet
  card. This is done by pushing the star (*) button, and then entering the
  IP number using the star (*) button to seperate each of the four parts of
  the IP address, and then pressing the (#) button. For example, the
  sequence below can be used to dial the IP address 192.168.64.5: 

    *192*168*64*5# 

INTERNAL MENU
  ohphone allows the user to perform various operations whilst listening for
  an incoming connection, or whilst a call is in progress. These operations
  are accessed via single line commands which each start with a single
  character identifying the function. The available commands are: 

    Q or X 
      Hangup any active calls and exit the program. 
    H 
      Hangup any active calls. 
    C address [gateway] 
      Initiate a call to the specified host or IP address. If the optional
      getway paramater is used, then the specified gateway will be used to
      make the call. If the address ends with the hash (#) character, it is
      assumed to be a Speed Dial code. 
    L 
      List all current speed dial codes 
    D code address 
      Create a new speed dial for address using code. 
    S 
      Print statistics of the call in progress. 
    P 
      Toggle between speakerphone and normal mode 
    A 
      Turn AEC up by one level (Quicknet cards only) 
    a 
      Turn AEC down by one level (Quicknet cards only) 

EXAMPLES
  ohphone -l 
    Find a gatekeeper on the local network, register with it, and then listen
    for incoming calls. 
  
  ohphone -ln 
    Listen for calls without registering with a gatekeeper. 
  
  ohphone -ln -q0 --callerid 
    Listen for calls without registering with a gatekeeper, using /dev/phone0
    (a Quicknet card) as the sound device, and enabling transmission of caller
    ID to the handset on incoming calls. 
  
  ohphone -n ipaddress 
    Make a call using directly to another endpoint without a gatekeeper 
  
  ohphone -n ipaddress 
    Make a call using directly to another endpoint without a gatekeeper 

FILES
  ~/.pwlib_config/ohphone.ini 

BUGS
  Picking up a handset after initiating a call using the menu C comment
  sometimes produces odd results 
 

                              ------------------------
