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
# Revision 1.108  2003/08/04 00:03:29  dereksmithies
# Reorganise tests for H263 codecs
#
# Revision 1.107  2003/07/29 12:34:18  csoutheren
# Changed to ensure dynamic libraries dynamically link pwlib
#
# Revision 1.106  2003/07/26 03:54:30  dereksmithies
# Fixes for New H263 support from ffmpeg and Vic H263
#
# Revision 1.105  2003/06/06 03:55:52  rjongbloed
# Added missing iLBC file.
#
# Revision 1.104  2003/06/06 02:37:05  rjongbloed
# Fixed iLBC build
#
# Revision 1.103  2003/06/06 02:19:04  rjongbloed
# Added iLBC codec
#
# Revision 1.102  2003/05/14 20:37:29  csoutheren
# Changed for new AVC
#
# Revision 1.101  2003/05/05 12:14:03  robertj
# Removed internal ldap as now use OpenLDAP
#
# Revision 1.100  2003/04/23 00:14:31  craigs
# More changes for MacOSX per Shawn Hsiao
#
# Revision 1.99  2003/04/16 04:26:57  dereks
# Initial release of h263 codec, which utilises the ffmpeg library.
# Thanks to Guilhem Tardy, and to AliceStreet.
#
# Revision 1.98  2003/04/01 01:07:58  robertj
# Split service control handlers from H.225 RAS header.
#
# Revision 1.97  2003/03/24 23:14:14  robertj
# Speex update
#
# Revision 1.96  2003/03/18 07:34:03  robertj
# Fixed problem with constructing LD_LIBRARY_PATH on Solaris
#
# Revision 1.95  2003/03/18 04:25:04  robertj
# Added Peer Element client for H.323 Annex G
#
# Revision 1.94  2003/03/17 22:22:27  robertj
# Removed videoio module, now in pwlib.
#
# Revision 1.93  2003/03/04 01:57:12  robertj
# Re-added h501pdu module
#
# Revision 1.92  2003/02/25 07:09:05  robertj
# More work on PDU transaction abstraction.
#
# Revision 1.91  2003/02/25 04:20:45  robertj
# Added H.323 Annex G support (incomplete)
#
# Revision 1.90  2002/11/27 11:52:37  robertj
# Fixed ASN file dependencies to .dep files.
# Fixed number of backslashes, goes with new classheader command in asnparser.
#
# Revision 1.89  2002/11/27 06:54:52  robertj
# Added Service Control Session management as per Annex K/H.323 via RAS
#   only at this stage.
# Added H.248 ASN and very primitive infrastructure for linking into the
#   Service Control Session management system.
# Added basic infrastructure for Annex K/H.323 HTTP transport system.
# Added Call Credit Service Control to display account balances.
#
# Revision 1.88  2002/11/26 14:14:48  craigs
# Added H245_AudioCapability::PrintOn
#
# Revision 1.87  2002/11/26 10:24:06  rogerh
# Move CU30 check up one level to openh323u.mak
#
# Revision 1.86  2002/11/22 10:22:03  robertj
# Adde missing optimiser flags to build rule, thanks Xiaodan Tang
#
# Revision 1.85  2002/11/15 06:10:25  robertj
# Added remaining H.450 ASN files and fixed all their dependencies.
#
# Revision 1.84  2002/11/06 22:58:29  robertj
# Renamed gsm and speex lpc.c
#
# Revision 1.83  2002/11/01 04:13:30  robertj
# Changed HAS_SPEEX to be NO_SPEEX so is included by default.
#
# Revision 1.82  2002/10/31 21:36:00  dereks
# Speex code is included, only if the HAS_SPEEX define is on.
#
# Revision 1.81  2002/10/22 11:57:09  rogerh
# Fix big-endian selection
#
# Revision 1.80  2002/10/22 11:15:46  rogerh
# Support speex on big endian machines
#
# Revision 1.79  2002/10/22 10:48:28  rogerh
# Compile the imported Speex codec library
#
# Revision 1.78  2002/09/23 07:28:52  robertj
# Added LDAP support, thanks Martin Froehlich and mediaWays!
#
# Revision 1.77  2002/08/15 08:15:22  robertj
# Removed EXPAT check for opalvxml file as has non expat stuff in it.
#
# Revision 1.76  2002/08/13 14:25:43  craigs
# Added Speex codec
#
# Revision 1.75  2002/08/05 12:00:18  robertj
# Changed symbol for building library dependent on OpenH323 to be a more
#   a general name.
#
# Revision 1.74  2002/07/19 01:51:41  robertj
# Fixed up directory defaults for openh323 directory.
#
# Revision 1.73  2002/07/03 01:53:13  craigs
# Added opalvxml.cxx
#
# Revision 1.72  2002/06/27 04:15:18  robertj
# Added empty (non operational) G.729 codec to build.
#
# Revision 1.71  2002/06/26 02:53:28  robertj
# Fix to automatic inclusion of pwlib directory in LD_LIBRARY_PATH
#
# Revision 1.70  2002/06/25 00:06:59  robertj
# Added H.450.10 and H.450.11 ASN files to makefile
#
# Revision 1.69  2002/06/20 03:13:07  robertj
# Added opalwavfile
#
# Revision 1.68  2002/05/21 04:24:34  robertj
# Added RTP to WAV file filter class.
#
# Revision 1.67  2002/04/02 22:27:16  rogerh
# Make ldap.asn generate ldap_asn.h and ldap_asn.cxx.
# This makes compilation easier on systems which have ldap.h installed
# from the Unix OpenLDAP library and means we do not have to be as strict
# with the ordering of the include file paths to the compiler.
#
# Revision 1.66  2002/03/10 15:53:45  robertj
# Fixed version number of shared library, tnanks lurch@gmx.li
#
# Revision 1.65  2002/02/11 06:20:07  robertj
# Moved version.h to root directory so have one for the library and not just
#   the sample application. SimpH323 uses the library version so they remain
#   in sync.
#
# Revision 1.64  2002/02/08 12:15:53  robertj
# Fixed error introduced in previous change, lost lpc10!
#
# Revision 1.63  2002/02/08 11:29:22  robertj
# Added G.726 codec, thanks Tiziano Morganti
#
# Revision 1.62  2002/01/23 09:15:50  rogerh
# Add export to setting of LD_LIBRARY_PATH so it works on FreeBSD and Solaris
#
# Revision 1.61  2002/01/23 05:19:44  craigs
# Added RFC2833 to makefile
#
# Revision 1.60  2002/01/14 00:09:31  robertj
# Added H.450.6, thanks Ben Madsen of Noorwood Systems.
#
# Revision 1.59  2001/12/17 23:35:22  robertj
# Compatibility with non GNU diff, eg Solaris, thanks James Dugal
#
# Revision 1.58  2001/11/27 22:48:40  robertj
# Changed to make system to better support non-shared library building.
#
# Revision 1.57  2001/10/23 02:17:16  dereks
# Initial release of cu30 video codec.
#
# Revision 1.56  2001/09/11 08:25:51  robertj
# Added support for cross compiling by defining HOST_PLATFORM_TYPE variable
#   so correct asnparser is executed.
# Added automatic setting of LD_LIBARY_PATH variable for asnparser.
#
# Revision 1.55  2001/09/11 01:24:36  robertj
# Added conditional compilation to remove video and/or audio codecs.
#
# Revision 1.54  2001/09/04 01:50:37  robertj
# Split h225.cxx into two files to reduce compiler memory requirement.
#
# Revision 1.53  2001/08/13 11:11:15  robertj
# Changed test to -f as Solaris does not understand -e
#
# Revision 1.52  2001/08/10 11:18:15  robertj
# Major changes to H.235 support in RAS to support server.
#
# Revision 1.51  2001/08/06 05:35:24  robertj
# Removed h323securoty files.
#
# Revision 1.50  2001/07/24 08:35:23  craigs
# Added gkserver
#
# Revision 1.49  2001/07/17 07:58:27  robertj
# Fixed missing products of T.38 ASN compile
#
# Revision 1.48  2001/07/17 04:44:29  robertj
# Partial implementation of T.120 and T.38 logical channels.
#
# Revision 1.47  2001/06/30 06:50:22  yurik
# Jac Goudsmit from Be submit these changes 6/28
#
# Revision 1.46  2001/06/18 07:44:21  craigs
# Made to compile with h225ras.cxx under Linux
#
# Revision 1.45  2001/06/05 04:38:47  robertj
# Added dependency of h225 on h245
#
# Revision 1.44  2001/06/05 04:08:48  robertj
# Updated H.225 ASN file to v4
#
# Revision 1.43  2001/05/31 07:16:27  craigs
# Added use of new PWlib OpenSSL detection
#
# Revision 1.42  2001/05/01 13:59:04  rogerh
# back out last change
#
# Revision 1.41  2001/05/01 11:03:35  rogerh
# Only build h235security on systems with OpenSSL defined
# (fixes BSD gmake optdepend problems)
#
# Revision 1.40  2001/05/01 06:06:32  robertj
# Added H.450.4 call hold (Near End only), thanks David M. Cassel.
#
# Revision 1.39  2001/05/01 04:28:54  robertj
# Fixed accidental removal of h235security.cxx when doing make clean, thanks Chih-Wei Huang
#
# Revision 1.38  2001/04/11 22:10:47  robertj
# Added H.450.2 (call transfer), thanks a LOT to Graeme Reid & Norwood Systems
#
# Revision 1.37  2001/03/21 04:52:40  robertj
# Added H.235 security to gatekeepers, thanks Fürbass Franz!
#
# Revision 1.36  2001/03/20 03:42:55  robertj
# Removed commented out and no longer used grabber files
#
# Revision 1.35  2001/03/02 06:59:57  robertj
# Enhanced the globally unique identifier class.
#
# Revision 1.34  2001/03/01 11:12:15  craigs
# Fixed problem with making from clean checkout
#
# Revision 1.33  2001/02/25 11:29:27  rogerh
# The -c flag to head is not found on all unix platforms.
# So use awk to get the first 3 columns of the asnparser version string
#
# Revision 1.32  2001/02/22 23:40:26  robertj
# Fixed problem with wanting to recompile ASN every time somthing is updated
#   in PWLib. Now only does so if the asnparser version number changes.
#
# Revision 1.31  2001/02/10 04:01:50  robertj
# Fixed build system so application can be built NOTRACE to separate directory.
#
# Revision 1.30  2001/02/09 04:44:37  craigs
# Added ability create a NOTRACE version of an exectuable with seperate
# libraries
#
# Revision 1.29  2001/01/26 08:34:18  rogerh
# Add mediafmt
#
# Revision 1.28  2000/12/19 22:33:44  dereks
# Adjust so that the video channel is used for reading/writing raw video
# data, which better modularizes the video codec.
#
# Revision 1.27  2000/10/30 00:24:28  robertj
# Removed redundant make rules (pieces of ancient history)
#
# Revision 1.26  2000/08/25 03:18:40  craigs
# More work on support for MS-GSM format
#
# Revision 1.25  2000/08/23 14:27:04  craigs
# Added prototype support for Microsoft GSM codec
#
# Revision 1.24  2000/08/14 17:11:08  rogerh
# Remove ixjdummy.cxx. It no longer builds on FreeBSD as it requires linux
# specific typedefs. All Openh323 code using ixj is protected by HAS_IXJ anyway.
#
# Revision 1.23  2000/07/14 12:38:56  craigs
# Prototype code to remove H.235
#
# Revision 1.22  2000/06/06 06:01:48  craigs
# Added Linux version of VPB API
#
# Revision 1.21  2000/06/05 09:31:16  robertj
# Removed copy and paste error adding gsm_decode.c twice.
#
# Revision 1.20  2000/06/05 07:06:42  robertj
# Added LPC-10 codec.
#
# Revision 1.19  2000/05/15 13:50:09  robertj
# Added dummy code for Quicknet xJack interface on platforms that do not yet have drivers.
#
# Revision 1.18  2000/05/11 02:27:18  robertj
# Removed "sample" directory and added "samples/simple" for demo app.
#
# Revision 1.17  2000/05/02 04:32:25  robertj
# Fixed copyright notice comment.
#
# Revision 1.16  2000/04/26 03:01:59  robertj
# Changed lib filename generation to use the version file for sample app.
#
# Revision 1.15  2000/04/26 01:07:23  robertj
# Removed tarfile creation target, this is done differently now.
#
# Revision 1.14  2000/04/18 01:07:04  craigs
# Fixed problem with compiling on machines without telephony files
#
# Revision 1.13  2000/04/06 17:50:28  craigs
# Removed ixjuser.h
#
# Revision 1.12  2000/04/05 16:27:38  craigs
# Fixed problem with Linux makefile
#
# Revision 1.11  2000/04/03 23:54:56  robertj
# Added missing H.235 dependency.
#
# Revision 1.10  2000/03/24 03:17:45  robertj
# Directory restructuring.
#
# Revision 1.9  2000/03/14 11:20:49  rogerh
# Compile the ixj code on FreeBSD. This is needed for openphone support.
#
# Revision 1.8  2000/03/03 12:20:40  robertj
# Fixed non fatal error in make rules and allowed for missing sample apps.
#
# Revision 1.7  2000/02/29 19:55:57  craigs
# Fixed problem with make include files in wrong order
#
# Revision 1.6  2000/02/24 11:53:31  craigs
# Fixed problem with .o files not going into correct directory
#
# Revision 1.5  2000/02/17 07:02:43  craigs
# Moved declaration of HAS_IXJ, HAS_VPB and LINUX_TELEPHONY into common Makefile
#
# Revision 1.4  2000/02/04 09:36:58  craigs
# Removed platform dependent grabber stuff
#
# Revision 1.3  2000/02/04 05:11:19  craigs
# Updated for new Makefiles and for new video transmission code
#
# Revision 1.2  2000/02/03 23:33:52  robertj
# Added missing "opt" in ASN parser compile line, thanks Brad Midgley
#
# Revision 1.1  2000/02/02 04:02:06  craigs
# Local makefile for library
#
#

ifndef OPENH323DIR
OPENH323DIR=$(CURDIR)/..
endif

LIBRARY_MAKEFILE:=1

include $(OPENH323DIR)/openh323u.mak


OH323_OBJDIR = $(OH323_LIBDIR)/$(PT_OBJBASE)
ifdef NOTRACE
OH323_OBJDIR := $(OH323_OBJDIR)n
endif


OBJDIR	=	$(OH323_OBJDIR)
LIBDIR	=	$(OH323_LIBDIR)
TARGET	=	$(LIBDIR)/$(OH323_FILE)
VERSION_FILE =	$(OPENH323DIR)/version.h

########################################

ifdef OH323_SUPPRESS_H235
ASN_EXCLUDE	+= h235_exclude.txt
endif

ASN_FILES := $(OH323_SRCDIR)/h225.asn \
             $(OH323_SRCDIR)/h245.asn \
             $(OH323_SRCDIR)/h248.asn \
             $(OH323_SRCDIR)/x880.asn \
             $(OH323_SRCDIR)/h4501.asn \
             $(OH323_SRCDIR)/h4502.asn \
             $(OH323_SRCDIR)/h4504.asn \
             $(OH323_SRCDIR)/h4505.asn \
             $(OH323_SRCDIR)/h4506.asn \
             $(OH323_SRCDIR)/h4507.asn \
             $(OH323_SRCDIR)/h4508.asn \
             $(OH323_SRCDIR)/h4509.asn \
             $(OH323_SRCDIR)/h45010.asn \
             $(OH323_SRCDIR)/h45011.asn \
             $(OH323_SRCDIR)/h501.asn \
             $(OH323_SRCDIR)/t38.asn \
             $(OH323_SRCDIR)/mcspdu.asn \
             $(OH323_SRCDIR)/gccpdu.asn

ifndef OH323_SUPPRESS_H235
ASN_FILES	+= $(OH323_SRCDIR)/h235.asn
endif

HEADER_FILES	:= $(OH323_INCDIR)/h323.h
COMMON_SOURCES	:= $(OH323_SRCDIR)/h323.cxx $(OH323_SRCDIR)/h323ep.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h323neg.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h323neg.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h323pdu.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h323pdu.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h323rtp.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h323rtp.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h323caps.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h323caps.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h323t120.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h323t120.cxx
HEADER_FILES	+= $(OH323_INCDIR)/t120proto.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/t120proto.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h323t38.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h323t38.cxx
HEADER_FILES	+= $(OH323_INCDIR)/t38proto.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/t38proto.cxx
HEADER_FILES	+= $(OH323_INCDIR)/q931.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/q931.cxx
HEADER_FILES	+= $(OH323_INCDIR)/x224.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/x224.cxx
HEADER_FILES	+= $(OH323_INCDIR)/codecs.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/codecs.cxx
HEADER_FILES	+= $(OH323_INCDIR)/channels.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/channels.cxx
HEADER_FILES	+= $(OH323_INCDIR)/transports.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/transports.cxx
HEADER_FILES	+= $(OH323_INCDIR)/jitter.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/jitter.cxx
HEADER_FILES	+= $(OH323_INCDIR)/rtp.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/rtp.cxx
HEADER_FILES	+= $(OH323_INCDIR)/rtp2wav.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/rtp2wav.cxx
HEADER_FILES	+= $(OH323_INCDIR)/gkclient.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/gkclient.cxx
HEADER_FILES	+= $(OH323_INCDIR)/gkserver.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/gkserver.cxx
HEADER_FILES	+= $(OH323_INCDIR)/lid.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/lid.cxx
HEADER_FILES	+= $(OH323_INCDIR)/mediafmt.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/mediafmt.cxx
HEADER_FILES	+= $(OH323_INCDIR)/guid.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/guid.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h450pdu.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h450pdu.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h225ras.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h225ras.cxx
HEADER_FILES	+= $(OH323_INCDIR)/svcctrl.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/svcctrl.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h323trans.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h323trans.cxx
HEADER_FILES	+= $(OH323_INCDIR)/peclient.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/peclient.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h323annexg.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h323annexg.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h501pdu.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h501pdu.cxx
HEADER_FILES	+= $(OH323_INCDIR)/h235auth.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/h235auth.cxx
HEADER_FILES	+= $(OH323_INCDIR)/rfc2833.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/rfc2833.cxx
HEADER_FILES	+= $(OH323_INCDIR)/opalwavfile.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/opalwavfile.cxx
HEADER_FILES	+= $(OH323_INCDIR)/opalvxml.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/opalvxml.cxx

ifdef HAS_OPENSSL
COMMON_SOURCES	+= $(OH323_SRCDIR)/h235auth1.cxx
endif

HEADER_FILES    += $(OH323_INCDIR)/ixjlid.h
ifdef HAS_IXJ
COMMON_SOURCES  += $(OH323_SRCDIR)/ixjunix.cxx
endif

ifdef HAS_VPB
COMMON_SOURCES  += $(OH323_SRCDIR)/vpblid.cxx
endif

COMMON_SOURCES	+= $(OH323_SRCDIR)/g711.c


ifndef NOAUDIOCODECS

# GSM 06.10

HEADER_FILES	+= $(OH323_INCDIR)/gsmcodec.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/gsmcodec.cxx

GSM_DIR 	= gsm
GSM_SRCDIR	= $(GSM_DIR)/src
GSM_INCDIR	= $(GSM_DIR)/inc

HEADER_FILES	+= $(GSM_INCDIR)/gsm.h \
                   $(GSM_INCDIR)/config.h \
                   $(GSM_INCDIR)/private.h \
                   $(GSM_INCDIR)/proto.h \
                   $(GSM_INCDIR)/unproto.h \
                   $(GSM_DIR)/README \
                   $(GSM_DIR)/COPYRIGHT \
                   $(GSM_DIR)/PART_OF_TOAST

COMMON_SOURCES	+= $(GSM_SRCDIR)/gsm_create.c \
                   $(GSM_SRCDIR)/gsm_destroy.c \
		   $(GSM_SRCDIR)/gsm_decode.c \
                   $(GSM_SRCDIR)/gsm_encode.c \
                   $(GSM_SRCDIR)/gsm_option.c \
		   $(GSM_SRCDIR)/code.c \
                   $(GSM_SRCDIR)/decode.c \
                   $(GSM_SRCDIR)/add.c \
		   $(GSM_SRCDIR)/gsm_lpc.c \
                   $(GSM_SRCDIR)/rpe.c \
                   $(GSM_SRCDIR)/preprocess.c \
                   $(GSM_SRCDIR)/long_term.c \
                   $(GSM_SRCDIR)/short_term.c \
                   $(GSM_SRCDIR)/table.c


# Microsoft GSM and ADPCM

HEADER_FILES	+= $(OH323_INCDIR)/mscodecs.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/mscodecs.cxx


# G.726

HEADER_FILES	+= $(OH323_INCDIR)/g726codec.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/g726codec.cxx

G726_DIR	= g726

HEADER_FILES	+= $(G726_DIR)/g72x.h \
                   $(G726_DIR)/private.h

COMMON_SOURCES	+= $(G726_DIR)/g72x.c \
                   $(G726_DIR)/g726_16.c \
                   $(G726_DIR)/g726_24.c \
                   $(G726_DIR)/g726_32.c \
                   $(G726_DIR)/g726_40.c


# LPC-10

HEADER_FILES	+= $(OH323_INCDIR)/lpc10codec.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/lpc10codec.cxx

LPC10_DIR 	= lpc10
LPC10_INCDIR	= $(LPC10_DIR)
LPC10_SRCDIR	= $(LPC10_DIR)/src

HEADER_FILES	+= $(LPC10_INCDIR)/lpc10.h

COMMON_SOURCES	+= $(LPC10_SRCDIR)/f2clib.c \
		   $(LPC10_SRCDIR)/analys.c \
		   $(LPC10_SRCDIR)/bsynz.c \
		   $(LPC10_SRCDIR)/chanwr.c \
		   $(LPC10_SRCDIR)/dcbias.c \
		   $(LPC10_SRCDIR)/decode_.c \
		   $(LPC10_SRCDIR)/deemp.c \
		   $(LPC10_SRCDIR)/difmag.c \
		   $(LPC10_SRCDIR)/dyptrk.c \
		   $(LPC10_SRCDIR)/encode_.c \
		   $(LPC10_SRCDIR)/energy.c \
		   $(LPC10_SRCDIR)/ham84.c \
		   $(LPC10_SRCDIR)/hp100.c \
		   $(LPC10_SRCDIR)/invert.c \
		   $(LPC10_SRCDIR)/irc2pc.c \
		   $(LPC10_SRCDIR)/ivfilt.c \
		   $(LPC10_SRCDIR)/lpcdec.c \
		   $(LPC10_SRCDIR)/lpcenc.c \
		   $(LPC10_SRCDIR)/lpcini.c \
		   $(LPC10_SRCDIR)/lpfilt.c \
		   $(LPC10_SRCDIR)/median.c \
		   $(LPC10_SRCDIR)/mload.c \
		   $(LPC10_SRCDIR)/onset.c \
		   $(LPC10_SRCDIR)/pitsyn.c \
		   $(LPC10_SRCDIR)/placea.c \
		   $(LPC10_SRCDIR)/placev.c \
		   $(LPC10_SRCDIR)/preemp.c \
		   $(LPC10_SRCDIR)/prepro.c \
		   $(LPC10_SRCDIR)/random.c \
		   $(LPC10_SRCDIR)/rcchk.c \
		   $(LPC10_SRCDIR)/synths.c \
		   $(LPC10_SRCDIR)/tbdm.c \
		   $(LPC10_SRCDIR)/voicin.c \
		   $(LPC10_SRCDIR)/vparms.c \


# iLBC

HEADER_FILES	+= $(OH323_INCDIR)/ilbccodec.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/ilbccodec.cxx

ILBC_DIR 	= iLBC

HEADER_FILES	+= $(ILBC_DIR)/iLBC_define.h
HEADER_FILES	+= $(ILBC_DIR)/iLBC_decode.h
COMMON_SOURCES	+= $(ILBC_DIR)/iLBC_decode.c
HEADER_FILES	+= $(ILBC_DIR)/iLBC_encode.h
COMMON_SOURCES	+= $(ILBC_DIR)/iLBC_encode.c
HEADER_FILES	+= $(ILBC_DIR)/FrameClassify.h
COMMON_SOURCES	+= $(ILBC_DIR)/FrameClassify.c
HEADER_FILES	+= $(ILBC_DIR)/LPCdecode.h
COMMON_SOURCES	+= $(ILBC_DIR)/LPCdecode.c
HEADER_FILES	+= $(ILBC_DIR)/LPCencode.h
COMMON_SOURCES	+= $(ILBC_DIR)/LPCencode.c
HEADER_FILES	+= $(ILBC_DIR)/StateConstructW.h
COMMON_SOURCES	+= $(ILBC_DIR)/StateConstructW.c
HEADER_FILES	+= $(ILBC_DIR)/StateSearchW.h
COMMON_SOURCES	+= $(ILBC_DIR)/StateSearchW.c
HEADER_FILES	+= $(ILBC_DIR)/anaFilter.h
COMMON_SOURCES	+= $(ILBC_DIR)/anaFilter.c
HEADER_FILES	+= $(ILBC_DIR)/constants.h
COMMON_SOURCES	+= $(ILBC_DIR)/constants.c
HEADER_FILES	+= $(ILBC_DIR)/createCB.h
COMMON_SOURCES	+= $(ILBC_DIR)/createCB.c
HEADER_FILES	+= $(ILBC_DIR)/doCPLC.h
COMMON_SOURCES	+= $(ILBC_DIR)/doCPLC.c
HEADER_FILES	+= $(ILBC_DIR)/enhancer.h
COMMON_SOURCES	+= $(ILBC_DIR)/enhancer.c
HEADER_FILES	+= $(ILBC_DIR)/filter.h
COMMON_SOURCES	+= $(ILBC_DIR)/filter.c
HEADER_FILES	+= $(ILBC_DIR)/gainquant.h
COMMON_SOURCES	+= $(ILBC_DIR)/gainquant.c
HEADER_FILES	+= $(ILBC_DIR)/getCBvec.h
COMMON_SOURCES	+= $(ILBC_DIR)/getCBvec.c
HEADER_FILES	+= $(ILBC_DIR)/helpfun.h
COMMON_SOURCES	+= $(ILBC_DIR)/helpfun.c
HEADER_FILES	+= $(ILBC_DIR)/hpInput.h
COMMON_SOURCES	+= $(ILBC_DIR)/hpInput.c
HEADER_FILES	+= $(ILBC_DIR)/hpOutput.h
COMMON_SOURCES	+= $(ILBC_DIR)/hpOutput.c
HEADER_FILES	+= $(ILBC_DIR)/iCBConstruct.h
COMMON_SOURCES	+= $(ILBC_DIR)/iCBConstruct.c
HEADER_FILES	+= $(ILBC_DIR)/iCBSearch.h
COMMON_SOURCES	+= $(ILBC_DIR)/iCBSearch.c
HEADER_FILES	+= $(ILBC_DIR)/lsf.h
COMMON_SOURCES	+= $(ILBC_DIR)/lsf.c
HEADER_FILES	+= $(ILBC_DIR)/packing.h
COMMON_SOURCES	+= $(ILBC_DIR)/packing.c
HEADER_FILES	+= $(ILBC_DIR)/syntFilter.h
COMMON_SOURCES	+= $(ILBC_DIR)/syntFilter.c


