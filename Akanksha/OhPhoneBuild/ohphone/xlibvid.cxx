/*
 * xlibvid.cxx            
 *                           
 *This file contains the class heirachy for 1)creating windows under xlib.
 *                                          2)displaying data on those windows
 *                                          3)converting image formats.
 *
 * Copyright (c) 1999-2000 Indranet Technologies ltd
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
 * The Original Code is Open H323
 * 
 * The Initial Developer of the Original Code is Equivalence Pty. Ltd. 
 * 
 * Contributor(s): Author Derek J Smithies (derek@indranet.co.nz)
 *
 * Note the license of this file was changed to the above with the full
 * permission of the authors.
 *
 * $Log: xlibvid.cxx,v $
 * Revision 1.20  2003/03/18 07:11:34  robertj
 * Removed openh323 versions of videoio.h classes as PVideoOutputDevice
 *   descendants for NULL and PPM files added to PWLib.
 *
 * Revision 1.19  2002/10/08 08:19:19  dereks
 * Fix so compiles with gcc 3.2 (Redhat 8.0)
 *
 * Revision 1.18  2002/06/27 02:17:40  robertj
 * Renamed video format 411 to the correct 420P, thanks Mark Cooke
 *
 * Revision 1.17  2001/05/25 01:14:44  dereks
 * Alter SetFrameSize & OpenWindo to use unsigned variables. Change type of
 * other variables to eliminate compiler warnings.
 *
 * Revision 1.16  2001/05/03 02:28:35  robertj
 * Fixed problem with KDE events, thanks Tom Dolsky
 *
 * Revision 1.15  2000/12/19 22:35:53  dereks
 * Install revised video handling code, so that a video channel is used.
 * Code now better handles the situation where the video grabber could not be opened.
 *
 * Revision 1.14  2000/09/27 03:06:13  dereks
 * Added lots of PTRACE statements to xlib code.
 * Removed X videoMutex from main.cxx & main.h
 * Removed some weird display issues from X code.
 *
 * Revision 1.13  2000/09/15 03:36:29  dereks
 * remove debug message
 *
 * Revision 1.12  2000/09/13 23:58:12  dereks
 * Corrected bug in video display. Now correctly handles 8, 16, 32 bit colour
 * Correctly handles 8 bit grayscale.
 *
 * Revision 1.11  2000/09/08 06:49:14  craigs
 * Removed extensive comment at end of file
 *
 * Revision 1.10  2000/09/08 03:43:00  dereks
 * Fix 8 and 16 bit display options.
 *
 * Revision 1.9  2000/08/21 04:41:58  dereks
 * Add parameter to set a)transmitted video quality and b)number of unchanged
 * blocks that are sent with every frame.
 * Fix some problems introduced with --videopip option.
 *
 * Revision 1.8  2000/08/07 03:47:42  dereks
 * Add picture in picture option (only for  X window display), better handling
 * of X windows. Handles situation where user selects cross on a X window.
 *
 * Revision 1.6  2000/07/03 06:35:20  craigs
 * Added ability for video to work on 24, 16 and 8 bit visuals
 *
 * Revision 1.5  2000/05/02 04:32:25  robertj
 * Fixed copyright notice comment.
 *
 */

#ifdef HAS_X11
#include <X11/Xatom.h>
#include <sys/time.h>
#include <unistd.h>
#include <ptlib.h>
#include <string.h>
#include "xlibvid.h"


int             GenericXlibVideoDevice::nWindowsOpen=0;
Window          GenericXlibVideoDevice::win[2];
Display        *GenericXlibVideoDevice::display;
GC              GenericXlibVideoDevice::gc;
Visual         *GenericXlibVideoDevice::visual; 
PMutex          GenericXlibVideoDevice::videoMutex;
Colormap        GenericXlibVideoDevice::colormap;

int             GenericXlibVideoDevice::pixelDepth;
int             GenericXlibVideoDevice::byteDepth;
BOOL            GenericXlibVideoDevice::useGrayScale;
int             GenericXlibVideoDevice::nGrayColors;
unsigned long   GenericXlibVideoDevice::grayColors[64  ];
float           GenericXlibVideoDevice::grayScaleFactor  ;

int             GenericXlibVideoDevice::redLoose;
int             GenericXlibVideoDevice::greenLoose;
int             GenericXlibVideoDevice::blueLoose;
int             GenericXlibVideoDevice::redPos;
int             GenericXlibVideoDevice::greenPos;
int             GenericXlibVideoDevice::bluePos;

