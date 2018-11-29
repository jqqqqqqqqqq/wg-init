#!/bin/bash

echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list

echo "Package: *
Pin: release a=unstable
Pin-Priority: 150" > /etc/apt/preferences.d/limit-unstable

apt update

apt -y install wireguard