# G.729 codec (not available on Unix yet!)

HEADER_FILES	+= $(OH323_INCDIR)/g729codec.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/g729codec.cxx

# Speex codec

ifndef NO_SPEEX

HEADER_FILES	+= $(OH323_INCDIR)/speexcodec.h
COMMON_SOURCES	+= $(OH323_SRCDIR)/speexcodec.cxx


SPEEX_DIR 	= speex
SPEEX_INCDIR	= $(SPEEX_DIR)/libspeex
SPEEX_SRCDIR	= $(SPEEX_DIR)/libspeex

HEADER_FILES	+= $(SPEEX_INCDIR)/speex.h \
		   $(SPEEX_INCDIR)/speex_bits.h \
		   $(SPEEX_INCDIR)/speex_header.h \
		   $(SPEEX_INCDIR)/speex_callbacks.h

COMMON_SOURCES	+= $(SPEEX_SRCDIR)/nb_celp.c \
		   $(SPEEX_SRCDIR)/sb_celp.c \
		   $(SPEEX_SRCDIR)/lpc.c \
		   $(SPEEX_SRCDIR)/ltp.c \
		   $(SPEEX_SRCDIR)/lsp.c \
		   $(SPEEX_SRCDIR)/quant_lsp.c \
		   $(SPEEX_SRCDIR)/lsp_tables_nb.c \
		   $(SPEEX_SRCDIR)/gain_table.c \
		   $(SPEEX_SRCDIR)/gain_table_lbr.c \
		   $(SPEEX_SRCDIR)/cb_search.c \
		   $(SPEEX_SRCDIR)/filters.c \
		   $(SPEEX_SRCDIR)/bits.c \
		   $(SPEEX_SRCDIR)/modes.c \
		   $(SPEEX_SRCDIR)/vq.c \
		   $(SPEEX_SRCDIR)/high_lsp_tables.c \
		   $(SPEEX_SRCDIR)/vbr.c \
		   $(SPEEX_SRCDIR)/hexc_table.c \
		   $(SPEEX_SRCDIR)/exc_5_256_table.c \
		   $(SPEEX_SRCDIR)/exc_5_64_table.c \
		   $(SPEEX_SRCDIR)/exc_8_128_table.c \
		   $(SPEEX_SRCDIR)/exc_20_32_table.c \
		   $(SPEEX_SRCDIR)/exc_10_32_table.c \
		   $(SPEEX_SRCDIR)/exc_10_16_table.c \
		   $(SPEEX_SRCDIR)/hexc_10_32_table.c \
		   $(SPEEX_SRCDIR)/misc.c \
		   $(SPEEX_SRCDIR)/speex_header.c \
		   $(SPEEX_SRCDIR)/speex_callbacks.c
endif

ifeq ($(ENDIAN),PBIG_ENDIAN)
SPEEX_FLAGS = -DWORDS_BIGENDIAN 
endif

endif



ifndef NOVIDEO

VIC_DIR = vic

HEADER_FILES	+= $(OH323_INCDIR)/h261codec.h \
                   $(VIC_DIR)/p64.h \
		   $(VIC_DIR)/dct.h \
		   $(VIC_DIR)/p64-huff.h \
		   $(VIC_DIR)/config.h \
		   $(VIC_DIR)/bsd-endian.h \
		   $(VIC_DIR)/crdef.h \
                   $(VIC_DIR)/encoder.h \
                   $(VIC_DIR)/encoder-h261.h \
                   $(VIC_DIR)/p64encoder.h \
                   $(VIC_DIR)/transmitter.h \
                   $(VIC_DIR)/vid_coder.h \
                   $(VIC_DIR)/videoframe.h \

COMMON_SOURCES	+= $(OH323_SRCDIR)/h261codec.cxx \
                   $(VIC_DIR)/dct.cxx \
		   $(VIC_DIR)/p64.cxx \
		   $(VIC_DIR)/huffcode.c \
		   $(VIC_DIR)/bv.c \
		   $(VIC_DIR)/encoder-h261.cxx \
                   $(VIC_DIR)/p64encoder.cxx \
                   $(VIC_DIR)/transmitter.cxx \
                   $(VIC_DIR)/vid_coder.cxx 


ifdef CU30INSTALLED
COMMON_SOURCES	+=$(OH323_SRCDIR)/cu30codec.cxx
HEADER_FILES	+=$(OH323_INCDIR)/cu30codec.h
endif

ifdef H323_AVCODEC
COMMON_SOURCES	+=$(OH323_SRCDIR)/ffh263codec.cxx 
HEADER_FILES	+=$(OH323_INCDIR)/ffh263codec.h 
endif

ifdef H323_VICH263
COMMON_SOURCES	+=$(OH323_SRCDIR)/h263codec.cxx 
HEADER_FILES	+=$(OH323_INCDIR)/h263codec.h 
endif

endif


# The following are required by the ptlib.mak
SOURCES		= $(OH323_SRCDIR)/h225_1.cxx \
                  $(OH323_SRCDIR)/h225_2.cxx \
		  $(OH323_SRCDIR)/h245_1.cxx \
		  $(OH323_SRCDIR)/h245_2.cxx \
		  $(OH323_SRCDIR)/h245_3.cxx \
		  $(OH323_SRCDIR)/h248.cxx \
		  $(OH323_SRCDIR)/x880.cxx \
		  $(OH323_SRCDIR)/t38.cxx \
		  $(OH323_SRCDIR)/h4501.cxx \
		  $(OH323_SRCDIR)/h4502.cxx \
		  $(OH323_SRCDIR)/h4504.cxx \
                  $(OH323_SRCDIR)/h4505.cxx \
                  $(OH323_SRCDIR)/h4506.cxx \
                  $(OH323_SRCDIR)/h4507.cxx \
                  $(OH323_SRCDIR)/h4508.cxx \
                  $(OH323_SRCDIR)/h4509.cxx \
                  $(OH323_SRCDIR)/h45010.cxx \
                  $(OH323_SRCDIR)/h45011.cxx \
		  $(OH323_SRCDIR)/h501.cxx \
		  $(OH323_SRCDIR)/mcspdu.cxx \
		  $(OH323_SRCDIR)/gccpdu.cxx \
		  $(COMMON_SOURCES) \

