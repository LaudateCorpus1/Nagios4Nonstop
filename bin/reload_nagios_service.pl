########################################################################################
# Copyright 2020 Hewlett Packard Enterprise Development LP. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
# 
#    1. Redistributions of source code must retain the above copyright notice, this list of
#       conditions and the following disclaimer.
# 
#    2. Redistributions in binary form must reproduce the above copyright notice, this list
#       of conditions and the following disclaimer in the documentation and/or other materials
#       provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY Hewlett Packard Enterprise Development LP ``AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Hewlett Packard Enterprise Development LP OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The views and conclusions contained in the software and documentation are those of the
# authors and should not be interpreted as representing official policies, either expressed
# or implied, of Hewlett Packard Enterprise Development LP.
########################################################################################

use strict;
use Getopt::Long;

my $out;
my $force=0;
my $debug=1;
my $maxtime=10;

my $warning=0;
my $critical=0;
my $verbose;
my $ret_code=0;
my $cpu;
my $result;
my $cpu_number;
my $hostaddress;

$result = GetOptions(
            "warning=i" => \$warning,    # numeric
            "critical=i"   => \$critical,      # string
            "hostaddress=s"   => \$hostaddress,      # string
            "verbose"  => \$verbose
          );


my $target_file="/opt/nonstop_extensions/etc/nsservers";

#check if the target file exists and file modified in last 5 minutes
#stat -c "%Y" tmp.txt
#date +%s
my $t=`cat /tmp/reloadtime;echo ":";stat -c "%Y" $target_file;`;
my ($t1, $t2, $time_diff);
if ($t =~ /(\d+)\s*:\s*(\d+)/s) {
  $t2=$1;
  $t1=$2;
} else {
print "forced\n";
   $force=1;
}
$time_diff=$t2-$t1;

chomp($t1);
$t1=0 if ($t1 !~ /\d+/);

print "time_diff=$time_diff\n" if ($debug);

if ( $force or $time_diff < $maxtime ) {
   print "Restarted nagios configurations\n";
   $out=`/etc/init.d/nagios reload `;
} 
system("date +%s > /tmp/reloadtime");
