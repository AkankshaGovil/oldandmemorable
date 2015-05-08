#!/usr/bin/perl
for($i=1; $i<=2000; $i++) 
{
$EP1="./cli iedge add Endpoint_B_".$i." 0";
$EP2="./cli iedge add Endpoint_S_".$i." 0";
print $EP1;
print $EP2;
system ("$EP1");
system ("$EP2");
}