ifndef OH323_SUPPRESS_H235
SOURCES		+= $(OH323_SRCDIR)/h235.cxx
endif

CLEAN_FILES	= $(OH323_LIB) \
		  $(ASN_FILES:.asn=.cxx) \
		  $(ASN_FILES:.asn=_[1-9t].cxx) \
		  $(ASN_FILES:.asn=_asn.cxx) \
		  $(OH323_INCDIR)/h225.h \
		  $(OH323_INCDIR)/h245.h \
		  $(OH323_INCDIR)/h248.h \
		  $(OH323_INCDIR)/h4501.h \
		  $(OH323_INCDIR)/h4502.h \
		  $(OH323_INCDIR)/h4504.h \
                  $(OH323_INCDIR)/h4505.h \
                  $(OH323_INCDIR)/h4506.h \
                  $(OH323_INCDIR)/h4507.h \
                  $(OH323_INCDIR)/h4508.h \
                  $(OH323_INCDIR)/h4509.h \
                  $(OH323_INCDIR)/h45010.h \
                  $(OH323_INCDIR)/h45011.h \
		  $(OH323_INCDIR)/h501.h \
		  $(OH323_INCDIR)/x880.h \
		  $(OH323_INCDIR)/t38.h \
		  $(OH323_INCDIR)/mcspdu.h \
		  $(OH323_INCDIR)/gccpdu.h \

ifndef OH323_SUPPRESS_H235
CLEAN_FILES	+= $(OH323_INCDIR)/h235.h
endif

ifdef NOTRACE
STDCCFLAGS += -DPASN_NOPRINTON
else
STDCCFLAGS += -DPTRACING
endif


VPATH_CXX := $(OH323_SRCDIR)
VPATH_C := $(OH323_SRCDIR)


####################################################

include $(PWLIBDIR)/make/common.mak

####################################################

# make sure pwlib is in the list of external libraries
# this ensures pwlib is not statically linked
LDFLAGS        += -L$(PW_LIBDIR)
SYSLIBS        += -l$(PTLIB_BASE)$(LIB_TYPE)

LIB_BASENAME=$(OH323_BASE)
LIB_FILENAME=$(OH323_FILE)

include $(PWLIBDIR)/make/lib.mak

####################################################


# Make sure the asnparser is built and if new version force recompiles

# Use a different variable here to support cross compiling
ifndef HOSTPWLIBDIR
HOSTPWLIBDIR=$(PWLIBDIR)
endif

ifndef HOST_PLATFORM_TYPE
HOST_PLATFORM_TYPE=$(PLATFORM_TYPE)
endif


# Set library path so asnparser will run

ifdef LD_LIBRARY_PATH
LD_LIBRARY_PATH:=$(LD_LIBRARY_PATH):$(HOSTPWLIBDIR)/lib
else
LD_LIBRARY_PATH:=$(HOSTPWLIBDIR)/lib
endif
export LD_LIBRARY_PATH


# If we're cross compiling, we want the host's asnparser
# otherwise use the one for the current platform
ASNPARSE_DIR = $(HOSTPWLIBDIR)/tools/asnparser
ASNPARSER = $(ASNPARSE_DIR)/obj_$(HOST_PLATFORM_TYPE)_r/asnparser


# If not cross compiling then make sure asnparser is built
ifeq ($(PLATFORM_TYPE),$(HOST_PLATFORM_TYPE))
$(ASNPARSER):
	$(MAKE) -C $(ASNPARSE_DIR) opt
endif


ifdef ASN_EXCLUDE
ASNPARSER += -x $(ASN_EXCLUDE)
endif

asnparser.version: $(ASNPARSER)
	$(ASNPARSER) --version | awk '{print $$1,$$2,$$3}' > asnparser.version.new
	if test -f asnparser.version && diff asnparser.version.new asnparser.version >/dev/null 2>&1 ; \
		then rm asnparser.version.new ; \
		else mv asnparser.version.new asnparser.version ; \
	fi


# Build the .cxx files from the .asn files

#### h245

$(OH323_SRCDIR)/h245_1.cxx \
$(OH323_OBJDIR)/h245_1.dep \
$(OH323_SRCDIR)/h245_2.cxx \
$(OH323_OBJDIR)/h245_2.dep \
$(OH323_SRCDIR)/h245_3.cxx \
$(OH323_OBJDIR)/h245_3.dep : $(OH323_INCDIR)/h245.h


$(OH323_INCDIR)/h245.h: $(OH323_SRCDIR)/h245.asn asnparser.version
	$(ASNPARSER) -s3 -m H245 -c --classheader "H245_AudioCapability=#ifndef PASN_NOPRINTON\nvoid PrintOn(ostream & strm) const;\n#endif" $<
	mv $(OH323_SRCDIR)/h245.h $(OH323_INCDIR)/h245.h

#### h235

ifndef OH323_SUPPRESS_H235

$(OH323_SRCDIR)/h235.cxx $(OH323_SRCDIR)/h235_t.cxx : $(OH323_INCDIR)/h235.h

$(OH323_INCDIR)/h235.h: $(OH323_SRCDIR)/h235.asn asnparser.version
	$(ASNPARSER) -m H235 -c $<
	mv $(OH323_SRCDIR)/h235.h $(OH323_INCDIR)/h235.h

endif

#### h225

$(OH323_SRCDIR)/h225_1.cxx \
$(OH323_OBJDIR)/h225_1.dep \
$(OH323_SRCDIR)/h225_2.cxx \
$(OH323_OBJDIR)/h225_2.dep : $(OH323_INCDIR)/h225.h \
                             $(OH323_SRCDIR)/h235_t.cxx \
			     $(OH323_INCDIR)/h245.h

$(OH323_INCDIR)/h225.h: $(OH323_SRCDIR)/h225.asn asnparser.version
	$(ASNPARSER) -s2 -m H225 -r MULTIMEDIA-SYSTEM-CONTROL=H245 -c $<
	mv $(OH323_SRCDIR)/h225.h $(OH323_INCDIR)/h225.h


#### h248

$(OH323_SRCDIR)/h248.cxx : $(OH323_INCDIR)/h248.h


