#!/usr/bin/perl

# $Id$
# License: OSI Artistic License
# Author:  (c) 2005 Soren Dossing
# Author:  (c) 2008 Alan Brenner, Ithaka Harbors
# Author:  (c) 2010 Matthew Wall

# The configuration file and ngshared.pm must be in this directory:
#use lib '/usr/local/nagios/etc/nagiosgraph';
use lib '/opt/nagiosgraph/etc/';

use ngshared;
use English qw(-no_match_vars);
use strict;
use warnings;
use CGI qw();

my $c = CGI->new;

my $header='
<!DOCTYPE html
 PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<title>nagiosgraph:  - </title>  

Testing..

<body id="nagiosgraph"> 

';

print $header;
my $x=`id`;
print "myid=$x<br>";
if ('POST' ne $c->request_method ) {
    exit(0);
}
my ($user, $host, $password);
    # yes, parameter exists

my $dbfile="/usr/local/ns/configdb";
my $configtemplate_dir="/opt/nonstop_extensions/etc/nsservers/";
my $configtemplate_file="/opt/nonstop_extensions/etc/ns_template";

my $out=`cat $dbfile`;
my $btnPressed=$c->param('btnAdd');

$btnPressed=$c->param('btnDelete') if ($c->param('btnDelete') !~ /^\s*$/);
$btnPressed=$c->param('btnUpdateServices') if ($c->param('btnUpdateServices') !~ /^\s*$/);

if ($btnPressed !~ /Add|Delete|UpdateServices/) {
   print " ERROR : You shouldn't see this <br>";
   exit(0) 
}
    $user=$c->param('user');
    $user="SUPER.SUPER";
    $host=uc($c->param('host'));
    $password=$c->param('password');

print "<br>";
print "host=".$c->param('host')."<br>";
print "user=".$c->param('user')."<br>";
print "password=".$c->param('password')."<br>";
    

my %hostdetails = ();
my $t;

foreach $t (split(/\n/,$out)) {
print "t=$t <br>";
    my ($h, $u, $p)=split(/\|/,$t);
    $hostdetails{$h}="$u|$p";
    print "h=$h, u=$u, p=$p<br>";
}
$hostdetails{$host}="$user|$password";

if ($btnPressed =~ /Add/ ) {

   open(FH, ">$dbfile") or die "could not open file for writing";
   print "opend succss<br>";
   foreach $t (keys(%hostdetails)) {
      print  "$t|".$hostdetails{$t}."<br>\n";
      print  FH "$t|".$hostdetails{$t}."\n";
   }
   close(FH);

   if ($out =~ /^$host\|/i ) {
       print "$host already exists .. Updated with new information <br>";
   } else {
   print "Updated config files for new host ($host).. <br>";
#use tempate and update hostnames and create a new file 
   my $simple_hostname=$host;
   $simple_hostname =~ s/\..*//;
#Copying the template as required hostname's file
   print "simple hostname=$simple_hostname<br>";
   my $tout=`cp -f $configtemplate_file $configtemplate_dir/$simple_hostname.cfg 2>&1  `;
   print "cp output |$tout|<br>";
#updating the hostname details 
   $tout=`sed -i 's/MYHOST.FQDN/$host/' $configtemplate_dir/$simple_hostname.cfg 2>&1`;
   $tout=`sed -i 's/myhostname/$simple_hostname/' $configtemplate_dir/$simple_hostname.cfg 2>&1`;
   print "sed output |$tout|<br>";
   if ($tout !~ /^\s*$/) {
         print "Error: while running sed ($tout)<br>";
         exit(0);
   }

   #Following will not work in latest Nagios vesion - Should be restarted by user
   #my $reload=`/etc/init.d/nagios reload `;

   #print "Nagios Reloaded..($reload) \n";
   #15/Mar/19 - RGH
   print '<br> <font size="5" color="red"> <B>Changes will be effective once Nagios is restarted. You can restart Nagios from Process Info link in side bar </B> </font> <br>';
  } 

} elsif ($btnPressed =~ /UpdateServices/) {

  foreach $t (split(/\n/,$out)) {
    my ($h, $u, $p)=split(/\|/,$t);
    $hostdetails{$h}="$u|$p";
#use tempate and update hostnames and create a new file 
     my $host=$h;
     my $simple_hostname=$host;
     $simple_hostname =~ s/\..*//;
#Copying the template as required hostname's file
     print "simple hostname=$simple_hostname<br>";
     my $tout=`cp -f $configtemplate_file $configtemplate_dir/$simple_hostname.cfg 2>&1  `;
     print "cp output |$tout|<br>";
#updating the hostname details 
     $tout=`sed -i 's/MYHOST.FQDN/$host/' $configtemplate_dir/$simple_hostname.cfg 2>&1`;
     $tout=`sed -i 's/myhostname/$simple_hostname/' $configtemplate_dir/$simple_hostname.cfg 2>&1`;
     print "sed output |$tout|<br>";
     if ($tout !~ /^\s*$/) {
         print "Error: while running sed ($tout)<br>";
         exit(0);
     }
  }
  #my $reload=`/etc/init.d/nagios reload `;
   print '<br> <font size="5" color="red"> <B>Changes will be effective once Nagios is restarted. You can restart Nagios from Process Info link in side bar </B> </font> <br>';

} else {

  if ($out =~ /^$host\|/i ) {
     print "$host has been deleted .. <br>";
  } else {
     print "$host doesn't exists .. <br>";
  }
}

print "<br>Success<br>";
