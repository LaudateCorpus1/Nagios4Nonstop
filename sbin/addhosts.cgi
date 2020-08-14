#!/usr/bin/perl

use lib '/opt/nagiosgraph/etc/';

use ngshared;
use English qw(-no_match_vars);
use strict;
use warnings;

print '
<!DOCTYPE html
 PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<title>nagiosgraph:  - </title>  

<body id="nagiosgraph"> 

';

my $remote_u=$ENV{REMOTE_USER};
if ($remote_u !~ /^nagiosadmin$/) {
   print "<br><br><B>This functionality allowed only for admin user</B><br>";
   exit(0);
}
my $sts = gettimestamp();
my ($cgi, $params) = init('show');
my ($periods, $expanded_periods) = initperiods('both', $params);

my $defaultds = readdatasetdb();
if (scalar @{$params->{db}} == 0) {
    if ($defaultds->{$params->{service}}
        && scalar @{$defaultds->{$params->{service}}} > 0) {
        $params->{db} = $defaultds->{$params->{service}};
    } elsif ($params->{host} ne q() && $params->{host} ne q(-)
             && $params->{service} ne q() && $params->{service} ne q(-)) {
        $params->{db} = dbfilelist($params->{host}, $params->{service});
    }
}


our $buf="
<form method='post' action='receivensdata.cgi'>
<INPUT TYPE='hidden' NAME='nagFormId' VALUE='b308ca00'>
<table CELLSPACING=0 CELLPADDING=5>
<tr>
</tr>
<tr>
<td>Host Name: </td>
<td><b><INPUT TYPE='TEXT' NAME='host' VALUE='brandy'></b></td>
</tr>
<tr>
<td>User Name: </td>
<td><b><INPUT TYPE='TEXT' NAME='user' VALUE='SUPER.SUPER' READONLY DISABLED ></b></td>
</tr>
<tr>
<td>Password:&nbsp;&nbsp;&nbsp;</td>
<td><b><INPUT TYPE='TEXT' NAME='password' VALUE='password'></b></td>
</tr>
<tr>
<td COLSPAN=2></td></tr>
<tr>
<td></td>
<td >
<INPUT TYPE='submit' NAME='btnAdd' VALUE='Add'> 
<INPUT TYPE='submit' NAME='btnDelete' VALUE='Delete'> 
<INPUT TYPE='submit' NAME='btnUpdateServices' VALUE='UpdateServices'> 
</td>
</tr>
</table>
</form>
";
print "$buf<br>";

