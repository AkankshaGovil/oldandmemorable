
INSTALL_FILES = getethers prodtest remap versions checkiedge lgenx lgenx-43 lgenx-50 \
		ntsw runser recover-net run_ser gnugk ohphone compareResults.sh suiteExe_all_scm gen_new asterisk \
		rtpsend suiteExe_all_scm_4.0 suiteExe_all_scm_4.3 suiteExe_all_scm_5.0 suiteExe_all_scm_sbb \
                suiteExe_all_scm_verizon suiteExe_all_scm_5.1 opensips

NIGHTLY_BUILD_FILES = NightlyBuildScript.txt applyPatch.exp install_hotknife.exp kill_ssh.exp \
                rebootGen.exp update_iserver_license.exp run_nextest run_nextest_hourly\
                freeradius-client-0.9.3-2.i586.rpm iserverlc.xml.dailybuild generateResult.sh\
                installPatch4.0c1-3 installPatch4.2c1-3 mailConfig.cfg mailer.py mailwrapper.py\
                rebootGen.exp update_nxlinux.sh emailattach.py attachwrapper.py nightlyBuild4.3.cfg \
		nightlyBuild4.2.cfg nightlyBuild.cfg nightlyBuild iserverlc.4.3.xml iserverlc.4.2.xml \
		iserverlc.5.0.xml nightlyBuild5.0.cfg iserverlc.5.1.xml nightlyBuild5.1.cfg


dist:
	mkdir $(BUILD_ROOT)/bin
	cp $(INSTALL_FILES) $(BUILD_ROOT)/bin

	mkdir -p $(BUILD_ROOT)/bin/Nightly_Builds
	(cd Nightly_Builds; cp $(NIGHTLY_BUILD_FILES) $(BUILD_ROOT)/bin/Nightly_Builds)


clean:
	@ echo "cleaning bin..."
	rm -f *~
