#!/usr/bin/perl

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# decode the MSx CDR's into field no, description, and value
# pfs rev_3-25-06
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#    usage: tail -f CDR.FILE | ./decode.pl
#    e.g.: tail -f DATA.CDR | ./decode.pl

#------------------------#
# filter the cdrdict.xml #
#------------------------#
$fn= "/usr/local/nextone/bin/cdrdict.xml";
@cdrdict= `cat $fn | grep field`;

#------------------------#
# setup the lookup array #
#------------------------#
push(@lookup, "unused");
foreach $line (@cdrdict)
{
  if (grep(/name/, $line))
  {
    @_ = split(/"/, $line);
    push(@lookup, @_[3]);
  }
  else
  {
    push(@lookup, "unused");
  }
}

#-----------------------#
# decode the CDR stream #
#-----------------------#
while (<>)
{
  $_ = $_ . ' ';
  @fields= split(";");
  $i = 1;
  foreach $value (@fields)
  {
    printf "%-2d: %-35s = %s\n", $i, $lookup[$i], $value;
    $i++;
  }
  print "\n";
}

