include $(BASE)/na.mk

ALARM_ENCR_FILES = \
			logpp

# ALARM_ENCR_MODULES =

# ALARM_OTHER_FILES =

install: Makefile createtemp license $(ALARM_ENCR_FILES) $(ALARM_ENCR_MODULES) $(ALARM_OTHER_FILES)
	@(for file in $(ALARM_ENCR_FILES); do \
		cp -f $$file $(FILE_DIR)/; \
		$(ENCR) $(FILE_DIR)/$$file; \
	done)
#	@(for file in $(ALARM_ENCR_MODULES); do \
#		cp -f $$file $(MODULE_DIR)/; \
#		$(ENCR) $(MODULE_DIR)/$$file; \
#	done)
#	@(cp -f $(ALARM_OTHER_FILES) $(FILE_DIR)/)

license: .DUMMY
	@(if [ ! -d $(MODULE_DIR)/$(LICENSE_FILE) ]; then \
		print "License Module not yet installed \n"; \
	fi)

createtemp: .DUMMY
	@(if [ ! -d $(MODULE_DIR) ]; then \
		mkdir $(MODULE_DIR); \
	fi)

install_par: Makefile createlib $(ALARM_ENCR_FILES)
	@(for file in $(ALARM_ENCR_FILES); do \
		sed -e '1s,.*,#!/bin/sh runmod,' $$file > $(FILE_DIR)/$$file; \
		chmod a+x $(FILE_DIR)/$$file; \
		$(ENCR) $(FILE_DIR)/$$file; \
	done)

createlib: .DUMMY
	@(if [ ! -d $(MOD_LIBDIR) ]; then \
		mkdir -p $(MOD_LIBDIR); \
	fi)

clean: .DUMMY
	@(for file in $(ALARM_ENCR_FILES) $(ALARM_OTHER_FILES); do \
		rm -f $(FILE_DIR)/$$file; \
	done)
#	@(for file in $(ALARM_ENCR_MODULES); do \
#		rm -f $(MODULE_DIR)/$$file; \
#	done)

.DUMMY:

