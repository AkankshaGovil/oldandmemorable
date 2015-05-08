#
# Makefile
#
# Make file for Open H323 library
#
# Copyright (c) 1998-2000 Equivalence Pty. Ltd.
#
# The contents of this file are subject to the Mozilla Public License
# Version 1.0 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is Open H323 Library.
#
# The Initial Developer of the Original Code is Equivalence Pty. Ltd.
#
# Contributor(s): ______________________________________.
#
# $Log: Makefile,v $
# Revision 1.45  2003/06/12 19:39:09  shawn
# Added shared memory video input/output devices.  Video frames of these two
# devices are stored in a named shared memory region and can be accessed by
# other applications.
#
# Revision 1.44  2003/05/07 02:45:58  dereks
# Alter ohphone to use the PSDLVideoOutputDevice class, which is now part of pwlib.
#
# Revision 1.43  2003/01/06 13:39:53  rogerh
# Remove -static which I added by mistake in the last commit.
# Pointed out by Andreas Wrede
#
# Revision 1.42  2002/11/26 10:20:38  rogerh
# CU30 test is now in openh323u.mak
#
# Revision 1.41  2002/10/14 22:40:54  rogerh
# Add FreeBSD SDL support
#
# Revision 1.40  2002/08/05 10:10:29  robertj
# Normalised Makefile usage of openh323u.mak include file, fixing odd messages.
#
# Revision 1.39  2002/06/05 01:00:46  dereks
# Modify rules to use the correct options when building unix versions of SDL.
#
# Revision 1.38  2002/04/18 05:13:17  robertj
# Changed /usr/include to SYSINCDIR helps with X-compiling, thanks Bob Lindell
#
# Revision 1.37  2002/02/21 01:04:53  dereks
# Add fix from Ryutaroh Matsumoto to fix SDL build for Debian 3.0 testing.
# Many thanks.
#
# Revision 1.36  2001/10/23 02:21:39  dereks
# Initial release CU30 video codec.
# Add --videotest option, to display raw video, but not invoke a call.
#
# Revision 1.35  2001/08/07 21:21:34  dereks
# Thanks Greg Hosler for the test on the presence of SDL
#
# Revision 1.34  2001/08/07 21:19:25  dereks
# Better check for the presence of the unix library SDL
# Code checks in /usr/local/include and /usr/include
#
# Revision 1.33  2001/08/06 04:11:08  dereks
# Modify test for presence of SDL library.
# If SDL is in /usr/local/, support for sdl display is added.
#
# Revision 1.32  2001/05/03 01:55:42  rogerh
# Add test for X Windows. Remove test for IXJ which is in openh323u.mak
#
# Revision 1.31  2001/03/07 01:47:45  dereks
# Initial release of SDL (Simple DirectMedia Layer, a cross-platform multimedia library),
# a video library code.
#
# Revision 1.30  2000/08/21 06:01:36  craigs
# Added call lists and redial capabilities
# Updated documentation
#
# Revision 1.29  2000/05/02 04:32:25  robertj
# Fixed copyright notice comment.
#
# Revision 1.28  2000/04/26 01:07:23  robertj
# Removed tarfile creation target, this is done differently now.
#
# Revision 1.27  2000/04/06 17:08:51  craigs
# Fixed problems when compiling with X11 capable systems
#
# Revision 1.26  2000/04/05 03:16:52  craigs
# Improved ability to compile on systems without X developement headers
#
# Revision 1.25  2000/03/25 01:34:46  craigs
# Changed name from voxilla to ohphone
#
# Revision 1.24  2000/03/09 09:28:35  rogerh
# Make sure all SOURCES are defined before including ptlib.mak
#
# Revision 1.23  2000/03/09 08:28:55  rogerh
# Updated to allow voxilla to compile on systems without X11 installed
#
# Revision 1.22  2000/02/24 11:17:02  craigs
# Fixed problem with making PW projects
#
# Revision 1.21  2000/02/02 04:18:26  craigs
# Changed to use common Makefiles
#
# Revision 1.20  1999/12/09 20:27:16  robertj
# Added build of library when building test app
#
# Revision 1.19  1999/11/29 09:04:35  craigs
# Added xlib files
#
# Revision 1.18  1999/10/28 01:12:34  robertj
# Used platform independent Quicknet support code now in library.
#
# Revision 1.17  1999/09/21 11:00:44  craigs
# Added support for full colour SVGA displays
#
# Revision 1.16  1999/09/21 08:39:01  craigs
# Added complete support for QuickNet G.723.1
# Added support for Linux video
#
# Revision 1.15  1999/09/03 14:05:19  robertj
# Fixed creation of tarball
#
# Revision 1.14  1999/08/25 05:56:11  robertj
# Simplified application
#
# Revision 1.13  1999/08/09 13:40:54  robertj
# Fixed define for TRACING, should be PTRACING
# Also allowed for generating code without tracing.
#
# Revision 1.12  1999/07/26 07:06:12  craigs
# Added support for QuickNet Cards
#
# Revision 1.11  1999/06/25 17:20:18  robertj
# New directory structure.
#
# Revision 1.10  1999/06/14 15:13:25  robertj
# Added pass thru command for make depend
#
# Revision 1.9  1999/06/12 06:56:59  craigs
# Extended clean targets
#
# Revision 1.8  1999/06/09 06:51:57  robertj
# Added tracing to optimised version.
#
# Revision 1.7  1999/06/09 06:18:00  robertj
# GCC compatibiltiy.
#
# Revision 1.6  1999/01/16 11:08:25  robertj
# Added dependency to openh323 library.
# Added copyright header.
#

PROG		= ohphone 
SOURCES		:= main.cxx vidlinux.cxx xlibvid.cxx

ifdef USE_SHM_VIDEO_DEVICES
STDCCFLAGS	+= -DUSE_SHM_VIDEO_DEVICES
SOURCES		+= shmvideo.cxx
endif

ifndef OPENH323DIR
OPENH323DIR=$(HOME)/openh323
endif

include $(OPENH323DIR)/openh323u.mak

#
# only include svgalib support if available on this sytem
#
ifneq (,$(wildcard $(SYSINCDIR)/vga.h))
LDLIBS		+= -lvga
STDCCFLAGS	+= -DHAS_VGALIB
endif

#
# only include X Windows support if available on this sytem
#
ifndef XINCDIR
XINCDIR=/usr/X11R6/include
endif

ifndef XLIBDIR
XLIBDIR=/usr/X11R6/lib
endif

ifneq (,$(wildcard $(XINCDIR)/X11/X.h))
STDCCFLAGS	+= -DHAS_X11
LDFLAGS     	+= -L$(XLIBDIR)
LDLIBS		+= -lXext -lX11
STDCCFLAGS	+= -I$(XINCDIR)
endif   


man:	ohphone.man

ohphone.man:	ohphone.1
	nroff -man ohphone.1 | col -b > ohphone.man

