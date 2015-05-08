/*
 * vidlinux.h
 *
 * Linux video interface
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
 * $Log: vidlinux.h,v $
 * Revision 1.10  2003/03/19 00:51:15  robertj
 * Removed openh323 versions of videoio.h classes as PVideoOutputDevice
 *   descendants for NULL and PPM files added to PWLib.
 *
 * Revision 1.9  2000/08/07 03:47:42  dereks
 * Add picture in picture option (only for  X window display), better handling
 * of X windows. Handles situation where user selects cross on a X window.
 *
 * Revision 1.8  2000/05/02 04:32:25  robertj
 * Fixed copyright notice comment.
 *
 * Revision 1.7  2000/04/06 17:08:51  craigs
 * Fixed problems when compiling with X11 capable systems
 *
 * Revision 1.6  2000/03/25 01:34:47  craigs
 * Changed name from voxilla to ohphone
 *
 * Revision 1.5  1999/11/29 09:03:42  craigs
 * Added X11 video capability
 *
 * Revision 1.4  1999/11/01 11:50:53  craigs
 * Updated for changes to video interface
 *
 * Revision 1.3  1999/11/01 00:52:00  robertj
 * Fixed various problems in video, especially ability to pass error return value.
 *
 * Revision 1.2  1999/09/21 11:00:44  craigs
 * Added support for full colour SVGA displays
 *
 * Revision 1.1  1999/09/21 08:53:35  craigs
 * Added support for Linux video
 *
 *
 */

#ifndef _OhPhone_VIDLINUX_H
#define _OhPhone_VIDLINUX_H

#ifdef P_LINUX

#ifdef HAS_VGALIB

#include <ptlib.h>


/**Displays video on SVGA screen, Linux only.
  */
class LinuxSVGAOutputDevice : public PVideoOutputDevice
{
  PCLASSINFO(LinuxSVGAOutputDevice, PVideoOutputDevice);
 
  public:
  /**Constructor
   */
    LinuxSVGAOutputDevice(int colours);
   
    /**Destructor
     */
    ~LinuxSVGAOutputDevice();

  /**Open the device given the device name.
    */
  virtual BOOL Open(
    const PString & deviceName,   /// Device name to open
    BOOL startImmediate = TRUE    /// Immediately start device
  );
      
  BOOL IsOpen() { return vgaOk; }

  /**Get a list of all of the drivers available.
   */
  virtual PStringList GetDeviceNames() const;

  /**Get the maximum frame size in bytes.
   */
  virtual PINDEX GetMaxFrameBytes();

   /**Indicate frame may be displayed.
    */
   virtual BOOL EndFrame();

  protected:
    /**internal variable.
     */
    BOOL vgaOk;

    /**internal variable.
     */
    int numColours;
}; 

/**Linux SVGA output, 256 colours only
  */
class LinuxSVGA256OutputDevice : public LinuxSVGAOutputDevice
{
  PCLASSINFO(LinuxSVGA256OutputDevice, LinuxSVGAOutputDevice);

  public:
  /**Constructor
   */
    LinuxSVGA256OutputDevice();

   /**Set a section of the output frame buffer.
     */
   virtual BOOL SetFrameData(
     unsigned x,
     unsigned y,
     unsigned width,
     unsigned height,
     const BYTE * data,
     BOOL endFrame = TRUE
   );
};

/**Linux SVGA outptut, no limit on the number of colours.
  */
class LinuxSVGAFullOutputDevice : public LinuxSVGAOutputDevice
{
  PCLASSINFO(LinuxSVGAFullOutputDevice, LinuxSVGAOutputDevice);


  public:
  /**Constructor
   */
    LinuxSVGAFullOutputDevice();

   /**Set a section of the output frame buffer.
     */
   virtual BOOL SetFrameData(
     unsigned x,
     unsigned y,
     unsigned width,
     unsigned height,
     const BYTE * data,
     BOOL endFrame = TRUE
   );
};


#endif

#endif

#endif


// End of File ///////////////////////////////////////////////////////////////
