ILBCDLL	= libilbs.so

ILBCSRCS = FrameClassify.c LPCdecode.c LPCencode.c StateConstructW.c StateSearchW.c \
anaFilter.c constants.c createCB.c doCPLC.c enhancer.c filter.c gainquant.c getCBvec.c \
helpfun.c hpInput.c hpOutput.c iCBConstruct.c iCBSearch.c iLBC_decode.c iLBC_encode.c \
iLBC_test.c lsf.c packing.c syntFilter.c

ILBCOBJS := $(ILBCSRCS:.c=.o)

%.o : %.c 
	$(CC) -fPIC $(STDCCFLAGS) $(OPTCCFLAGS) $(CFLAGS) -c $< -o $@

$(ILBCDLL): $(ILBCOBJS)
	$(CC) -Wl,-soname,$(ILBCDLL) -o $(ILBCDLL) -lm $(ILBCOBJS) 

clean:
	rm -f $(ILBCOBJS) $(ILBCDLL)
