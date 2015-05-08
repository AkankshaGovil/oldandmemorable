#
# openh323u.mak
#
# Make symbols include file for Open H323 library
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
# The Original Code is Open H323 library.
#
# The Initial Developer of the Original Code is Equivalence Pty. Ltd.
#
# Contributor(s): ______________________________________.
#
# $Log: openh323u.mak.in,v $
# Revision 1.3  2003/08/04 00:03:09  dereksmithies
# Get it to correctly handle tests for H263
#
# Revision 1.2  2003/07/26 03:55:31  dereksmithies
# Upates for Vic H263 codec
#
# Revision 1.1  2003/05/14 19:52:44  csoutheren
# Initial version
#
# Revision 1.45  2003/04/16 04:26:57  dereks
# Initial release of h263 codec, which utilises the ffmpeg library.
# Thanks to Guilhem Tardy, and to AliceStreet.
#
# Revision 1.44  2003/01/06 22:05:42  rogerh
# Make sure NetBSD sets HAS_OSS
#
# Revision 1.43  2003/01/06 21:21:31  rogerh
# Set HAS_OSS on more platforms
#
# Revision 1.42  2002/11/26 10:24:54  rogerh
# Move CU30 test here.
# Add new target 'ccflags' which prints the STDCCFLAGS used by pwlib and
# openh323. This is handy for 3rd party applications.
#
# Revision 1.41  2002/11/22 10:56:41  robertj
# Added PREFIX variable to move the include directory, required by packagers.
#
# Revision 1.40  2002/11/05 02:18:03  robertj
# Changed default for speex codec to be included.
#
# Revision 1.39  2002/11/04 00:37:14  dereks
# Disable usage of speex codec when NO_SPEEX define is set.
#
# Revision 1.38  2002/10/22 08:59:42  rogerh
# Use the imported Speex library
#
# Revision 1.37  2002/10/09 12:58:00  rogerh
# Look for Speex include file in SYSINCDIR. Submitted by Huib Kleinhout.
#
# Revision 1.36  2002/09/23 07:41:29  robertj
# Fixed so builds pwlib before openh323 when go make optlibs
#
# Revision 1.35  2002/08/14 04:26:00  craigs
# Fixed Speex library problem
#
# Revision 1.34  2002/08/14 02:41:08  robertj
# Fixed previous patch, missing parenthesis
#
# Revision 1.33  2002/08/14 02:28:17  robertj
# Added search order for pwlib directory, look in parent to openh323 directory
#   first, then users home directory, then /usr/local.
#
# Revision 1.32  2002/08/13 14:24:51  craigs
# Added Speex codec detection
#
# Revision 1.31  2002/08/05 12:00:18  robertj
# Changed symbol for building library dependent on OpenH323 to be a more
#   a general name.
#
# Revision 1.30  2002/08/05 07:01:25  robertj
# Fixed double inclusion of common.mak
#
# Revision 1.29  2002/04/18 05:14:10  robertj
# Changed /usr/include to SYSINCDIR helps with X-compiling, thanks Bob Lindell
#
# Revision 1.28  2002/01/14 15:38:09  rogerh
# Look for telephony.h in /usr/local/include/sys (which is where the
# FreeBSD Ports Tree copy of the ixj driver puts the header files)
#
# Revision 1.27  2001/11/27 22:48:40  robertj
# Changed to make system to better support non-shared library building.
#
# Revision 1.26  2001/10/09 09:05:24  robertj
# Added LIBDIRS variable so can go "make libs" to build openh323 & pwlib
#
# Revision 1.25  2001/10/05 03:28:18  robertj
# Fixed the inclusion of VPB support if can find the library somewhere.
#
# Revision 1.24  2001/09/11 08:33:05  robertj
# Prevented inclusion of xJack if cross compiling to Nucleus, thanks Nick Hoath
#
# Revision 1.23  2001/09/11 01:24:36  robertj
# Added conditional compilation to remove video and/or audio codecs.
#
# Revision 1.22  2001/05/16 07:35:10  robertj
# New minor version
#
# Revision 1.21  2001/05/03 01:43:55  rogerh
# There is no need to test for X11 as the openh323 library does not use it
#
# Revision 1.20  2001/03/15 11:29:52  rogerh
# use NO_XWINDOWS=1 to compile without X11 support on systems with X11 installed
#
# Revision 1.19  2001/02/10 04:01:50  robertj
# Fixed build system so application can be built NOTRACE to separate directory.
#
# Revision 1.18  2001/02/09 04:44:37  craigs
# Added ability create a NOTRACE version of an exectuable with seperate
# libraries
#
# Revision 1.17  2000/10/30 00:23:56  robertj
# Added auto inclusion of ptlib make rules
#

PWLIBDIR	= /home/akanksha/OhPhoneBuild/openh323/../pwlib
STDCCFLAGS	+= 
LDFLAGS		+= 
ENDLDLIBS	:=  $(ENDLDLIBS)
H323_AVCODEC	= 
H323_VICH263	=       

