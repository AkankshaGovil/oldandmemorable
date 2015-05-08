# Microsoft Developer Studio Project File - Name="iLBCCodec" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=iLBCCodec - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "ilbccodec.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "ilbccodec.mak" CFG="iLBCCodec - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "iLBCCodec - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "iLBCCodec - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "iLBCCodec - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "iLBCCodec_EXPORTS" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "iLBCCodec_EXPORTS" /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0xc09 /d "NDEBUG"
# ADD RSC /l 0xc09 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386

!ELSEIF  "$(CFG)" == "iLBCCodec - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "iLBCCodec_EXPORTS" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "iLBCCodec_EXPORTS" /FD /GZ /c
# SUBTRACT CPP /YX /Yc /Yu
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0xc09 /d "_DEBUG"
# ADD RSC /l 0xc09 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "iLBCCodec - Win32 Release"
# Name "iLBCCodec - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\anaFilter.c
# End Source File
# Begin Source File

SOURCE=.\constants.c
# End Source File
# Begin Source File

SOURCE=.\createCB.c
# End Source File
# Begin Source File

SOURCE=.\dllcodec.c
# End Source File
# Begin Source File

SOURCE=.\doCPLC.c
# End Source File
# Begin Source File

SOURCE=.\enhancer.c
# End Source File
# Begin Source File

SOURCE=.\filter.c
# End Source File
# Begin Source File

SOURCE=.\FrameClassify.c
# End Source File
# Begin Source File

SOURCE=.\gainquant.c
# End Source File
# Begin Source File

SOURCE=.\getCBvec.c
# End Source File
# Begin Source File

SOURCE=.\helpfun.c
# End Source File
# Begin Source File

SOURCE=.\hpInput.c
# End Source File
# Begin Source File

SOURCE=.\hpOutput.c
# End Source File
# Begin Source File

SOURCE=.\iCBConstruct.c
# End Source File
# Begin Source File

SOURCE=.\iCBSearch.c
# End Source File
# Begin Source File

SOURCE=.\iLBC_decode.c
# End Source File
# Begin Source File

SOURCE=.\iLBC_encode.c
# End Source File
# Begin Source File

SOURCE=.\LPCdecode.c
# End Source File
# Begin Source File

SOURCE=.\LPCencode.c
# End Source File
# Begin Source File

SOURCE=.\lsf.c
# End Source File
# Begin Source File

SOURCE=.\packing.c
# End Source File
# Begin Source File

SOURCE=.\StateConstructW.c
# End Source File
# Begin Source File

SOURCE=.\StateSearchW.c
# End Source File
# Begin Source File

SOURCE=.\syntFilter.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\anaFilter.h
# End Source File
# Begin Source File

SOURCE=.\constants.h
# End Source File
# Begin Source File

SOURCE=.\createCB.h
# End Source File
# Begin Source File

SOURCE=.\doCPLC.h
# End Source File
# Begin Source File

SOURCE=.\enhancer.h
# End Source File
# Begin Source File

SOURCE=.\filter.h
# End Source File
# Begin Source File

SOURCE=.\FrameClassify.h
# End Source File
# Begin Source File

SOURCE=.\gainquant.h
# End Source File
# Begin Source File

SOURCE=.\getCBvec.h
# End Source File
# Begin Source File

SOURCE=.\helpfun.h
# End Source File
# Begin Source File

SOURCE=.\hpInput.h
# End Source File
# Begin Source File

SOURCE=.\hpOutput.h
# End Source File
# Begin Source File

SOURCE=.\iCBConstruct.h
# End Source File
# Begin Source File

SOURCE=.\iCBSearch.h
# End Source File
# Begin Source File

SOURCE=.\iLBC_decode.h
# End Source File
# Begin Source File

SOURCE=.\iLBC_define.h
# End Source File
# Begin Source File

SOURCE=.\iLBC_encode.h
# End Source File
# Begin Source File

SOURCE=.\LPCdecode.h
# End Source File
# Begin Source File

SOURCE=.\LPCencode.h
# End Source File
# Begin Source File

SOURCE=.\lsf.h
# End Source File
# Begin Source File

SOURCE=.\packing.h
# End Source File
# Begin Source File

SOURCE=.\StateConstructW.h
# End Source File
# Begin Source File

SOURCE=.\StateSearchW.h
# End Source File
# Begin Source File

SOURCE=.\syntFilter.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
