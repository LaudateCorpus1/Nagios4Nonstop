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
@processes_per_cpu=( '$ZLS', '$ZPP',  '$ZRA', '$ZFM', '$ZSP', '$ZTA', '$ZTT'   );
@processes_per_system=('$ZPNS', '$ZPMON');

$perf_data="";

$data=join('',<STDIN>);
foreach $process (@processes_per_cpu) {
    $value=0;
    $pat=quotemeta($process);

    $flag=0;
    #while ($data =~ s/(.*)(Process.*?$pat.*?PrivStack)(.*$)/$1$3/s ) {
    while ($data =~ s/(.*)(Process[\d\s,]*?\($pat.*?PrivStack)(.*$)/$1$3/s ) {
      $flag=1;
      $data2 = $2;
      $num=99;
      $num=$1 if ($data2 =~ /Process.*?$pat(\d\d)/);
      $this_process=$process."$num";
      $value=0;
      if ($data2 =~ /Cpu-Busy-Time(.{20})/) {
          $tmpv=$1;
          $value=$1 if ($tmpv=~ /(\d+\.{0,1}\d*)/);
      } 
      $perf_data.="${this_process}_cpu_busy_time=$value ";
    } 

    if (!$flag) {
       print "Some thing went wrong, Could not find Heap32 for process $process\n";
       exit(-1);
    }
}

foreach $process (@processes_per_system) {
    $value=0;
    $pat=quotemeta($process);

    $flag=0;
    while ($data =~ s/(.*)(Process[\d,\s]*?\($pat.*?PrivStack)(.*$)/$1$3/s ) {
      $flag=1;
      $data2 = $2;
      $this_process=$process;
      $value=0;
      #if ($data2 =~ /Heap32(.{32})/) {
      if ($data2 =~ /Cpu-Busy-Time(.{20})/) {
          $tmpv=$1;
          $value=$1 if ($tmpv=~ /(\d+\.{0,1}\d*)/);
      } 
      $perf_data.="${this_process}_cpu_busy_time=$value ";
    } 

    if (!$flag) {
       print STDERR "Some thing went wrong, Could not find Heap32 for process $process\n";
    }
}

print "$perf_data\n";

