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

my $disk_cache_buf=0;
my $pxs_buf=0;
my $pxs64_buf=0;
my $inet_buf=0;
my $afunix_buf=0;
my $pipe_buf=0;

sub get_in_mb($) {
   my $insize=shift;
   my $outsize=$insize/(1024*1024);
   return $outsize;
}

$out=`perl ./get_stats.pl -H $hostaddress`;

my $lookup_str="Dir-Streams";
my $i=1;
while ($out =~ s/(MEASURE_OUTPUT_START::)(.*?$lookup_str)(.*)(::MEASURE_OUTPUT_END)/$1$3$4/s ) {
   my $buf=$2;
   if ($buf =~ s/OSSCPU\s+(\d+)//) { 
       $cpu="cpu".int($1);
   }
   if ($buf =~ s/Disk-Cache-Buf-Bytes(.{35})// ) {
        my $t=$1;
        $t =~ s/,//g;
        $disk_cache_buf=get_in_mb(int($t));
   }
   if ($buf =~ s/PXS-Buf-Bytes(.{42})// ) {
        my $t=$1;
        $t =~ s/,//g;
        $pxs_buf=get_in_mb(int($t));
   }
   if ($buf =~ s/PXS64-Buf-Bytes(.{40})// ) {
        my $t=$1;
        $t =~ s/,//g;
        $pxs64_buf=get_in_mb(int($t));
   }
   if ($buf =~ s/AF-INET-Socket-Buf-Bytes(.{31})// ) {
        my $t=$1;
        $t =~ s/,//g;
        $inet_buf=get_in_mb(int($t));
   }
   if ($buf =~ s/AF-UNIX-Socket-Buf-Bytes(.{31})// ) {
        my $t=$1;
        $t =~ s/,//g;
        $afunix_buf=get_in_mb(int($t));
   }
   if ($buf =~ s/Pipe-FIFO-Buf-Bytes(.{36})// ) {
        my $t=$1;
        $t =~ s/,//g;
        $pipe_buf=get_in_mb(int($t));
   }

   $main_data.=" ${cpu}_Disk-Cache-Buf-Bytes = $disk_cache_buf, ${cpu}_PXS-Buf-Bytes = $pxs_buf, ${cpu}_PXS64-Buf-Bytes = $pxs64_buf, ${cpu}_AF-INET-Socket-Buf-Bytes = $inet_buf, ${cpu}_AF-UNIX-socket-buf-bytes = $afunix_buf, ${cpu}_pipe-FIFO-buf-bytes = $pipe_buf";
   $perf_data.=" ${cpu}_Disk-Cache-Buf-Bytes=$disk_cache_buf ${cpu}_PXS-Buf-Bytes=$pxs_buf ${cpu}_PXS64-Buf-Bytes=$pxs64_buf ${cpu}_AF-INET-Socket-Buf-Bytes=$inet_buf ${cpu}_AF-UNIX-socket-buf-bytes=$afunix_buf ${cpu}_pipe-FIFO-buf-bytes=$pipe_buf";

}
$perf_data =~ s/^,//;
$perf_data =~ s/^\s+//;
$main_data =~ s/^, //;

print "$status - " . $main_data . "" . " |$perf_data" . "\n";

exit $ret_code;