XImage         *GenericXlibVideoDevice::images[4];
BYTE           *GenericXlibVideoDevice::pixels[4];

int             GenericXlibVideoDevice::displayWidth[2];
int             GenericXlibVideoDevice::displayHeight[2];

XShmSegmentInfo ShmXlibVideoDevice::shminfo[4];


//Error handler for messages from X. cannot be included in a class.
int  XLibErrorHandler(Display *dpy,XErrorEvent *ee)
{
#if 0
  cerr<< "Error handler called in "<<getpid()<<endl
      << " Error is "<<::hex<<(int)ee->error_code<<" "
      << (int)ee->request_code<<" "<<(int)ee->minor_code<<::dec<<endl;
  if(ee->error_code==BadDrawable)
    cerr <<"Internal error. Code attempted to manipulate non existant window"<<endl;
#endif
  return(00);
}

void segvhandler(int signo)
{

  cerr<<"##########################################"<<endl;
  cerr<<"##########################################"<<endl;
  cerr<<"SEGV error ("<<signo<<") in pid "<<getpid()<<endl;
  PTRACE(0,"XDisplay\t segvhandler called");
  usleep(1000);
  exit(0);
}



//////////////////////////////////////////////////////////////////////////
//
//  Generic Xlib functions
//
GenericXlibVideoDevice::GenericXlibVideoDevice(const PString & _remoteName,BOOL _isEncoding, 
                                                 BOOL _videoPIP)
{
       videoMutex.Wait();
       PTRACE(3,"Generic\t constructor start.");
       
       remoteName = _remoteName; n_bytes=0; forceDepth = 0;

       isEncoding= _isEncoding;
       videoPIP  = _videoPIP;

       width=0;
       height=0;

       pixels[xIndex(0)]=NULL; pixels[ xIndex(1) ]=NULL;
       images[xIndex(0)]=NULL; images[ xIndex(1) ]=NULL;

       //        XSetErrorHandler(XLibErrorHandler);
       // signal(SIGSEGV,segvhandler);
       videoMutex.Signal();
}

GenericXlibVideoDevice::~GenericXlibVideoDevice()
{ 
  Close();
}

BOOL GenericXlibVideoDevice::Open(const PString &, BOOL)
{
	return TRUE;
}

BOOL GenericXlibVideoDevice::Close()
{
       videoMutex.Wait();
       PTRACE(3,"Xdisplay\t Close Start");
       CloseWindow();
       PTRACE(3,"Xdisplay\tClose DONE");
       videoMutex.Signal();
       return TRUE;
}

PStringList GenericXlibVideoDevice::GetDeviceNames() const
{
	return PStringList();
}

PINDEX GenericXlibVideoDevice::GetMaxFrameBytes()
{
	return 0;
}

BOOL GenericXlibVideoDevice::SetFrameSize (unsigned _width, unsigned _height)
{
    videoMutex.Wait();
    PTRACE(3,"XDisplay\t SetFrameSize Start for the "<<DirectionStr()<<" window" );
     if ((width != _width) || (height != _height)) {
        PTRACE(3,"XDisplay\t Requested internal size of "<<_width<<"x"<<_height);
        PTRACE(3,"XDisplay\t did not match internal size of "<<width<<"x"<<height);
        CloseWindow();               //Close memory for images 
        OpenWindow(_width,_height);  //Allocate memory for images.
     }
     PTRACE(3,"XDisplay\tSetSize DONE for the "<<DirectionStr()<<" window" );
     videoMutex.Signal();

     return TRUE;
}

