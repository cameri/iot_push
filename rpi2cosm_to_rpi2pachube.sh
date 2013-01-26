#!/bin/bash

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

