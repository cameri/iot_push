#!/bin/bash

#    rpi2cosm - Script for pushing to Cosm from Raspberry Pi
#    Copyright (c) 2012, Ricardo Cabral <ricardo.arturo.cabral@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Load configuration
if [[ -f "~/.rpi2cosm.conf" ]]; then
. ~/.rpi2cosm.conf
elif [[ -f "/etc/rpi2cosm.conf" ]]; then
. /etc/rpi2cosm.conf
else
  echo "rpi2cosm: Error: Unable to load configuration. (File not found)" 1>&2
  exit 1
fi

# Read memory
mem_free=`cat /proc/meminfo | grep MemFree | awk '{r=$2/1024; printf "%0.2f", r}'`
mem_total=`cat /proc/meminfo | grep MemTotal | awk '{r=$2/1024; printf "%0.2f", r}'`
mem_used=`echo $mem_total $mem_free | awk '{print $1-$2}'`
mem_cached=`cat /proc/meminfo | grep ^Cached | awk '{r=$2/1024; printf "%0.2f", r}'`

# Read cpu avg
read tmp cpu tmp < /proc/loadavg

# Read temperature
temp=$(env LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/vc/lib \
	/opt/vc/bin/vcgencmd measure_temp | sed "s/temp=\([0-9]\+\.[0-9]\+\)'C/\1/")

# Read process count (remove ps and wc from the count)
pid_count=`expr $(ps -e | wc -l) - 2`

# Read throughput in KB/s
ifstat -i $iface 1 1 | tail -n 1 > /tmp/ifstat
read iface_down iface_up < /tmp/ifstat

# Read user count
users=`users | wc -w`

# Read connection count
connections=`netstat -tun | grep ESTABLISHED | wc -l`

# Serialize to JSON format
data='{"version":"1.0.0",
	"datastreams":[
		{"id":"cpu", "current_value":"'$cpu'"},
		{"id":"mem_free", "current_value":"'$mem_free'"},
		{"id":"mem_used", "current_value":"'$mem_used'"},
		{"id":"mem_cached", "current_value":"'$mem_cached'"},
		{"id":"temp", "current_value":"'$temp'"},
		{"id":"processes", "current_value":"'$pid_count'"},
		{"id":"users", "current_value":"'$users'"},
		{"id":"connections", "current_value":"'$connections'"},
		{"id":"iface_up", "current_value":"'$iface_up'"},
		{"id":"iface_down", "current_value":"'$iface_down'"}
	]}'

curl	--request PUT \
	--data "$data" \
	--header "Content-type: application/json" \
	--header "X-ApiKey: ${api_key}" \
	http://api.cosm.com/v2/feeds/${feed}

exit 0