BOOL GenericXlibVideoDevice::OpenWindow(unsigned _width, unsigned _height)
{
  PTRACE(3,"XDisplay\tOpenWindow of size "<<_width<<"x"<<_height<<
            " "<<DirectionStr()<<" window");
    if ((_width == 0) || (_height == 0))
       return FALSE;     //refuse to open a window containg 0 pixels.
   // save parameters
    width     = _width; 
    height    = _height;
    n_bytes   = width*height;
    useImage0 = 0;


   if(videoPIP && isEncoding) {
     //Need to do picture in picture. Check first if parent exists.
      if(nWindowsOpen==0)
	return FALSE;    //parent does not exist
    }

  // open display and screen
  if (nWindowsOpen==0) {
      display = XOpenDisplay(NULL);  
      if (display == NULL) {
          cerr << "Failed to open display in GenericXlibVideoDevice::OpenWindow"<<endl;
         PTRACE(0,"OpenWindow\t Failed to open display for XWindows");
         return FALSE;
      }
  }
  screen = DefaultScreen(display);


  if(( nWindowsOpen==0 ) && (!DetermineVisualInformation())) {
    XCloseDisplay(display);
    display=NULL;
    return FALSE;
  }

  XSetWindowAttributes attributes;
  int attributeMask = 0;


  attributeMask       |= CWColormap;
  attributes.colormap = colormap;

  attributeMask       |= CWBorderPixel;
  attributes.border_pixel = 0;

  Window   rootWindow;
  if(videoPIP&&isEncoding) {
      rootWindow= win[xReceiveIndex()];
      attributeMask |= CWOverrideRedirect;
      attributes.override_redirect= FALSE;   //Remove border for the inset picture.
   }  else
      rootWindow=RootWindow(display,screen);

  unsigned int xpos,ypos,border_width;

  displayWidth[xIndex()] =width; 
  displayHeight[xIndex()]=height;
  xpos=ypos= 10;
  border_width=5;
  if(videoPIP) {
     if(isEncoding) {
        displayWidth[xIndex()] =width/2; 
        displayHeight[xIndex()]=height/2;
        border_width=0; 
        xpos= displayWidth[xReceiveIndex()] -(width/2);
        ypos= displayHeight[xReceiveIndex()]-(height/2);;
     } else {
        displayWidth[xIndex()] =width*2; 
        displayHeight[xIndex()]=height*2;
      }
  } 

  win[xIndex()] = XCreateWindow(display,
                        rootWindow,
                        xpos,ypos,
                        displayWidth[xIndex()],
                        displayHeight[xIndex()],
                        border_width,
                        pixelDepth,
                        InputOutput,
                        visual,       
                        attributeMask, &attributes);
  if (win[xIndex()] == 0) {
    PTRACE(0,"XDisplay\t Failed to open "<<DirectionStr()<< "window. ");
    cerr << "Allocation of X window failed" << endl;
    if(nWindowsOpen)
       return FALSE;
    FreeColormapInformation();
    n_bytes=0;
    return FALSE;    
  } 

  nWindowsOpen++;
  XSizeHints size_hints;
  size_hints.flags = PSize | PMinSize | PMaxSize;  //Prevent resizing.
  size_hints.min_width =  displayWidth[xIndex()];
  size_hints.max_width =  displayWidth[xIndex()];
  size_hints.min_height = displayHeight[xIndex()];
  size_hints.max_height = displayHeight[xIndex()];

  // Set name of window, used to display receive or send images.
  PString str1;
  if (remoteName *= "Local")
    str1= remoteName;
  else
    str1= PString("From ") & remoteName;
  XSetStandardProperties(display,
                         win[xIndex()],
                         (const char *)str1,
			(const char *)str1, /*remoteName,*/
                         None,0,0,&size_hints); 

  XSelectInput(display, win[xIndex()], 0);
  XMapWindow(display, win[xIndex()]);
  XRaiseWindow(display,win[xIndex()]);
  gc = XCreateGC(display, win[xIndex()], 0, NULL);
  OpenRender();

  wm_delete_window = XInternAtom(display, "WM_DELETE_WINDOW", False); //Handles user selecting cross.
 (void) XSetWMProtocols(display,win[xIndex()], &wm_delete_window, 1);

 PTRACE(3,"XDisplay\t OpenWindow all done, internal size is "<<width<<"x"<<height);
 PTRACE(3,"XDisplay\t OpenWindow. Display size is "<<displayWidth[xIndex()]<<"x"<<displayHeight[xIndex()]);
 PTRACE(3,"XDisplay\t OpenWindow of "<<DirectionStr()<<" window DONE....");
  
  return TRUE;
}

BOOL GenericXlibVideoDevice::DetermineVisualInformation(void)
{

  // get visual information
  XVisualInfo visualTemplate;
  XVisualInfo *visualInfo;

  int count;
  int index;
  int visualIndex;
  BOOL foundVisual;


  visualTemplate.screen = screen;
  visualInfo = XGetVisualInfo(display, VisualScreenMask, &visualTemplate, &count);

  if(!visualInfo) { //No memory available to hold result.
    cerr<<" Failed to obtain information on the available visual formats."<<endl;
    cerr<<" No video display window constructed. Sorry."<<endl;
    PTRACE(3,"XDisplay\t Failed to open buffer to hold intermediate memory result");
    XFree(visualInfo);
    return FALSE;
  }

  foundVisual=FALSE;
  visualIndex=0;
  byteDepth =1;

  //Look for 24||32 bit visual that supports direct or true colour.
  for(index=0; (index<count) && (!foundVisual);index++) 
    if( ((forceDepth == 0) || (forceDepth == 24) || (forceDepth == 32)) &&
        (visualInfo[index].depth >= 24) && (!foundVisual) &&
        ( visualInfo[index].c_class == DirectColor ||
	  visualInfo[index].c_class == TrueColor)       ) {
         visualIndex   = index;
         foundVisual   = TRUE;
         byteDepth     = 4;
    }

  //Look for 16 bit visual that supports direct or true colour.
  for(index=0; (index<count) && (!foundVisual);index++) 
    if( ((forceDepth == 0) || (forceDepth == 16) ) &&
        (visualInfo[index].depth == 16) && (!foundVisual) &&
        ( visualInfo[index].c_class == DirectColor ||
	  visualInfo[index].c_class == TrueColor)       ) {
         visualIndex   = index;
         foundVisual   = TRUE;
         byteDepth     = 2;
    }

#if 0
  //Look for 8 bit visual that supports static colour.
  for(index=0; (index<count) && (!foundVisual);index++) 
    if( ((forceDepth == 0) || (forceDepth == 8) ) &&
        (visualInfo[index].depth == 8) && (!foundVisual) &&
        ( visualInfo[index].c_class == StaticColor)     ) {
         visualIndex   = index;
         foundVisual   = TRUE;
         byteDepth     = 1;
    }
#endif

  //Look for 8 bit visual that supports psuedo colour.
  for(index=0; (index<count) && (!foundVisual);index++) 
    if( ((forceDepth == 0) || (forceDepth == 8) ) &&
        (visualInfo[index].depth == 8) && (!foundVisual) &&
        ( visualInfo[index].c_class == PseudoColor)      )  {
         visualIndex   = index;
         foundVisual   = TRUE;
         byteDepth     = 1;
    }


  if(!foundVisual) {
    if (forceDepth == 0) {
       PTRACE(0,"XDisplay\t Default screen does not support 24 or 16 bit TrueColor,");
       PTRACE(0,"XDisplay\t                           or DirectColor visuals,"      );
       PTRACE(0,"XDisplay\t                           or 8 bit StaticColor visuals" );
       PTRACE(0,"XDisplay\t                           or 8 bit PseudoColor visuals"  );   
     } else 
       PTRACE(0,"XDisplay\t Default screen does not support " << forceDepth << " bit visuals" );

    PTRACE(0,"XDisplay\t No window created, as could not decide on a suitable bit depth.");
    XFree(visualInfo); 
    return FALSE;     
  }

  visual     = visualInfo[visualIndex].visual;
  pixelDepth = visualInfo[visualIndex].depth;

  XFree(visualInfo);

  // if we ended up with a PseudoColor visual, then use 64 level gray scale
  if (visual->c_class != PseudoColor) {
    useGrayScale = FALSE;

    MaskCalc(redPos,   redLoose,   visual->red_mask);
    MaskCalc(greenPos, greenLoose, visual->green_mask);
    MaskCalc(bluePos,  blueLoose,  visual->blue_mask);

    PTRACE(3,"XDisplay\t Display bitmap:RED loose   "<<redLoose  <<"  at "<<redPos);
    PTRACE(3,"XDisplay\t Display bitmap:GREEN loose "<<greenLoose<<"  at "<<greenPos);
    PTRACE(3,"XDisplay\t Display bitmap:BLUE loose  "<<blueLoose <<"  at "<<bluePos);

    colormap =  XCreateColormap(display, RootWindow(display, screen), visual, AllocNone);

  } else {
    useGrayScale = TRUE;
    
    colormap=DefaultColormap(display,screen); 

    PTRACE(3,"XDisplay\t Finished finding gray colormap.");

     
    AllocGrays(64);
    if(nGrayColors<4) {
        PTRACE(0,"XDisplay\t No window created, as could not create 8 bit gray scale window.");
        return FALSE;     
    }

    pixelDepth            = 8;
    byteDepth             = 1;
  }
  return TRUE;
}

