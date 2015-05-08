/*
 * dllcodec.h
 *
 * Definition for dll codecs
 *
 * Open H323 Library
 *
 * Copyright (c) 2003 Equivalence Pty. Ltd.
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
 * $Log: dllcodec.h,v $
 * Revision 1.2  2003/04/30 04:57:13  craigs
 * Changed interface to DLL codec to improve Opal compatibility
 *
 * Revision 1.1  2003/04/27 23:48:24  craigs
 * Initial version
 *
 */

#ifndef _OPALDLLCODEC
#define _OPALDLLCODEC

typedef void * OpalDLLCodecContextCreate(void * userData);

typedef void OpalDLLCodecContextDestroy(void * userData, void * context);

typedef BOOL OpalDLLCodecEncode(void * userData, void * context, 
                                const void * fromData, unsigned   fromLen, 
                                      void * toData,   unsigned * toLen);

typedef void OpalDLLCodecSetParameter(void * userData, const char * attribute, const char * value);
typedef BOOL OpalDLLCodecGetParameter(void * userData, const char * attribute, char * value, int len) ;

typedef struct OpalDLLCodecKeyValue {
  const char * key;
  const char * value;
} OpalDLLCodecKeyValue;

typedef struct OpalDLLCodecInfo {

  const OpalDLLCodecKeyValue * attributes;
  const OpalDLLCodecKeyValue * attributes2;

  void * codecUserData;

  // encoder routines
  OpalDLLCodecContextCreate  * createContext;
  OpalDLLCodecContextDestroy * destroyContext;
  OpalDLLCodecEncode         * encoder;

  OpalDLLCodecSetParameter   * setParameter; 
  OpalDLLCodecGetParameter   * getParameter; 

} OpalDLLCodecInfo;

#endif
