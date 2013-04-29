rpi2pachube
===========

Bash script for pushing Raspberry Pi data to Pachube using cron

Visit the following link if you need help getting rpi2pachube working:

http://cameriworkbench.blogspot.com/2013/01/pushing-raspberry-pi-data-to-cosm-using.html

Requirements
============
1. Debian-flavor "ifstat command". Run "ifstat -v"; You should have version 1.1.
2. realpath command for setup.sh. Run "realpath --version" to see if you have it installed. Use apt-get or pacman to install it depending on which linux distro you are using.

What does it do?
=================
rpi2pachube gathers performance data from your Raspberry Pi (temperature, load, network throughput, etc.) at 5 minute intervals and pushes this data to Pachube. From Pachube, you can watch how your Pi is doing from basically anywhere in the world.

Installation
============
1. Create an account on Pachube, create a new Device feed and a new API key for that device with Write privileges.
2. Clone the github repository: $ git clone https://github.com/Cameri/rpi2pachube.git
3. Run the configuration utility: $ ./setup.sh

That's it.

Bug reports, comments, ideas?
=============================
If you have found a bug or you have an idea to enhance rpi2pachube, please open a new issue.
