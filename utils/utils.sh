#!/bin/bash

#    This file is part of rpi2pachube (formerly rpi2cosm).
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

function bool2str () {
  if [ "${1:-0}" -eq 1 ]; then
    echo -n "yes"
  else
    echo -n "no"
  fi
}

function newds() {
  printf '{"id":"%s","current_value":"%s"}' "$1" "$2"
}

function read_yn () {
  while true; do
    if [ "$2" != "" ]; then
      echo -n "$1 (Default:" $(bool2str "$2") ")"
    else
      echo -n "$1 "
    fi
    read value
    if [ "$value" = "y" ] || [ "$value" = "Y" ];  then
      return 1
    elif [ "$value" = "n" ] || [ "$value" = "N" ]; then
      return 0
    elif [ "$2" != "" ] && [ "$value" = "" ]; then
      return "${2:-0}"
    fi
  done
}

function read_s () {
  while true; do
    if [ "$3" != "" ]; then
      echo -n "$1 (Default: $3)"
    else
      echo -n "$1 "
    fi
    read value
    if [ -n "$value" ]; then
      eval "$2=\"$value\""
      break
    elif [ "$3" != "" ]; then
      eval "$2=\"$3\""
      break
    fi
  done
  return 0
}

function get_interfaces() {
  echo $(ip link show | grep ^[0-9] | cut -d ' ' -f 2 | cut -d ':' -f 1 | tr "\n" ',' | sed "s/,$//")
}