void GenericXlibVideoDevice::MaskCalc(int & startPos, int & looseNBits, int visualMask)
{
  /*The source data (from the YUV 420P image) is three bytes, one each for RGB.
    These three bytes have to be transformed into the N bit per pixel display.
    Some part of each of the three bytes will have to be lost.
   EG (abcd efgh)  (klmn opqr)  (stuv wxyz) are the three source RGB bytes.
      Want to display on a 15 bit display    (15 makes the description easy)
      Thus, each of the three bytes will have to have three bits deleted.
            the bytes will need to be shifted, one 10 bits, one 5 bits, one not.

   The source data will transformed into::
     abcde klmno stuvw

   From this Mask calc routine, we need to know how many bits to truncate,
                                                how many bits to shift to display.
  */
  // look for starting position
  int pos=0,wid;
  if(visualMask==0) 
    return;
      
  while ((visualMask & (1 << pos)) == 0)
    pos++;
  startPos=pos;

  //look for ending position.
  while ((visualMask & (1 << pos)) != 0)
    pos++;   
  wid=pos-startPos;

  looseNBits= 8-wid;
}

void GenericXlibVideoDevice::CloseWindowOfType(BOOL closeEncoder)
{
  int isEncodingOld;
  
  isEncodingOld= isEncoding;
  isEncoding   = closeEncoder;
  usleep(1000);
  CloseRender();
  XFlush(display);
  XDestroyWindow(display,win[xIndex()]);
  XFlush(display);
  win[xIndex()]= (Window)NULL;
  nWindowsOpen--;
  isEncoding= isEncodingOld;
}



void GenericXlibVideoDevice::CloseWindow()
{
  PTRACE(3,"XDisplay\t Close the "<<DirectionStr()<<" window.");
  if(!(width||height)) {
    PTRACE(3,"XDisplay\tAttempting to close 0x0 sized window. So do nothing");
    return;
  }
  //Do the special case first. The act of closing the
  //receive window (if PIP is on) should first close the
  //local window.
    if((nWindowsOpen==2)&& videoPIP&&(!isEncoding)) {
        PTRACE(3,"XDisplay\t Close the local video window in a PIP setup.");
        CloseWindowOfType(TRUE); //close local window here.
        
    }

   if(nWindowsOpen==1) {   
      PTRACE(3,"XDisplay\t close the last remaining window");
      FreeColormapInformation();
      XFreeGC(display, gc);
      CloseWindowOfType(isEncoding);
      XCloseDisplay(display);
      display=NULL;
   }

    if(nWindowsOpen==2) {
      PTRACE(3,"XDisplay\t Close the 2nd window - no display change");
      CloseWindowOfType(isEncoding);
    }
    width=0;
    height=0;
}

void GenericXlibVideoDevice::FreeColormapInformation(void)
{
       XFreeColormap(display, colormap);
}

void GenericXlibVideoDevice::AllocGrays(int num)
{
  XColor xcol;
  int i;

  if (num < 4) {
    nGrayColors=0;
    PTRACE(0,"XDisplay\t Error allocating grayscale colormap.");
    return;
  }
  if (num > 128) num = 128;
  for (i = 0; i < num; ++i) {
        xcol.red = xcol.green = xcol.blue = 65535*i/(num-1);
                xcol.flags = DoRed | DoGreen | DoBlue;
                if (!XAllocColor(display, colormap, &xcol)) {
                  if (i) 
                      XFreeColors(display, colormap, grayColors, i, 0);
                  AllocGrays(num/2);
                  return;
                }
                grayColors[i] = xcol.pixel;
  }
  nGrayColors= num;
  grayScaleFactor= nGrayColors/((float)255.0);
  PTRACE(3,"XDisplay\t Allocated "<<nGrayColors<<" for 8 bit display");
}





#define LIMIT(x) (BYTE)(((x>0xffffff)?0xff0000:((x<=0xffff)?0:x&0xff0000))>>16)

