#!/bin/bash

which realpath &> /dev/null
if [ $? -eq 0 ]; then
  realpath=`realpath $0 2>/dev/null`
else
  echo "Command 'realpath' is missing." 1>&2
  echo "Install 'realpath' before running this utility." 1>&2
  exit 1
fi

# Rename configuration files
echo "Renaming configuration files..."
if [ -f "$HOME/.rpi2cosm.conf" ]; then
  mv $HOME/.rpi2cosm.conf $HOME/.rpi2pachube.conf
  cp $HOME/.rpi2pachube.conf $HOME/.rpi2pachube.conf.old
fi
# Remove rpi2cosm from crontab
echo "Backing up crontab first to $HOME/crontab.backup..."
crontab -l 2>/dev/null 1>$HOME/crontab.backup
echo "Removing rpi2cosm from crontab..."
crontab -l 2>/dev/null | grep rpi2cosm &> /dev/null
if [ $? -eq 0 ]; then
  crontab -l 2>/dev/null | grep -v rpi2cosm > /tmp/crontab
  crontab /tmp/crontab
  echo "rpi2cosm removed successfully."
else
  echo "rpi2cosm not found. Exiting." 1>&2
  exit 1
fi

echo "Adding rpi2pachube.sh to crontab..."
crontab -l 2>/dev/null | grep rpi2pachube.sh &> /dev/null
if [ $? -eq 0 ]; then
  echo "rpi2pachube.sh already exists in your crontab." 2>&1
  echo "Run 'crontab -e' if you want to manually edit your crontab."
  exit 1
else
  dirname=`dirname $realpath`
  crontab -l 1>/tmp/crontab 2>/dev/null
  echo "*/5 * * * * ${dirname}/rpi2pachube.sh" >> /tmp/crontab
  crontab /tmp/crontab
  echo "rpi2pachube.sh was successfully added to your crontab."
fi

exit 0

