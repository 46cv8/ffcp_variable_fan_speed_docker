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
 && git checkout variable_fan_speed \
 && git submodule update --init --recursive \
 && cd /build/OctoPrint-GPX/GPX \
 && git checkout variable_fan_speed \
 && ./configure \
 && cd /build/OctoPrint-GPX \
 && python setup.py bdist_wheel
 