void GenericXlibVideoDevice::Translate420PInput(BYTE *d, const void *frame)
{	
  const BYTE * yplane  = (const BYTE *) frame;
  const BYTE * yplane2 = yplane + width;
  const BYTE * uplane  = yplane + n_bytes;
  const BYTE * vplane  = yplane + n_bytes + (n_bytes >> 2);

  long Y,Cr,Cb;
  long l,lr2,lg2,lb2;
  long lr,lb,lg;
  unsigned  x, y,gray;
  unsigned    r,g,b;
#ifdef REPORT_TIMES
  struct timeval t1,t2;
  gettimeofday(&t1,NULL);
#endif

  //In the YUV frame, there are four Y pixels for every UV pair.
  //Thus, calculate the Cr and Cb values for a UV pair, and then
  //determine the RGB values for each of the four Y Pixels.


#define CALCULATE         Cr = *(uplane++) - 128;   /* First, get Cb and Cr.*/\
                          Cb = *(vplane++) - 128;      \
                          lr2 = 104635 * Cb;        \
                          lg2 = -25690 * Cr + -53294 * Cb;   \
                          lb2 = 132278 * Cr



#define GETRGB(yp)  Y= *(yp++) -16; \
                    if(Y<0) Y=0;  l = 76310 * Y;      \
                    lr = l + lr2;       \
                    lg = l + lg2;       \
                    lb = l + lb2;       \
                    r = LIMIT(lr);      \
                    g = LIMIT(lg);      \
                    b = LIMIT(lb);     


#define GRAYPIXEL(yp,dtype,d)  { GETRGB(yp);               \
    gray = (int)((r * 0.299) + (g * 0.587) + (b * 0.114)); \
    if (gray > 255)                                        \
      gray = 255;                                          \
    else if (gray < 0)                                     \
      gray = 0;                                            \
    *((dtype *)(d)) = grayColors[((int)(gray * grayScaleFactor))]; }

#define RGBPIXEL(yp,dtype,d) { GETRGB(yp);       \
                 *((dtype *)(d))=((r >> redLoose)  << redPos)   |\
                                    ((g >> greenLoose)<< greenPos) |\
                                    ((b >> blueLoose) << bluePos); }

#define YUVCONVERT(sw,dtype,d1,d2,d3,d4)         \
  { /*Handle the case for LARGE IMAGE */         \
  if(videoPIP&&(!isEncoding)){                   \
      d1= ((dtype *)d);                          \
      d2= ((dtype *)d) + (width*2);              \
      d3= ((dtype *)d) + (width*4);              \
      d4= ((dtype *)d) + (width*6);              \
      for(y=0;y<height;y+=2) {                   \
         for(x=0;x<width;x+=2) {                 \
           CALCULATE ;                           \
           if(sw==1)                             \
             RGBPIXEL(yplane,dtype,d1)           \
            else                                 \
             GRAYPIXEL(yplane,dtype,d1)          \
           *(d1+1)=*d1;                          \
           *(d2++)=*d1;                          \
           *(d2++)=*d1;                          \
           d1+=2;                                \
           if(sw==1)                             \
             RGBPIXEL(yplane,dtype,d1)           \
            else                                 \
             GRAYPIXEL(yplane,dtype,d1)          \
           *(d1+1)=*d1;                          \
           *(d2++)=*d1;                          \
           *(d2++)=*d1;                          \
           d1+=2;                                \
           if(sw==1)                             \
             RGBPIXEL(yplane2,dtype,d3)          \
            else                                 \
             GRAYPIXEL(yplane2,dtype,d3)         \
           *(d3+1)=*d3;                          \
           *(d4++)=*d3;                          \
           *(d4++)=*d3;                          \
           d3+=2;                                \
           if(sw==1)                             \
             RGBPIXEL(yplane2,dtype,d3)          \
            else                                 \
             GRAYPIXEL(yplane2,dtype,d3)         \
           *(d3+1)=*d3;                          \
           *(d4++)=*d3;                          \
           *(d4++)=*d3;                          \
           d3+=2;                                \
          }                                      \
       d1+=width*6;                              \
       d2+=width*6;                              \
       d3+=width*6;                              \
       d4+=width*6;                              \
       yplane+=width;                            \
       yplane2+=width;                           \
     }                                           \
 } else if(videoPIP&&isEncoding) {               \
          d1= (dtype *)d;                        \
          for(y=0;y<height;y+=2) {               \
             for(x=0;x<width;x+=2) {             \
               CALCULATE ;                       \
               if(sw==1)                         \
                  RGBPIXEL(yplane,dtype,d1)      \
                else                             \
                  GRAYPIXEL(yplane,dtype,d1)     \
               d1++;                             \
               yplane++;                         \
              }                                  \
           yplane+=width;                        \
           }                                     \
       } else {                                  \
         d1= (dtype *)d;                         \
         d2= d1+width;                           \
         for(y=0;y<height;y+=2) {                \
           for(x=0;x<width;x+=2) {               \
             CALCULATE ;                         \
             if(sw==1)                           \
                RGBPIXEL(yplane,dtype,d1)        \
              else                               \
                GRAYPIXEL(yplane,dtype,d1)       \
             d1++;                               \
             if(sw==1)                           \
                RGBPIXEL(yplane,dtype,d1)        \
              else                               \
                GRAYPIXEL(yplane,dtype,d1)       \
             d1++;                               \
             if(sw==1)                           \
                RGBPIXEL(yplane2,dtype,d2)       \
              else                               \
                GRAYPIXEL(yplane2,dtype,d2)      \
             d2++;                               \
             if(sw==1)                           \
                RGBPIXEL(yplane2,dtype,d2)       \
              else                               \
                GRAYPIXEL(yplane2,dtype,d2)      \
             d2++;                               \
            }                                    \
         d1+=width;                              \
         d2+=width;                              \
         yplane+=width;                          \
         yplane2+=width;                         \
        }                                        \
      }                                          \
   }

  if(byteDepth==4) {
     u_int32_t *dest1, *dest2, *dest3, *dest4;
      if(useGrayScale)
       YUVCONVERT(0,u_int32_t,dest1,dest2,dest3,dest4)
      else
       YUVCONVERT(1,u_int32_t,dest1,dest2,dest3,dest4)
  } 
  if(byteDepth==2) {
     u_int16_t *dest1, *dest2, *dest3, *dest4;
     if(useGrayScale)
       YUVCONVERT(0,u_int16_t,dest1,dest2,dest3,dest4)
      else
       YUVCONVERT(1,u_int16_t,dest1,dest2,dest3,dest4)
  }
  if(byteDepth==1) {
     u_int8_t *dest1, *dest2, *dest3, *dest4;
     if(useGrayScale)
       YUVCONVERT(0,u_int8_t,dest1,dest2,dest3,dest4)
      else
       YUVCONVERT(1,u_int8_t,dest1,dest2,dest3,dest4)
  }

