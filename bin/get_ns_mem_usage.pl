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
use File::Basename;

chdir(dirname($0)) or die "Coun't chdir from this path $0\n";

my $warning=60;
my $critical=80;
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

our @mem_usage=();
our $status="Memory OK";
our $perf_data="";
our $main_data="";
my $index=0;
my $out;

$out=`perl ./get_stats.pl -H $hostaddress`;

my $lookup_str="See TOTAL for sum over all initiating CPUs: total data into & from each CPU.";

while ($out =~ s/(MEASURE_OUTPUT_START::)(.*?)$lookup_str(.*)(::MEASURE_OUTPUT_END)/$1$3$4/s ) {

   my $buf=$2;
   my ($total_mem,$free_mem,$used_mem);
   if ($buf =~ /Cpu\s*(\d+)/) {
       $cpu_number=int($1);
   }

   if ($buf =~ /Memory\s*MB\s*(\d+)/ ) {
       #$perf_data.=" cpu${cpu_number}_usage=".$1."MB".";$warning;$critical;";
       $perf_data.=" mem${cpu_number}_total=".$1."MB";
       $main_data.=", Memory${cpu_number} Total = ".int($1)."MB";
       $total_mem=$1;
   }

   if ($buf =~ /Ending-Free-Mem\s*(.*?)#/ ) {
       my $tmp=$1;
       $tmp =~ s/,//g;
       $tmp =~ s/\s+//g;
       $tmp=int($tmp * 16384 / (1024*1024));
       $free_mem=$tmp;
       push (@mem_usage,$tmp);
       #$perf_data.=" cpu${cpu_number}_usage=".$1."MB".";$warning;$critical;";
       $perf_data.=" mem${cpu_number}_free=".$tmp."MB";
       $main_data.=", Memory${cpu_number} Free= ".int($tmp)."MB";

#Used memory - Better visualization
       $used_mem=$total_mem-$free_mem;

       $perf_data.=" mem${cpu_number}_used=".$used_mem."MB";
       $main_data.=", Memory${cpu_number} Used= ".int($used_mem)."MB";
   }

}

$perf_data =~ s/^,//;
$perf_data =~ s/^\s+//;
$main_data =~ s/^, //;

print "$status - " . $main_data . "" . " |$perf_data" . "\n";

exit $ret_code;


