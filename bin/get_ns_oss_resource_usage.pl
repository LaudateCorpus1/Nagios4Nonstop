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
our $status="OK";
our $perf_data="";
our $main_data="";
my $index=0;
my $out;
my $ossopens=0;
my $afsopens=0;
my $afisopens=0;
my $diropens=0;
my $dirsopens=0;
my $ttyopens=0;
my $pipefopens=0;

$out=`perl ./get_stats.pl -H $hostaddress`;
#$out=`cat /tmp/t.txt`;

my $lookup_str="------------ OSS Resource --------------------";
my $i=1;
while ($out =~ s/(MEASURE_OUTPUT_START::)(.*)$lookup_str(.*)(::MEASURE_OUTPUT_END)/$1$2$4/s ) {
   my $buf=$3;
   if ($buf =~ s/OSSCPU//) { 
       $cpu_number=int($1);
   }
   if ($buf =~ s/OSS-Opens\s+(\S+)\s+#\s+(\S+)\s+#// ) {
        my $t=$1;
        $t =~ s/,//g;
        $ossopens+=int($t);
   }
   if ($buf =~ s/AF-UNIX-Socket-Opens\s+(\S+)\s+#\s+(\S+)\s+#// ) {
        my $t=$1;
        $t =~ s/,//g;
        $afsopens+=int($t);
   }
   if ($buf =~ s/AF-INET-Socket-Opens\s+(\S+)\s+#\s+(\S+)\s+#// ) {
        my $t=$1;
        $t =~ s/,//g;
        $afisopens+=int($t);
   }
   if ($buf =~ s/Dir-Opens\s+(\S+)\s+#\s+(\S+)\s+#// ) {
        my $t=$1;
        $t =~ s/,//g;
        $diropens+=int($t);
   }
   if ($buf =~ s/Dir-Streams\s+(\S+)\s+#\s+(\S+)\s+#// ) {
        my $t=$1;
        $t =~ s/,//g;
        $dirsopens+=int($t);
   }
   if ($buf =~ s/TTY-Opens\s+(\S+)\s+#\s+(\S+)\s+#// ) {
        my $t=$1;
        $t =~ s/,//g;
        $ttyopens+=int($t);
   }
   if ($buf =~ s/Pipe-FIFO-Opens\s+(\S+)\s+#\s+(\S+)\s+#// ) {
        my $t=$1;
        $t =~ s/,//g;
        $pipefopens+=int($t);
   }

}
$main_data=" OSS-Opens = $ossopens, AF Unix Socket Opens = $afsopens, AF INET Socket Opens = $afisopens, Pipe-FIFO-Open = $pipefopens, Dir-Opens = $diropens, Dir-Steams = $dirsopens, TTY-Opens = $ttyopens";
$perf_data=" OSS_Opens=$ossopens AF_Unix_Socket_Opens=$afsopens AF_INET_Socket_Opens=$afisopens Pipe_FIFO_Open=$pipefopens Dir_Opens=$diropens Dir_Steams=$dirsopens TTY_Opens=$ttyopens";

$perf_data =~ s/^,//;
$perf_data =~ s/^\s+//;
$main_data =~ s/^, //;

print "$status - " . $main_data . "" . " |$perf_data" . "\n";

exit $ret_code;