#ifdef REPORT_TIMES
  int diffrence;
  static int total_diff_enc=0;
  static int total_diff_dec=0;
  static int framesdone_enc=0;
  static int framesdone_dec=0;
  gettimeofday(&t2,NULL);
  if(t1.tv_sec<t2.tv_sec)
    diffrence=1000000;
   else
    diffrence=0;
  diffrence+= t2.tv_usec-t1.tv_usec;
  if(isEncoding) {
     total_diff_enc+=diffrence;
     framesdone_enc++;
   } else {
      total_diff_dec+=diffrence;
      framesdone_dec++;
  }
  if(framesdone_enc>100){
        cerr<<getpid()<< "average 100 frames enc"<<
              total_diff_enc/framesdone_enc<<endl;
    framesdone_enc=0;
    total_diff_enc=0;
   }
  if(framesdone_dec>100){
      cerr<<getpid()<< "average 100 frames dec"<<
               total_diff_dec/framesdone_dec<<endl;
    framesdone_dec=0;
    total_diff_dec=0;
   }
#endif
  return;
}

BOOL GenericXlibVideoDevice::SetFrameData(unsigned x, unsigned y,
			                  unsigned w, unsigned h,
					  const BYTE * data,
					  BOOL endFrame)
{
  videoMutex.Wait();
  PTRACE(6,"XDisplay\t Redraw START "<<DirectionStr()<<" window.");
  if(win[xIndex()]) {
    XEvent event;
    if(XEventsQueued(display,QueuedAfterFlush)) {
      XNextEvent(display,&event);
      switch (event.type) {
        case ClientMessage:
          PTRACE(3,"XDisplay\t ClientMessage: Cross in X window selected.");
          CloseWindow();
        default:
          PTRACE(4,"XDisplay\t Message " << event.type);
      }
    }
  }
  if(videoPIP&&isEncoding&&width&&height&&(!win[xIndex()])&& display) 
       OpenWindow(width,height); 
      //The display is open. doing PIP, but there is no local window.
      //There should be a local window, so open it.

  if(width&&height&&win[xIndex()]) {
     PTRACE(6,"XDisplay\t  Window all ready for "<<DirectionStr()<< " display");
     Translate420PInput(pixels[xIndex(useImage0)], data);
     XImage * xi = images[xIndex(useImage0)];
     DisplayImage(xi);
     useImage0 = 1 - useImage0;
  } 

  PTRACE(6,"XDisplay\t Redraw FINISH "<<DirectionStr()<<" window.");
  videoMutex.Signal();
  return TRUE;
}


BOOL GenericXlibVideoDevice::EndFrame()
{
  return TRUE;
}


BOOL  GenericXlibVideoDevice::IsOpen()
{
  return nWindowsOpen > 0 ;
}

 

//////////////////////////////////////////////////////////////////////////
//
//  Shared memory Xlib functions
//

