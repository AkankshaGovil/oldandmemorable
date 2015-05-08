#################################################################
#################################################################
##
##                      Makefile
##
#################################################################
#################################################################
##
## Makefile for making Perl Libraries.
##

## 
## Targets supported are 
##
## config - creates the Makefile from Makefile.PL
##          it is better to generate this in separate step from install
##          so the module is not recompiled if it is already compiled
##
## install - installs the modules in $BASE/lib
##
## clean - runs make clean in all perl mod subdirs
##

##
## Add all the perl module names which follow the standard processing
##

ifeq ("${MKMK_VER}","new")
MKMK_PRE = "PREFIX=$(BASE)"
else
MKMK_POS = "PREFIX=$(BASE)"
endif

PAR_FILE = $(BASE)/lib/mod.par
PAR_SCRIPT = $(BASE)/lib/pmod
PAR_DIR = PAR-0.65
PAR_PL = $(BASE)/plib/$(PAR_DIR)/blib/script/par.pl
BLIB_SUBDIR = arch/ lib/ script/

PERL_MOD_DIRS = Statistics-Descriptive-2.4 \
	Mail-Sendmail-0.78 \
	Date-EzDate-0.93 \
	libnet-1.0704 \
	MIME-Base64-2.12 \
	File-Rsync-0.20 \
	Net-Telnet-3.02 \
	File-Tail-0.99.3 \
	Time-HiRes-1.35 \
	Digest-Perl-MD5-1.5 \
	DBI-1.18 \
	DBD-mysql-2.9004 \
	Config-Simple-2.82 \
	encryption \
	TermReadKey-2.21 \
	Compress-Zlib-1.21 \
	Archive-Zip-1.05 \
	Module-ScanDeps-0.17 \
	$(PAR_DIR) 


#	Msql-Mysql-modules-1.2219 \

OTH_MOD_DIRS = expat-2.0.1 \
	XML-Parser-2.30 \
	XML-Simple-1.08_01


NARS_INSTALL_PERL_MOD_DIRS = \
        Data-Dumper-2.101 \
	TermReadKey-2.21 \
        Config-Simple-4.55

NARS_INSTALL_OTH_MOD_DIRS = expat-2.0.1 \
	XML-Parser-2.34 \
        XML-Simple-2.09 \
            Socket6-0.23
	
PLIBDIRS = $(PERL_MOD_DIRS) $(OTH_MOD_DIRS) $(NARS_INSTALL_PERL_MOD_DIRS) $(NARS_INSTALL_OTH_MOD_DIRS)

# the perl module the narsagent will need as of 3.1
ifneq ("${PLATFORM}", "linux")
NARSAGENT_PERL_MODS =	File-Tail-0.99.3 \
			Config-Simple-4.55 \
			Time-HiRes-1.35 \
			Digest-Perl-MD5-1.6 \
			MIME-Base64-3.01 \
			libnet-1.18 \
			URI-1.30 \
			HTML-Parser-3.36 \
			Crypt-SSLeay-0.57 \
			libwww-perl-5.79 \
			DBI-1.42 \
			DBD-mysql-2.9004 \
                        encryption \
			TermReadKey-2.21 \
			INET6-2.01 \
			Net-INET6Glue-0.4
else
# for linux, DBD-mysql is built separately in order to build shared object instead of linked object
# That's because, the linux build machine has mysqlclient.so installed, thus links to that, other
# platforms just have mysqlclient.a
NARSAGENT_PERL_MODS =	File-Tail-0.99.3 \
			Config-Simple-4.55 \
			Time-HiRes-1.35 \
			Digest-Perl-MD5-1.6 \
			MIME-Base64-3.01 \
			libnet-1.18 \
			URI-1.30 \
			HTML-Parser-3.36 \
			Crypt-SSLeay-0.57 \
			libwww-perl-5.79 \
			DBI-1.42 \
			encryption \
			TermReadKey-2.21 \
            INET6-2.01 \
            Net-INET6Glue-0.4
endif


#			Msql-Mysql-modules-1.2219 \

#			TermReadKey-2.21 \
#			Compress-Zlib-1.21 \
#			Archive-Zip-1.05 \
#			Module-scanDeps-0.17 \
#			Data-Dumper-2.101

NARSAGENT_OTH_MODS = 	expat-2.0.1 \
			XML-Parser-2.34 \
			XML-Simple-2.09 \
            Socket6-0.23
		     

NARSAGENT_PLIB_DIRS = $(NARSAGENT_PERL_MODS) $(NARSAGENT_OTH_MODS)


