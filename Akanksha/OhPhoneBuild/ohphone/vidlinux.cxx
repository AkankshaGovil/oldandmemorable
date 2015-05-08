/*
 * vidlinux.cxx
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
 * $Log: vidlinux.cxx,v $
 * Revision 1.10  2003/03/19 00:51:15  robertj
 * Removed openh323 versions of videoio.h classes as PVideoOutputDevice
 *   descendants for NULL and PPM files added to PWLib.
 *
 * Revision 1.9  2002/12/02 07:42:15  robertj
 * Fixed GNU warning
 *
 * Revision 1.8  2000/05/02 04:32:25  robertj
 * Fixed copyright notice comment.
 *
 * Revision 1.7  2000/04/06 17:08:51  craigs
 * Fixed problems when compiling with X11 capable systems
 *
 * Revision 1.6  1999/11/01 11:50:53  craigs
 * Updated for changes to video interface
 *
 * Revision 1.5  1999/11/01 00:52:00  robertj
 * Fixed various problems in video, especially ability to pass error return value.
 *
 * Revision 1.4  1999/09/21 14:58:19  craigs
 * Fixed problem with SVGAFull mode
 *
 * Revision 1.3  1999/09/21 12:27:18  craigs
 * Fixed problem with incorrect BYTE ordering on VGAFull mode
 *
 * Revision 1.2  1999/09/21 11:00:44  craigs
 * Added support for full colour SVGA displays
 *
 * Revision 1.1  1999/09/21 08:55:11  craigs
 * Added support for Linux video
 *
 *
 */

#include <ptlib.h>
#include "vidlinux.h"

#ifdef HAS_VGALIB
#include <vga.h>

static BYTE rgbto256(const BYTE * rgb)
{
  return (rgb[0] & 0xe0) | ((rgb[1] >> 3) & 0x1c) | ((rgb[2] >> 6) & 0x03);
}

LinuxSVGAOutputDevice::LinuxSVGAOutputDevice(int _numColours)
  : numColours(_numColours)
{
  vgaOk = vga_init() == 0;

  if (vgaOk) {
    if (numColours == 256)
      vgaOk = vga_setmode(G320x200x256) == 0;
    else if (numColours > 256) {
      vgaOk = vga_setmode(G320x200x16M) == 0;
      if (!vgaOk)
        vgaOk = vga_setmode(G320x200x32K) == 0;
    } else
      vgaOk = FALSE;
  }

  if (!vgaOk) {
    vga_setmode(TEXT);
    PError << "cannot open specified svga device" << endl;
  }
}

LinuxSVGAOutputDevice::~LinuxSVGAOutputDevice()
{
  if (vgaOk)
    vga_setmode(TEXT);
}

BOOL LinuxSVGAOutputDevice::Open(const PString &, BOOL)
{
  return TRUE;
}

PStringList LinuxSVGAOutputDevice::GetDeviceNames() const
{
  return PStringList();
}

PINDEX LinuxSVGAOutputDevice::GetMaxFrameBytes()
{
  return 0;
}

BOOL LinuxSVGAOutputDevice::EndFrame()
{
  return TRUE;
}


///////////////////////////////////////////////////////////////

LinuxSVGA256OutputDevice::LinuxSVGA256OutputDevice()
  : LinuxSVGAOutputDevice(256)
{
  if (vgaOk) {
    PINDEX r, g, b, i = 0;
    for (r = 0; r < 8; r++)
      for (g = 0; g < 8; g++)
        for (b = 0; b < 4; b++)
          vga_setpalette(i++, (r * 36) >> 2, (g * 36) >> 2, (b * 85) >> 2);
  }
}

BOOL LinuxSVGA256OutputDevice::SetFrameData(unsigned x, unsigned y,
			                    unsigned w, unsigned h,
					    const BYTE * data,
					    BOOL endFrame)
{
  if (vgaOk) {
    PBYTEArray rgb256(w);

    for (unsigned dy = 0; dy < h; dy++) {
      for (unsigned dx = 0; dx < w; dx++)
        rgb256[dx] = rgbto256(data + dx*3);

      vga_drawscansegment(rgb256.GetPointer(), x, y+dy, w);
    }
  }
  return TRUE;
}

///////////////////////////////////////////////////////////////

LinuxSVGAFullOutputDevice::LinuxSVGAFullOutputDevice()
  : LinuxSVGAOutputDevice(256*256*256)
{
}


BOOL LinuxSVGAFullOutputDevice::SetFrameData(unsigned x, unsigned y,
			                     unsigned w, unsigned h,
					     const BYTE * data,
					     BOOL endFrame)
{
  if (vgaOk) {
    for (unsigned dy = 0; dy < h; dy++) {
      BYTE bgr[3];
      bgr[2] = data[dy*w*3+0];
      bgr[1] = data[dy*w*3+1];
      bgr[0] = data[dy*w*3+2];
      vga_drawscansegment(bgr, x, y+dy, w*3);
    }
  }
  return TRUE;
}


#endif


// End of File ///////////////////////////////////////////////////////////////