void ShmXlibVideoDevice::OpenRender(void)
{
  PTRACE(3,"XDisplayShm\t Open Render, label "<<DirectionStr());
  for(int i=0;i<2;i++) {
     CreateShmXImage(&images[ xIndex(i) ], &shminfo[xIndex(i)]);
     pixels[xIndex(i)] = (BYTE *)shminfo[xIndex(i)].shmaddr;
  }
}

void ShmXlibVideoDevice::CloseRender()
{   
   PTRACE(3,"XDisplayShm\t Close Render, label "<<DirectionStr());
   for(int i=0;i<2;i++) 
     DestroyShmXImage(&images[ xIndex(i) ], &shminfo[xIndex(i)]);
}

void ShmXlibVideoDevice::CreateShmXImage(XImage **image, XShmSegmentInfo *xsi)
{

  int w1,h1;

  w1=displayWidth[xIndex()];
  h1=displayHeight[xIndex()];

  *image = XShmCreateImage(display,
                           visual,
                           pixelDepth,
                           ZPixmap,
                           NULL,
                           xsi,
                           w1,h1);

    if ((*image) == NULL) {
       cerr << "Failed to create shared memory image" << endl; 
       return;
    }
    //   XInitImage(*image);

   xsi->shmid = shmget(IPC_PRIVATE,
                      w1 * h1 * byteDepth,
                      IPC_CREAT | 0777 );
  if(xsi->shmid<0) {
    PTRACE(0,"XDisplayShm\t Failed to create shared memory area" );
    return;
  }

  xsi->shmaddr = (*image)->data = (char *)shmat(xsi->shmid,0 ,0);
  if (xsi->shmaddr == (char *) -1) {
    PTRACE(0,"XDisplayShm\t Failed to assign shared memory area to image->data");
    return;
  }
  xsi->readOnly = False;
  if(!XShmAttach(display, xsi)) {
    PTRACE(0,"XDisplayShm\t Failed to attach shared memory area to X server");
    return;
  }
}

void ShmXlibVideoDevice::DestroyShmXImage(XImage **image, XShmSegmentInfo *xsi)
{
  struct shmid_ds shared_ds;
  if ((*image) != NULL) {
    XShmDetach(display,xsi);
    XDestroyImage(*image);
    shmdt(xsi->shmaddr);
    shmctl(xsi->shmid,IPC_RMID,&shared_ds);          
    *image=NULL;
    }
}
 
void ShmXlibVideoDevice::DisplayImage(XImage *xi)
{ 
  XShmPutImage(display,win[xIndex()],gc,xi,0,0,0,0, xi->width,xi->height,False);
}

//////////////////////////////////////////////////////////////////////////
//
//  Non-shared memory Xlib functions
//

void XlibVideoDevice::OpenRender(void)
{
  PTRACE(3,"XDisplayNonShm\t Open Render, label "<<DirectionStr());
  for(int i=0;i<2;i++)
    CreateXImage(&images[ xIndex(i) ], &pixels[ xIndex(i) ]);
}

void XlibVideoDevice::CloseRender()
{
  PTRACE(3,"XDisplayNonShm\t Close Render, label "<<DirectionStr());

  for(int i=0;i<2;i++)
    if(images[ xIndex(i) ]) {  
      XDestroyImage(images[ xIndex(i) ]);
      images[ xIndex(i) ]=NULL;
    }
}

void XlibVideoDevice::CreateXImage(XImage **image, BYTE ** pixelData)
{
  int w1,h1;

  w1=displayWidth[xIndex()];
  h1=displayHeight[xIndex()];

  *pixelData = (BYTE *)runtime_malloc(w1 * h1 * byteDepth);

  if ((*pixelData) == NULL) {
    PTRACE(0,"XDisplayNonShm\t Failed to allocate storage for pixel data");
    cerr << "Failed to allocate storage for pixel data" << endl;
    return;
  }
  *image = XCreateImage(display,
                        visual,
                        pixelDepth,
                        ZPixmap,
                        0,
                        (char *)*pixelData,
                        w1, h1,
                        8, 0);
  if ((*image) == NULL) {
    cerr << "Failed to create X image" << endl;
    return;
  }

  XInitImage(*image);
}

void XlibVideoDevice::DestroyXImage(XImage **image)
{
  if (*image != NULL)
    XDestroyImage(*image);
}

void XlibVideoDevice::DisplayImage(XImage *xi)
{
  XPutImage(display,win[xIndex()],gc,xi,0,0,0,0, xi->width,xi->height);
}   



#endif

// HAS_X11
