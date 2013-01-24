#!/bin/bash

which realpath
if [ $? -eq 0 ];
  realpath=`realpath $0 2>/dev/null`
else
  echo "Command 'realpath' is missing." 1>&2
  echo "Install 'realpath' before running this utility." 1>&2
  exit 1
fi

# Rename configuration files
echo "Renaming configuration files..."
if [ -f "~/.rpi2cosm.conf" ]; then
  mv ~/.rpi2cosm.conf ~/.rpi2pachube.conf
fi
if [ -f "/etc/rpi2cosm.conf" ]; then
  mv /etc/rpi2cosm.conf /etc/rpi2pachube.conf
fi
echo "Backing up rpi2cosm.sh..."
if [ -f "rpi2cosm.sh" ]; then
  mv rpi2cosm.sh rpi2cosm.sh.backup
  if [ $? -ne 0 ]; then
    echo "Unable to rename rpi2cosm.sh to rpi2cosm.sh.backup." 1>&2
  fi
fi

# Remove rpi2cosm from crontab
echo "Removing rpi2cosm from crontab..."
crontab -l 2>/dev/null | grep -v rpi2cosm > /tmp/cron_without_rpi2cosm
if [ $? -eq 0 ]; then
  crontab /tmp/cron_without_rpi2cosm
  echo "rpi2cosm removed successfully."
else
  echo "rpi2cosm not found. Exiting." 1>&2
  exit 1
fi

echo "Adding rpi2pachube.sh to crontab..."
dirname=`dirname $realpath`
crontab -l 2>/dev/null | grep rpi2pachube.sh &> /dev/null
if [ $? -eq 0 ]; then
  echo "rpi2pachube.sh already exists in your crontab." 2>&1
  echo "Run 'crontab -e' if you want to manually edit your crontab."
  exit 1
else
  crontab -l 1>/tmp/crontab 2>/dev/null
  echo "*/5 * * * * ${dirname}/rpi2pachube.sh" >> /tmp/crontab
  crontab /tmp/crontab
  echo "rpi2pachube.sh was successfully added to your crontab."
fi

exit 0