$(OH323_INCDIR)/h248.h: $(OH323_SRCDIR)/h248.asn asnparser.version
	$(ASNPARSER) -m H248 -c $<
	mv $(OH323_SRCDIR)/h248.h $(OH323_INCDIR)/h248.h

### h450

$(OH323_SRCDIR)/h4501.cxx $(OH323_OBJDIR)/h4501.dep : \
		$(OH323_INCDIR)/h4501.h $(OH323_INCDIR)/x880.h

$(OH323_INCDIR)/h4501.h: $(OH323_SRCDIR)/h4501.asn asnparser.version
	$(ASNPARSER) -m H4501 -c $<
	mv $(OH323_SRCDIR)/h4501.h $(OH323_INCDIR)/h4501.h


$(OH323_SRCDIR)/h4502.cxx $(OH323_OBJDIR)/h4502.dep : \
		$(OH323_INCDIR)/h4502.h $(OH323_INCDIR)/x880.h \
		$(OH323_INCDIR)/h4501.h

$(OH323_INCDIR)/h4502.h: $(OH323_SRCDIR)/h4502.asn asnparser.version
	$(ASNPARSER) -m H4502 -c $<
	mv $(OH323_SRCDIR)/h4502.h $(OH323_INCDIR)/h4502.h


$(OH323_SRCDIR)/h4504.cxx $(OH323_OBJDIR)/h4504.dep : \
		$(OH323_INCDIR)/h4504.h $(OH323_INCDIR)/x880.h \
		$(OH323_INCDIR)/h4501.h

$(OH323_INCDIR)/h4504.h: $(OH323_SRCDIR)/h4504.asn asnparser.version
	$(ASNPARSER) -m H4504 -c $<
	mv $(OH323_SRCDIR)/h4504.h $(OH323_INCDIR)/h4504.h


$(OH323_SRCDIR)/h4505.cxx $(OH323_OBJDIR)/h4505.dep : \
		$(OH323_INCDIR)/h4505.h $(OH323_INCDIR)/x880.h \
		$(OH323_INCDIR)/h4501.h \
		$(OH323_INCDIR)/h4504.h

$(OH323_INCDIR)/h4505.h: $(OH323_SRCDIR)/h4505.asn asnparser.version
	$(ASNPARSER) -m H4505 -c $<
	mv $(OH323_SRCDIR)/h4505.h $(OH323_INCDIR)/h4505.h


$(OH323_SRCDIR)/h4506.cxx $(OH323_OBJDIR)/h4506.dep : \
		$(OH323_INCDIR)/h4506.h $(OH323_INCDIR)/x880.h \
		$(OH323_INCDIR)/h4501.h \
		$(OH323_INCDIR)/h4504.h

$(OH323_INCDIR)/h4506.h: $(OH323_SRCDIR)/h4506.asn asnparser.version
	$(ASNPARSER) -m H4506 -c $<
	mv $(OH323_SRCDIR)/h4506.h $(OH323_INCDIR)/h4506.h


$(OH323_SRCDIR)/h4507.cxx $(OH323_OBJDIR)/h4507.dep : \
		$(OH323_INCDIR)/h4507.h $(OH323_INCDIR)/x880.h \
		$(OH323_INCDIR)/h4501.h \
		$(OH323_INCDIR)/h4504.h

$(OH323_INCDIR)/h4507.h: $(OH323_SRCDIR)/h4507.asn asnparser.version
	$(ASNPARSER) -m H4507 -c $<
	mv $(OH323_SRCDIR)/h4507.h $(OH323_INCDIR)/h4507.h


$(OH323_SRCDIR)/h4508.cxx $(OH323_OBJDIR)/h4508.dep : \
		$(OH323_INCDIR)/h4508.h $(OH323_INCDIR)/x880.h \
		$(OH323_INCDIR)/h4501.h \
		$(OH323_INCDIR)/h4505.h

$(OH323_INCDIR)/h4508.h: $(OH323_SRCDIR)/h4508.asn asnparser.version
	$(ASNPARSER) -m H4508 -c $<
	mv $(OH323_SRCDIR)/h4508.h $(OH323_INCDIR)/h4508.h


$(OH323_SRCDIR)/h4509.cxx $(OH323_OBJDIR)/h4509.dep : \
		$(OH323_INCDIR)/h4509.h $(OH323_INCDIR)/x880.h \
		$(OH323_INCDIR)/h4501.h \
		$(OH323_INCDIR)/h4504.h \
		$(OH323_INCDIR)/h4507.h

$(OH323_INCDIR)/h4509.h: $(OH323_SRCDIR)/h4509.asn asnparser.version
	$(ASNPARSER) -m H4509 -c $<
	mv $(OH323_SRCDIR)/h4509.h $(OH323_INCDIR)/h4509.h


$(OH323_SRCDIR)/h45010.cxx $(OH323_OBJDIR)/h45010.dep : \
		$(OH323_INCDIR)/h45010.h $(OH323_INCDIR)/x880.h \
		$(OH323_INCDIR)/h4504.h \
		$(OH323_INCDIR)/h4506.h

$(OH323_INCDIR)/h45010.h: $(OH323_SRCDIR)/h45010.asn asnparser.version
	$(ASNPARSER) -m H45010 -c $<
	mv $(OH323_SRCDIR)/h45010.h $(OH323_INCDIR)/h45010.h


$(OH323_SRCDIR)/h45011.cxx $(OH323_OBJDIR)/h45011.dep : \
		$(OH323_INCDIR)/h45011.h $(OH323_INCDIR)/x880.h \
		$(OH323_INCDIR)/h4501.h \
		$(OH323_INCDIR)/h4504.h \
		$(OH323_INCDIR)/h4506.h \
		$(OH323_INCDIR)/h45010.h

$(OH323_INCDIR)/h45011.h: $(OH323_SRCDIR)/h45011.asn asnparser.version
	$(ASNPARSER) -m H45011 -c $<
	mv $(OH323_SRCDIR)/h45011.h $(OH323_INCDIR)/h45011.h


### x880

$(OH323_SRCDIR)/x880.cxx: $(OH323_INCDIR)/x880.h

$(OH323_INCDIR)/x880.h: $(OH323_SRCDIR)/x880.asn asnparser.version
	$(ASNPARSER) -m X880 -c $<
	mv $(OH323_SRCDIR)/x880.h $(OH323_INCDIR)/x880.h

### h501

$(OH323_SRCDIR)/h501.cxx $(OH323_OBJDIR)/h501.dep : \
		$(OH323_INCDIR)/h501.h

$(OH323_INCDIR)/h501.h: $(OH323_SRCDIR)/h501.asn asnparser.version
	$(ASNPARSER) -m H501 -c $<
	mv $(OH323_SRCDIR)/h501.h $(OH323_INCDIR)/h501.h


### t38

$(OH323_SRCDIR)/t38.cxx: $(OH323_INCDIR)/t38.h

$(OH323_INCDIR)/t38.h: $(OH323_SRCDIR)/t38.asn asnparser.version
	$(ASNPARSER) -m T38 -c $<
	mv $(OH323_SRCDIR)/t38.h $(OH323_INCDIR)/t38.h

#### mcs

$(OH323_SRCDIR)/mcspdu.cxx: $(OH323_INCDIR)/mcspdu.h

$(OH323_INCDIR)/mcspdu.h: $(OH323_SRCDIR)/mcspdu.asn asnparser.version
	$(ASNPARSER) -m MCS -c $<
	mv $(OH323_SRCDIR)/mcspdu.h $(OH323_INCDIR)/mcspdu.h

#### gcc

$(OH323_SRCDIR)/gccpdu.cxx: $(OH323_INCDIR)/gccpdu.h

$(OH323_INCDIR)/gccpdu.h: $(OH323_SRCDIR)/gccpdu.asn asnparser.version
	$(ASNPARSER) -m GCC -c $<
	mv $(OH323_SRCDIR)/gccpdu.h $(OH323_INCDIR)/gccpdu.h


ifndef OH323_SUPPRESS_H235

# ensure that h.235.h is created for the h225 compilation
$(OH323_OBJDIR)/h225.o: $(OH323_INCDIR)/h235.h

endif

# Build rules for VIC codecs

$(OH323_OBJDIR)/%.o : $(VIC_DIR)/%.cxx
	@if [ ! -d $(OH323_OBJDIR) ] ; then mkdir -p $(OH323_OBJDIR) ; fi
	$(CPLUS) -I$(VIC_DIR) $(STDCCFLAGS) $(CFLAGS) -c $< -o $@

$(OH323_OBJDIR)/%.o : $(VIC_DIR)/%.c
	@if [ ! -d $(OH323_OBJDIR) ] ; then mkdir -p $(OH323_OBJDIR) ; fi
	$(CC) -I$(VIC_DIR) $(STDCCFLAGS) $(CFLAGS) -c $< -o $@

$(DEPDIR)/%.dep : $(VIC_DIR)/%.c
	@if [ ! -d $(DEPDIR) ] ; then mkdir -p $(DEPDIR) ; fi
	@printf %s $(OH323_OBJDIR)/ > $@
	$(CPLUS) -I$(VIC_DIR) $(STDCCFLAGS) $(CFLAGS) -M $< >> $@

$(DEPDIR)/%.dep : $(VIC_DIR)/%.cxx
	@if [ ! -d $(DEPDIR) ] ; then mkdir -p $(DEPDIR) ; fi
	@printf %s $(OH323_OBJDIR)/ > $@
	$(CPLUS) -I$(VIC_DIR) $(STDCCFLAGS) $(CFLAGS) -M $< >> $@


# Build rules for the GSM codec

$(OH323_OBJDIR)/%.o : $(GSM_SRCDIR)/%.c
	@if [ ! -d $(OH323_OBJDIR) ] ; then mkdir -p $(OH323_OBJDIR) ; fi
	$(CC) -ansi -I$(GSM_INCDIR) -DWAV49 -DNeedFunctionPrototypes=1 $(OPTCCFLAGS) $(CFLAGS) -c $< -o $@

$(DEPDIR)/%.dep : $(GSM_SRCDIR)/%.c
	@if [ ! -d $(DEPDIR) ] ; then mkdir -p $(DEPDIR) ; fi
	@printf %s $(OH323_OBJDIR)/ > $@
	$(CC) -ansi -I$(GSM_INCDIR) -DWAV49 -DNeedFunctionPrototypes=1 $(CFLAGS) -M $< >> $@


# Build rules for the G.726 codec

$(OH323_OBJDIR)/%.o : $(G726_DIR)/%.c
	@if [ ! -d $(OH323_OBJDIR) ] ; then mkdir -p $(OH323_OBJDIR) ; fi
	$(CC) $(OPTCCFLAGS) $(CFLAGS) -c $< -o $@

$(DEPDIR)/%.dep : $(G726_DIR)/%.c
	@if [ ! -d $(DEPDIR) ] ; then mkdir -p $(DEPDIR) ; fi
	@printf %s $(OH323_OBJDIR)/ > $@
	$(CC) $(OPTCCFLAGS) $(CFLAGS) -M $< >> $@


# Build rules for the LPC10 codec

$(OH323_OBJDIR)/%.o : $(LPC10_SRCDIR)/%.c
	@if [ ! -d $(OH323_OBJDIR) ] ; then mkdir -p $(OH323_OBJDIR) ; fi
	$(CC) -I$(LPC10_INCDIR) $(OPTCCFLAGS) $(CFLAGS) -c $< -o $@

$(DEPDIR)/%.dep : $(LPC10_SRCDIR)/%.c
	@if [ ! -d $(DEPDIR) ] ; then mkdir -p $(DEPDIR) ; fi
	@printf %s $(OH323_OBJDIR)/ > $@
	$(CC) -I$(LPC10_INCDIR) $(CFLAGS) -M $< >> $@

# Build rules for the iLBC codec

$(OH323_OBJDIR)/%.o : $(ILBC_DIR)/%.c
	@if [ ! -d $(OH323_OBJDIR) ] ; then mkdir -p $(OH323_OBJDIR) ; fi
	$(CC) $(OPTCCFLAGS) $(CFLAGS) -c $< -o $@

$(DEPDIR)/%.dep : $(ILBC_DIR)/%.c
	@if [ ! -d $(DEPDIR) ] ; then mkdir -p $(DEPDIR) ; fi
	@printf %s $(OH323_OBJDIR)/ > $@
	$(CC) $(CFLAGS) -M $< >> $@

# Build rules for the Speex codec

$(OH323_OBJDIR)/%.o : $(SPEEX_SRCDIR)/%.c
	@if [ ! -d $(OH323_OBJDIR) ] ; then mkdir -p $(OH323_OBJDIR) ; fi
	$(CC) $(SPEEX_FLAGS) -I$(SPEEX_INCDIR) $(OPTCCFLAGS) $(CFLAGS) -c $< -o $@

$(DEPDIR)/%.dep : $(SPEEX_SRCDIR)/%.c
	@if [ ! -d $(DEPDIR) ] ; then mkdir -p $(DEPDIR) ; fi
	@printf %s $(OH323_OBJDIR)/ > $@
	$(CC) $(SPEEX_FLAGS) -I$(SPEEX_INCDIR) $(CFLAGS) -M $< >> $@


notrace::
	$(MAKE) NOTRACE=1 opt