ifdef LIBRARY_MAKEFILE
include $(PWLIBDIR)/make/unix.mak
else
ifdef NOTRACE
OBJDIR_SUFFIX := n
endif
include $(PWLIBDIR)/make/ptlib.mak
endif


LIBDIRS += $(OPENH323DIR)

#OH323_SUPPRESS_H235	= 1


OH323_SRCDIR = $(OPENH323DIR)/src
ifdef PREFIX
OH323_INCDIR = $(PREFIX)/include/openh323
else
OH323_INCDIR = $(OPENH323DIR)/include
endif
OH323_LIBDIR = $(OPENH323DIR)/lib


ifdef NOTRACE
STDCCFLAGS += -DPASN_NOPRINTON -DPASN_LEANANDMEAN
OH323_SUFFIX = n
else
STDCCFLAGS += -DPTRACING
RCFLAGS	   += -DPTRACING
OH323_SUFFIX = $(OBJ_SUFFIX)
endif

ifdef NOAUDIOCODECS
STDCCFLAGS += -DNO_H323_AUDIO_CODECS
endif

ifdef NOVIDEO
STDCCFLAGS += -DNO_H323_VIDEO
endif



OH323_BASE  = h323_$(PLATFORM_TYPE)_$(OH323_SUFFIX)$(LIB_TYPE)
OH323_FILE  = lib$(OH323_BASE).$(LIB_SUFFIX)

LDFLAGS	    += -L$(OH323_LIBDIR)
LDLIBS	    := -l$(OH323_BASE) $(LDLIBS)

STDCCFLAGS  += -I$(OH323_INCDIR)


ifneq ($(OS),Nucleus)

ifdef	OH323_SUPPRESS_H235
STDCCFLAGS  += -DOH323_SUPPRESS_H235
endif

ifneq (,$(wildcard $(SYSINCDIR)/linux/telephony.h))
HAS_IXJ	    = 1
STDCCFLAGS += -DHAS_IXJ
endif

ifneq (,$(wildcard $(SYSINCDIR)/sys/telephony.h))
HAS_IXJ	    = 1
STDCCFLAGS += -DHAS_IXJ
endif

ifneq (,$(wildcard /usr/local/include/sys/telephony.h))
HAS_IXJ	    = 1
STDCCFLAGS += -DHAS_IXJ -I/usr/local/include
endif

#Check if we have an OSS soundcard.h
ifneq (,$(wildcard $(SYSINCDIR)/linux/soundcard.h))
HAS_OSS	    = 1
STDCCFLAGS += -DHAS_OSS

else

ifneq (,$(wildcard /usr/include/sys/soundcard.h))
HAS_OSS	    = 1
STDCCFLAGS += -DHAS_OSS

else

ifneq (,$(wildcard /usr/include/machine/soundcard.h))
HAS_OSS	    = 1
STDCCFLAGS += -DHAS_OSS

else

ifneq (,$(wildcard $(SYSINCDIR)/soundcard.h))
HAS_OSS	    = 1
STDCCFLAGS += -DHAS_OSS

endif
endif
endif
endif

#Allow disabling of speex codec
ifdef NO_SPEEX
STDCCFLAGS += -DNO_SPEEX
endif
endif # !Nucleus

ifneq (,$(wildcard /usr/local/lib/libcu30.so))
#STDCCFLAGS    += -DHAS_CU30 
#CU30INSTALLED = 1
endif

VPB_LIB := vpb
ifneq (,$(wildcard $(SYSLIBDIR)/lib$(VPB_LIB).a))
VPB_LIB_PATH=$(SYSLIBDIR)
else
ifneq (,$(wildcard /usr/local/lib/lib$(VPB_LIB).a))
VPB_LIB_PATH=/usr/local/lib
else
ifeq ($(OSTYPE),linux)
ifneq (,$(wildcard $(OH323_SRCDIR)/lib$(VPB_LIB).a))
VPB_LIB_PATH=$(OH323_SRCDIR)
else
ifneq (,$(wildcard ./lib$(VPB_LIB).a))
VPB_LIB_PATH=.
endif # current directory
endif # openhrer/src
endif # linux
endif # /usr/local/lib
endif # /usr/lib

ifdef VPB_LIB_PATH
HAS_VPB    := 1
STDCCFLAGS += -DHAS_VPB
LDFLAGS	   += -L$(VPB_LIB_PATH)
LDLIBS	   += -l$(VPB_LIB)
endif


ifdef H323_VICH263
LDFLAGS    += -L/usr/local/lib
LDLIBS     += -lvich263
endif

$(TARGET) :	$(OH323_LIBDIR)/$(OH323_FILE)

ifndef LIBRARY_MAKEFILE
ifdef DEBUG
$(OH323_LIBDIR)/$(OH323_FILE):
	$(MAKE) -C $(OH323_SRCDIR) debug
else
$(OH323_LIBDIR)/$(OH323_FILE):
	$(MAKE) -C $(OH323_SRCDIR) opt
endif
endif

ccflags:
	@echo $(STDCCFLAGS)

# End of file
