include $(BASE)/na.mk

LICENSE_ENCR_MODULES = \
			LM.pm 

install: Makefile createtemp $(LICENSE_ENCR_MODULES)
	@(for file in $(LICENSE_ENCR_MODULES); do \
		cp -f $$file $(MODULE_DIR)/; \
		$(ENCR) $(MODULE_DIR)/$$file; \
	done)

createtemp: .DUMMY
	@(if [ ! -d $(MODULE_DIR) ]; then \
		mkdir $(MODULE_DIR); \
	fi)

install_par: Makefile createlib $(LICENSE_ENCR_MODULES)
	@(for file in $(LICENSE_ENCR_MODULES); do \
		cp -f $$file $(MOD_LIBDIR)/; \
		$(ENCR) $(MOD_LIBDIR)/$$file; \
	done)

createlib: .DUMMY
	@(if [ ! -d $(MOD_LIBDIR) ]; then \
		mkdir -p $(MOD_LIBDIR); \
	fi)

clean: .DUMMY
	@(for file in $(LICENSE_ENCR_MODULES); do \
		rm -f $(MODULE_DIR)/$$file; \
	done)
	
.DUMMY:
