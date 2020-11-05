#!/bin/bash

# This script should be run on a raspberrypi to build the OctoPrint-GPX plugin with support for variable fan speed.

DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
      python3-pip \
      python3-dev \
 && pip3 install virtualenv \
 && cd /build \
 && git clone https://github.com/OctoPrint/OctoPrint \
 && cd OctoPrint \
 && virtualenv venv \
 && source venv/bin/activate \
 && pip install -e .[develop,plugins] \
 && pip install "cookiecutter>=1.4,<1.7" \
 && cd /build \
 && git clone https://github.com/46cv8/OctoPrint-GPX.git \
 && cd /build/OctoPrint-GPX \
 && git remote add upstream https://github.com/markwal/OctoPrint-GPX.git \
 && git checkout variable_fan_speed_and_fast_alt_serial \
 && git submodule update --init --recursive \
 && cd /build/OctoPrint-GPX/GPX \
 && git checkout variable_fan_speed_and_fast_alt_serial \
 && ./configure \
 && cd /build/OctoPrint-GPX \
 && python setup.py bdist_wheel

 # then build a .tar.gz "cd ../ && cp -r OctoPrint-GPX OctoPrint-GPX-variable_fan_speed-2.6.6 && rm -rf OctoPrint-GPX-variable_fan_speed-2.6.6/.git && tar -czvf OctoPrint-GPX-variable_fan_speed-2.6.6.tar.gz OctoPrint-GPX-variable_fan_speed-2.6.6 && cp OctoPrint-GPX-variable_fan_speed-2.6.6.tar.gz OctoPrint-GPX/OctoPrint-GPX-variable_fan_speed-2.6.6.tar.gz"
 # then commit the .tar.gz to github.
 # then from octoprint you can just reference that .tar.gz with the submodule already included. 
 # eg) https://github.com/46cv8/OctoPrint-GPX/raw/variable_fan_speed/OctoPrint-GPX-variable_fan_speed-2.6.6.tgz

 # then build a .tar.gz "cd ../ && cp -r OctoPrint-GPX OctoPrint-GPX-variable_fan_speed_and_fast_alt_serial-2.6.6 && rm -rf OctoPrint-GPX-variable_fan_speed_and_fast_alt_serial-2.6.6/.git && tar -czvf OctoPrint-GPX-variable_fan_speed_and_fast_alt_serial-2.6.6.tar.gz OctoPrint-GPX-variable_fan_speed_and_fast_alt_serial-2.6.6 && cp OctoPrint-GPX-variable_fan_speed_and_fast_alt_serial-2.6.6.tar.gz OctoPrint-GPX/OctoPrint-GPX-variable_fan_speed_and_fast_alt_serial-2.6.6.tar.gz"
 # then commit the .tar.gz to github.
 # then from octoprint you can just reference that .tar.gz with the submodule already included.
 # eg) https://github.com/46cv8/OctoPrint-GPX/raw/variable_fan_speed_and_fast_alt_serial/OctoPrint-GPX-variable_fan_speed_and_fast_alt_serial-2.6.6.tgz
