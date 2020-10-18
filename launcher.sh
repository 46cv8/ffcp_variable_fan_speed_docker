#!/bin/bash

DEVICES=""
for device in /dev/ttyUSB*
do
  if [ -c $device ]; then
    DEVICES="${DEVICES} --share $device"
  fi
done
for device in /dev/ttyACM*
do
  if [ -c $device ]; then
    DEVICES="${DEVICES} --share $device"
  fi
done
for device in /dev/gpiochip*
do
  if [ -c $device ]; then
    DEVICES="${DEVICES} --share $device"
  fi
done

<<'###BLOCK-COMMENT'
x11docker --pw pkexec --no-entrypoint \
  --group-add tty --group-add dialout \
  --share $HOME/Documents ${DEVICES} \
  --clipboard --hostdisplay \
  -- \
  --volume ./shares:/home/yourusername/shares \
  -- \
  yourusername/docker-ffcp:20.04-2.3.0a1-20201018a \
  /usr/bin/codium-wait
###BLOCK-COMMENT

#<<'###BLOCK-COMMENT'
x11docker --interactive --sudouser --pw pkexec --no-entrypoint \
  --group-add tty --group-add dialout \
  --share $HOME/Documents ${DEVICES} \
  --clipboard --hostdisplay \
  -- \
  --volume ./shares:/home/yourusername/shares \
  -- \
  yourusername/docker-ffcp:20.04-2.3.0a1-20201018a \
  /usr/bin/bash
###BLOCK-COMMENT

exit


# To rebuild the modified sailfish
# sudo -i
# cd /build/Sailfish-MightyBoardFirmware/firmware
# scons platform=ff_creatorx-2560

# To program modified sailfish (from https://github.com/DrLex0/Sailfish-MightyBoardFirmware/releases)
# cd /build/Sailfish-MightyBoardFirmware/firmware/build/ff_creatorx-2560/
# avrdude -D -p m2560 -P /dev/ttyACM0 -c stk500v2 -b 57600 -U flash:w:ff_creatorx-2560_v7.8.0.en.hex:i

# To rebuild the modified gpx
# cd /build/GPX/build
# ../configure
# make
# sudo checkinstall -D --install=yes --fstrans=no --pkgname=gpx --provides=gpx --pkgversion=2.5.2-2020XXXXa --nodoc -y

# To run replicatorG (don't need it currently)
# cd /opt/replicatorg-0040
# ./replicatorg

# To run prusa-slicer
# /usr/local/bin/prusa-slicer

# Test part cooling fan gcode from commandline
# cd /home/yourusername/shares
# gpx -m fcp M126.gcode
# gpx -m fcp -s M126.gcode /dev/ttyACM0
# gpx -m fcp M126_with_speeds.gcode
# gpx -m fcp -s M126_with_speeds.gcode /dev/ttyACM0
# python3
# import binascii
# with open('M126_with_speeds.x3g', 'rb') as f:
#     for chunk in iter(lambda: f.read(10), b''):
#         print(binascii.hexlify(chunk))



