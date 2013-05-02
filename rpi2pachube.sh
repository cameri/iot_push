#!/bin/bash

#    rpi2pachube - Script for pushing Raspberry Pi data to Pachube
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

cd $(dirname $(realpath $0))
. utils/utils.sh

# Load configuration
if [[ -f "$HOME/.rpi2pachube.conf" ]]; then
. $HOME/.rpi2pachube.conf
else
  echo "rpi2pachube: Error: Unable to load configuration. (File not found)" 1>&2
  exit 1
fi

# Initialize datastreams array
declare -a dss

# Read cpu avg (cpu_one and cpu_fifteen unused, feel free to add)
if [[ $monitor_load_avg -eq 1 ]]; then
  read load_one load_five load_fifteen < /proc/loadavg
  dss=(${dss[@]} $(newds "load_avg" "$load_five"))
fi

# Read free and total memory
mem_free=$(cat /proc/meminfo | grep MemFree | awk '{r=$2/1024; printf "%0.2f", r}')
mem_total=$(cat /proc/meminfo | grep MemTotal | awk '{r=$2/1024; printf "%0.2f", r}')

if [[ ${monitor_mem_free -eq 1 ]]; then
  dss=(${dss[@]} $(newds "mem_free" "$mem_free"))
fi
if [ "${monitor_mem_used:-0}" -eq 1 ]; then
  mem_used=$(expr ${mem_total/.*} - ${mem_free/.*})
  dss=(${dss[@]} $(newds "mem_used" "$mem_used"))
fi

# Read cached memory
if [ "${monitor_mem_cached:-0}" -eq 1 ]; then
  mem_cached=$(cat /proc/meminfo | grep ^Cached | awk '{r=$2/1024; printf "%0.2f", r}')
  dss=(${dss[@]} $(newds "mem_cached" "$mem_cached"))
fi

# Read temperature (some systems do not define LD_LIBRARY_PATH)
if [ "${monitor_temp:-0}" -eq 1 ]; then
  temp=$(env LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/vc/lib \
    /opt/vc/bin/vcgencmd measure_temp | sed "s/temp=\([0-9]\+\.[0-9]\+\)'C/\1/")
  if [ "${monitor_temp_f:-0}" -eq 1 ]; then
    temp=$(echo $temp | awk '{r=$1*9/5+32; printf "%0.2f", r}')
  fi
  dss=(${dss[@]} $(newds "temp" "$temp"))
fi

# Read process count (remove ps, wc and cron from the count)
if [ "${monitor_pid_count:-0}" -eq 1 ]; then
  pid_count=$(expr $(ps -e | wc -l) - 3)
  dss=(${dss[@]} $(newds "processes" "$pid_count"))
fi

# Read user count
if [ "${monitor_users:-0}" -eq 1 ]; then
  users=$(users | wc -w)
  dss=(${dss[@]} $(newds "users" "$users"))
fi

# Read connection count
if [ "${monitor_connections:-0}" -eq 1 ]; then
  connections=$(netstat -tun | grep ESTABLISHED | wc -l)
  dss=(${dss[@]} $(newds "connections" "$connections"))
fi

# Read uptime
if [ "${monitor_uptime:-0}" -eq 1 ]; then
  uptime=$(cut -d. -f1 /proc/uptime | awk '{h=$1/86400; printf "%0.2f", h}')
  dss=(${dss[@]} $(newds "uptime" "$uptime"))
fi

# Read throughput in KB/s
if [ "${monitor_network_interfaces:-0}" -eq 1 ]; then
  # Convert network_interfaces (comma-separated) to an array called ifaces
  SAVE_IFS=$IFS
  IFS=,
  read -ra ifaces <<< "$network_interfaces"
  IFS=$SAVE_IFS
  for iface in "${ifaces[@]}"; do
    read down up <<< $(ifstat -i $iface 1 1 2>/dev/null | tail -n 1)
    upds=$(newds "${iface}_up" "$up")
    downds=$(newds "${iface}_down" "$down")
    dss=("${dss[@]}" "$upds,$downds")
  done

fi

# Serialize to JSON format
data=$(IFS=, ;echo "{\"version\":\"1.0.0\",\"datastreams\":[${dss[*]}]}")

curl --request PUT \
  --data "$data" \
  --header "Content-type: application/json" \
  --header "X-ApiKey: ${api_key}" \
  -s \
  http://api.cosm.com/v2/feeds/${feed} 1>/dev/null

exit 0
