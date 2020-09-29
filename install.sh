#!/bin/bash
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

target_nagios_location=/opt/nagios/
nonstop_plugin_location=/opt/nonstop_extensions

if [ ! -e /opt/nagios/etc/nagios.cfg.orig ]
then
   cp -f /opt/nagios/etc/nagios.cfg /opt/nagios/etc/nagios.cfg.orig
fi

mkdir -p $nonstop_plugin_location/etc/nsservers

echo "cfg_file=${nonstop_plugin_location}/etc/nscommands" >> /opt/nagios/etc/nagios.cfg 
echo "cfg_dir=${nonstop_plugin_location}/etc/nsservers"   >>  /opt/nagios/etc/nagios.cfg 

cat apt_proxy_info.txt >> /etc/apt/apt.conf

apt-get update
apt-get install expect -y

#update *.cgi (being copied) with appropriate 'use lib' statement  
#Currently - this part is updated manually - needs to change only if the nagios is installed in different location

#Both of these below has some code like this -- needs to by dynamic  /usr/local/nagios/etc/nagiosgraph

cp $nonstop_plugin_location/sbin/addhosts.cgi /opt/nagios/sbin/
cp $nonstop_plugin_location/sbin/receivensdata.cgi /opt/nagios/sbin/ 
cp $nonstop_plugin_location/share/side.php /opt/nagios/share/

#Change ownerships
chown nagios:nagios $target_nagios_location/sbin/addhosts.cgi
chown nagios:nagios $target_nagios_location/sbin/receivensdata.cgi

chown nagios:nagios -R /opt/nagiosgraph/var/rrd/
chown nagios:nagios -R $nonstop_plugin_location

#Create softlink to ns folder 

rm -f /usr/local/ns
ln -f -s $nonstop_plugin_location  /usr/local/ns 

#Create softlink to ns/bin folder ..
ln -f -s $nonstop_plugin_location/bin  /usr/local/ns/bin

#use different file name in ns_meascom.cgi -- TBD later.  $SYSTEM.TMP.DATA01 and $SYSTEM.TMP.F1 

#copy RRD files from the sources
cp -a $nonstop_plugin_location/rrd /opt/nagiosgraph/var/

#SSH keys - still used by Nonstop (on old systems, so we need to support that), which are disabled in latest dockers
echo "Host *"  > /opt/nagios/.ssh/config
echo " HostKeyAlgorithms=+ssh-dss"  >> /opt/nagios/.ssh/config
chown nagios:nagios /opt/nagios/.ssh/config


