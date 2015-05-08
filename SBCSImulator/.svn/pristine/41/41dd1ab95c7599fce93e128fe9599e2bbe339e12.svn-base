include $(BASE)/na.mk

CDRSERVER_ENCR_FILES = \
			cdrserver.pl \
			rateunrated.pl \
			cdrcatchup.pl \
			gencdrs.pl \
			rateone.pl \
			monitor.pl

CDRSERVER_ENCR_MODULES = \
			Cdrposter.pm \
			Cdrstreamer.pm \
			Cdrfilter.pm \
			Sqlstatements.pm \
			Logger.pm \
			Config.pm \
			validate.pm \
			version.pm \
			Constants.pm \
            Poster.pm \
            Trapposter.pm

CDRSERVER_OTHER_FILES =	\
			narsagent \
                        rungencdr \
                        runcdrcatchup \
			narspm \
			cdrdel \
			nars.cfg \
			gencdrs.cfg \
			narslog.cfg \
			libmysqlclient16-5.1.36-6.7.2.x86_64.rpm \
			perl-Data-ShowTable-3.3-707.3.x86_64.rpm \
			perl-DBD-mysql-4.012-2.1.x86_64.rpm \
			error.properites

install: Makefile createtemp license $(CDRSERVER_ENCR_FILES) $(CDRSERVER_ENCR_MODULES) $(CDRSERVER_OTHER_FILES)
	@(for file in $(CDRSERVER_ENCR_FILES); do \
		cp -f $$file $(FILE_DIR)/; \
		$(ENCR) $(FILE_DIR)/$$file; \
	done)
	@(for file in $(CDRSERVER_ENCR_MODULES); do \
		cp -f $$file $(MODULE_DIR)/; \
		$(ENCR) $(MODULE_DIR)/$$file; \
	done)
	@(cp -f $(CDRSERVER_OTHER_FILES) $(FILE_DIR)/)

license: .DUMMY
	@(if [ ! -d $(MODULE_DIR)/$(LICENSE_FILE) ]; then \
		print "License Module not yet installed \n"; \
	fi)

createtemp: .DUMMY
	@(if [ ! -d $(MODULE_DIR) ]; then \
		mkdir $(MODULE_DIR); \
	fi)

clean: .DUMMY
	@(for file in $(CDRSERVER_ENCR_FILES) $(CDRSERVER_OTHER_FILES); do \
		rm -f $(FILE_DIR)/$$file; \
	done)
	@(for file in $(CDRSERVER_ENCR_MODULES); do \
		rm -f $(MODULE_DIR)/$$file; \
	done)

install_par: Makefile createlib $(CDRSERVER_ENCR_FILES) $(CDRSERVER_ENCR_MODULES) $(CDRSERVER_OTHER_FILES)
	@(for file in $(CDRSERVER_ENCR_FILES); do \
		sed -e '1s,.*,#!/bin/sh runmod,' $$file > $(FILE_DIR)/$$file; \
		chmod a+x $(FILE_DIR)/$$file; \
		$(ENCR) $(FILE_DIR)/$$file; \
	done)
	@(for file in $(CDRSERVER_ENCR_MODULES); do \
		cp -f $$file $(MOD_LIBDIR)/; \
		$(ENCR) $(MOD_LIBDIR)/$$file; \
	done)
	@(cp -f $(CDRSERVER_OTHER_FILES) $(FILE_DIR)/)

createlib: .DUMMY
	@(if [ ! -d $(MOD_LIBDIR) ]; then \
		mkdir -p $(MOD_LIBDIR); \
	fi)


.DUMMY:

