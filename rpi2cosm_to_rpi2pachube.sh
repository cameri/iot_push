#!/bin/bash

#    This file is part of rpi2pachube.
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

which realpath &> /dev/null
if [ $? -eq 0 ]; then
  realpath=`realpath $0 2>/dev/null`
else
  echo "Command 'realpath' is missing.
Install 'realpath' before running this utility." 1>&2
  exit 1
fi

# Rename configuration files
echo -n "Renaming configuration file... "
if [ -f "$HOME/.rpi2cosm.conf" ]; then
  mv "$HOME/.rpi2cosm.conf" "$HOME/.rpi2pachube.conf"
  if [ $? -eq 0 ]; then
    echo "[DONE]"
  else
    echo "[FAILED]"
    echo "Unable to rename $HOME/.rpi2cosm.conf to $HOME/.rpi2pachube.conf" 1>&2
    exit 1
  fi
else
  echo "[SKIP]"
fi

# Back up crontab before doing anything
echo -n "Backing up crontab to $HOME/crontab.backup... "
crontab -l 2>/dev/null 1>$HOME/crontab.backup
echo "[DONE]"

echo -n "Removing rpi2cosm from crontab... "
crontab -l 2>/dev/null | grep rpi2cosm &> /dev/null
if [ $? -eq 0 ]; then
  crontab -l 2>/dev/null | grep -v rpi2cosm > /tmp/crontab
  crontab /tmp/crontab
  echo "[DONE]"
else
  echo "[SKIP]"
fi

echo -n "Adding rpi2pachube.sh to crontab... "
crontab -l 2>/dev/null | grep rpi2pachube.sh &> /dev/null
if [ $? -eq 0 ]; then
  echo "[SKIP]"
else
  dirname=`dirname $realpath`
  crontab -l 1>/tmp/crontab 2>/dev/null
  echo "*/5 * * * * ${dirname}/rpi2pachube.sh" >> /tmp/crontab
  crontab /tmp/crontab
  echo "[DONE]"
fi

exit 0