##
## install
##
install lib exec: compile createdist

##
## narsinstall
##
#narsinstall: checkmysql compile createdist
narsinstall: compile createdist
	@(cd $(BASE)/lib; tar uf libperl.tar)

#	@(cd $(BASE)/lib; tar uf libperl.tar libmysqlclient.so.10)


narsagent: narsagent_oth_compile narsagent_perl_compile createdist

narsagent_oth_compile: .DUMMY $(NARSAGENT_OTH_MODS)
	@(cd expat-2.0.1; if [ ! -r Makefile ]; then ./configure; fi)
	@(cd expat-2.0.1; make prefix=$(BASE) bindir=$(BASE)/bin/$(TARGET) libdir=$(BASE)/lib/$(TARGET) install)
	@(cd XML-Parser-2.34; if [ ! -r Makefile ]; then perl Makefile.PL EXPATINCPATH=$(BASE)/include EXPATLIBPATH=$(BASE)/lib/$(TARGET) $(MKMK_PRE); fi)
	@(cd XML-Parser-2.34; make $(MKMK_POS) install)
	@(cd XML-Simple-2.09; if [ ! -r Makefile ]; then perl -I$(BASE)/lib/perl5/site_perl Makefile.PL $(MKMK_PRE); fi)
	@(cd XML-Simple-2.09; make $(MKMK_POS) install)
	@(cd Socket6-0.23; if [ ! -r Makefile ]; then chmod +x configure; ./configure; fi)
	@(cd Socket6-0.23; perl Makefile.PL $(MKMK_PRE); make $(MKMK_POS) install)
ifeq ("${TARGET}", "x86_64") 
		echo "*********======================***********"
		echo "The version target is ${TARGET} (64bit) "
   		echo "*********======================***********"
		#ifeq ("${PLATFORM}", "linux")
		#ifeq ($(origin MYSQLCLIENT), undefined)
			# if no specific mysql client is given, use the machine default
		#@(mkdir $(BASE)/mysql-static; cp /usr/lib/mysql/*.a $(BASE)/mysql-static; cd DBD-mysql-2.9004; perl Makefile.PL --libs="-L$(BASE)/mysql-static -lmysqlclient -lz -lcrypt -lnsl -lm " $(MKMK_PRE); make $(MKMK_POS) install; rm -rf $(BASE)/mysql-static)
		#else
			# if a specific mysql client is given, use that
		#@(cd DBD-mysql-2.9004; perl Makefile.PL --cflags="-I$(MYSQLCLIENT)/include -march=i586 -mcpu=i686 -fmessage-length=0 -DPIC -fPIC -fno-strict-aliasing" --libs="-L$(MYSQLCLIENT)/lib -lmysqlclient -lz -lcrypt -lnsl -lm -L$(MYSQLCLIENT)/icc -lirc" $(MKMK_PRE); make $(MKMK_POS) install)
		#endif
		#endif
else 
		echo "*********======================***********"
		echo "The version target is ${TARGET} (32 bit) " 
		echo "*********======================***********" 
