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

###############################################################################
# Purpose :
#         This scripts runs a command on Nonstop to get the count of ZZSA files
#         on the $SYSTEM.* volume. This will be counter that reflects total
#         number of crash dump files that are existing on Nonstop System
#
###############################################################################

use strict;
use Getopt::Long;

my $warning=60;
my $critical=80;
my $verbose;
my $ret_code=0;
my $result;
my $hostaddress;

$result = GetOptions(
            "warning=i" => \$warning,    # numeric
            "critical=i"   => \$critical,      # string
            "hostaddress=s"   => \$hostaddress,      # string
            "verbose"  => \$verbose
          );

our $status="OK";
our $perf_data="";
our $main_data="";
my $out;
my $zzsa_count=0;

$out=`perl /usr/local/ns/get_stats.pl -H $hostaddress`;

my $i=1;
if ($out =~ /ZZSA_COUNTER_START::(.*)::ZZSA_COUNTER_END/s ) {

   my @buf=split(/\n/,$1);
   $zzsa_count=0;

   foreach my $b (@buf) {
       ++$zzsa_count if ($b =~ /ZZSA\d+\s+130/);
   }

} else {

    print STDERR "Warning: This pattern was not matched, pattern=ZZSA_COUNTER_START::(.*)::ZZSA_COUNTER_END\n";

}
$main_data=" ZZSA Count = $zzsa_count";
$perf_data=" ZZSA_Count=$zzsa_count";

$perf_data =~ s/^,//;
$perf_data =~ s/^\s+//;
$main_data =~ s/^, //;

print "$status - " . $main_data . "" . " |$perf_data" . "\n";

exit $ret_code;


