:: set the sql path
PATH=%PATH%;SQL_PATH;PERL_PATH


:: create nars tables
cd INSTALL_PATH
mysql <nars-tables-upgrade.sql
 
:: execute licence module
perl nars_lic_install.pl