ifeq ("${PLATFORM}", "linux")
ifeq ($(origin MYSQLCLIENT), undefined)
			# if no specific mysql client is given, use the machine default
		@(mkdir $(BASE)/mysql-static; cp /usr/lib/mysql/*.a $(BASE)/mysql-static; cd DBD-mysql-2.9004; perl Makefile.PL --libs="-L$(BASE)/mysql-static -lmysqlclient -lz -lcrypt -lnsl -lm " $(MKMK_PRE); make $(MKMK_POS) install; rm -rf $(BASE)/mysql-static)
else
			#if a specific mysql client is given, use that
		@(cd DBD-mysql-2.9004; perl Makefile.PL --cflags="-I$(MYSQLCLIENT)/include -march=i586 -mcpu=i686 -fmessage-length=0 -DPIC -fPIC -fno-strict-aliasing" --libs="-L$(MYSQLCLIENT)/lib -lmysqlclient -lz -lcrypt -lnsl -lm -L$(MYSQLCLIENT)/icc -lirc" $(MKMK_PRE); make $(MKMK_POS) install)
endif
endif
endif

narsagent_perl_compile: .DUMMY $(NARSAGENT_PERL_MODS)
	@for subdir in $(NARSAGENT_PERL_MODS); do \
		(cd $$subdir;  if [ ! -r Makefile ]; then perl Makefile.PL $(MKMK_PRE); fi; exit $$?; ); \
		if [ $$? -ne 0 ]; then \
			echo "======================"; \
			echo "Error making Makefile in $$subdir"; \
			echo "======================"; \
			exit 1; \
		fi; \
		(cd $$subdir;  make $(MKMK_POS) install; exit $$?; ); \
		if [ $$? -ne 0 ]; then \
			echo "======================"; \
			echo "Error Compiling and Installing $$subdir"; \
			echo "======================"; \
			exit 1; \
		fi; \
	done


##
## compile
##
compile: othmod_compile perlmod_compile

othmod_compile: .DUMMY
	@(cd expat-2.0.1; if [ ! -r Makefile ]; then ./configure; fi)
	@(cd expat-2.0.1; make prefix=$(BASE) bindir=$(BASE)/bin/$(TARGET) libdir=$(BASE)/lib/$(TARGET) install)
	@(cd XML-Parser-2.30; if [ ! -r Makefile ]; then perl Makefile.PL EXPATINCPATH=$(BASE)/include EXPATLIBPATH=$(BASE)/lib/$(TARGET) $(MKMK_PRE); fi)
	@(cd XML-Parser-2.30; make $(MKMK_POS) install)
	@(cd XML-Simple-1.08_01; if [ ! -r Makefile ]; then perl -I$(BASE)/lib/perl5/site_perl Makefile.PL $(MKMK_PRE); fi)
	@(cd XML-Simple-1.08_01; make $(MKMK_POS) install)

perlmod_compile: .DUMMY
	@for subdir in $(PERL_MOD_DIRS); do \
		(cd $$subdir;  if [ ! -r Makefile ]; then perl Makefile.PL $(MKMK_PRE); fi; exit $$?; ); \
		if [ $$? -ne 0 ]; then \
			echo "======================"; \
			echo "Error making Makefile in $$subdir"; \
			echo "======================"; \
			exit 1; \
		fi; \
		(cd $$subdir;  make $(MKMK_POS) install; exit $$?; ); \
		if [ $$? -ne 0 ]; then \
			echo "======================"; \
			echo "Error Compiling and Installing $$subdir"; \
			echo "======================"; \
			exit 1; \
		fi; \
	done


##
## createdist
##
createdist: .DUMMY
	@(cd $(BASE)/lib/perl5/site_perl; cp -fpR $(PERLVERSION) $(PERLADJVERSION); cp -fpR $(PERLVERSION) $(PERLOLDVERSION);)
	@(cd $(BASE)/lib; tar cf libperl.tar perl5)
	@(cd $(BASE)/lib/$(TARGET); tar cf libexpatpackage.tar libexpat.* ; mv -f libexpatpackage.tar .. )

##
## install_par
##
install_par: create_par

##
## create_par
##
create_par: checkmysql othmod_par perlmod_par encrypt_par

othmod_par: .DUMMY
	@(cd expat-2.0.1; if [ ! -r Makefile ]; then ./configure; fi)
	@(cd expat-2.0.1; make prefix=$(BASE) bindir=$(BASE)/bin/$(TARGET) libdir=$(BASE)/lib/$(TARGET) install)
	@(cd XML-Parser-2.30; if [ ! -r Makefile ]; then perl Makefile.PL EXPATINCPATH=$(BASE)/include EXPATLIBPATH=$(BASE)/lib/$(TARGET); fi)
	@(cd XML-Parser-2.30; make; cp -fpR blib/ $(BASE)/lib/ );
	@(cd XML-Simple-1.08_01; if [ ! -r Makefile ]; then perl -I$(BASE)/lib/perl5/site_perl Makefile.PL; fi)
	@(cd XML-Simple-1.08_01; make; cp -fpR blib/ $(BASE)/lib/ );

perlmod_par: .DUMMY
	@for subdir in $(PERL_MOD_DIRS); do \
		(cd $$subdir;  if [ ! -r Makefile ]; then perl Makefile.PL; fi; exit $$?; ); \
		if [ $$? -ne 0 ]; then \
			echo "======================"; \
			echo "Error making Makefile in $$subdir"; \
			echo "======================"; \
			exit 1; \
		fi; \
		(cd $$subdir;  make; exit $$?; ); \
		if [ $$? -ne 0 ]; then \
			echo "======================"; \
			echo "Error Compiling $$subdir"; \
			echo "======================"; \
			exit 1; \
		fi; \
		(cd $$subdir;  cp -fpR blib/ $(BASE)/lib/; exit $$?; ); \
		if [ $$? -ne 0 ]; then \
			echo "======================"; \
			echo "Error installing $$subdir in $(PAR_FILE)"; \
			echo "======================"; \
			exit 1; \
		fi; \
	done

encrypt_par: .DUMMY
	@(cd encryption; make install_encrypt; )

##
## pardist
##
pardist: .DUMMY
	@(zip -r $(PAR_FILE) run )
	@(cd $(BASE)/lib/blib; zip -r $(PAR_FILE) $(BLIB_SUBDIR); )
	@(cd $(BASE)/lib; $(PAR_PL) -b -O$(PAR_SCRIPT) $(PAR_FILE); )
	@(cd $(BASE)/lib/$(TARGET); tar cvf libexpatpackage.tar libexpat.* ; mv -f libexpatpackage.tar .. )

##
## checkmysql
##
checkmysql: .DUMMY
	@(if (test ! -r /usr/local/mysql/lib/mysql/libmysqlclient.so.10); then \
		echo "============================================================================="; \
		echo "Need local mysql installation at /usr/local/mysql to create narsagent package"; \
		echo "============================================================================="; \
		exit 1; \
	fi; \
	if (test ! -d $(BASE)/lib); then \
		mkdir $(BASE)/lib; \
	fi; \
	cd $(BASE)/lib; $(BASE)/utils/links.sh $(TARGET) Makefile);
	cd $(BASE)/lib; cp /usr/local/mysql/lib/mysql/libmysqlclient.so.10 .;

##
## narsInstall: For creating library for narsInstall.tar 2.06t2
##
narsInstall: narsCompile narsCreateDist
	@(cd $(BASE)/lib; tar uf libperl.tar)

narsCompile: narsothmod_compile narsperlmod_compile

narsothmod_compile: .DUMMY
	@(cd expat-2.0.1; if [ ! -r Makefile ]; then ./configure; fi)
	@(cd expat-2.0.1; make prefix=$(BASE) bindir=$(BASE)/bin/$(TARGET) libdir=$(BASE)/lib/$(TARGET) install)
	@(cd XML-Parser-2.34; if [ ! -r Makefile ]; then perl Makefile.PL EXPATINCPATH=$(BASE)/include EXPATLIBPATH=$(BASE)/lib/$(TARGET) $(MKMK_PRE); fi)
	@(cd XML-Parser-2.34; make $(MKMK_POS) install)
	@(cd XML-Simple-2.09; if [ ! -r Makefile ]; then perl -I$(BASE)/lib/perl5/site_perl Makefile.PL $(MKMK_PRE); fi)
	@(cd XML-Simple-2.09; make $(MKMK_POS) install)

narsperlmod_compile: .DUMMY
	@for subdir in $(NARS_INSTALL_PERL_MOD_DIRS); do \
                (cd $$subdir;  if [ ! -r Makefile ]; then perl Makefile.PL $(MKMK_PRE); fi; exit $$?; ); \
                if [ $$? -ne 0 ]; then \
                        echo "======================"; \
                        echo "Error making Makefile in $$subdir"; \
                        echo "======================"; \
                        exit 1; \
                fi; \
                (cd $$subdir;  make $(MKMK_POS) install; exit $$?; ); \
                if [ $$? -ne 0 ]; then \
                        echo "======================"; \
                        echo "Error Compiling and Installing $$subdir"; \
                        echo "======================"; \
                        exit 1; \
                fi; \
        done

narsCreateDist: .DUMMY
	@(cd $(BASE)/lib/perl5/site_perl; cp -fpR $(PERLVERSION) $(PERLADJVERSION); cp -fpR $(PERLVERSION) $(PERLOLDVERSION);)
	@(cd $(BASE)/lib; tar cvf libperl.tar perl5)
	@(cd $(BASE)/lib/$(TARGET); tar cvf libexpatpackage.tar libexpat.* ; mv -f libexpatpackage.tar .. )
##
## clean
##
clean: .DUMMY
	@for subdir in $(PLIBDIRS); do \
		(cd $$subdir;  if [ -r Makefile ]; then make clean; fi; exit $$?; ); \
		if [ $$? -ne 0 ]; then \
			echo "======================"; \
			echo "Error cleaning $$subdir"; \
			echo "======================"; \
			exit 1; \
		fi \
	done

cleannarsagent: .DUMMY
	@for subdir in $(NARSAGENT_PLIB_DIRS); do \
		echo "Cleaning $$subdir"; \
		(cd $$subdir;  if [ -r Makefile ]; then make clean; fi; exit $$?; ); \
		if [ $$? -ne 0 ]; then \
			echo "======================"; \
			echo "Error cleaning $$subdir"; \
			echo "======================"; \
			exit 1; \
		fi \
	done

.DUMMY:
