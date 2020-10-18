# FlashForge Creator Pro Variable Fan Speed for Part Cooling Fan Docker Build Scripts

Please read this README completely before attempting to use these custom builds.

Dockerbuild and x11docker launch script for building PrusaSlicer, Sailfish-MightyBoardFirmware and GPX with variable fan speed support via enhanced M126 commands.
The docker image is based of Ubuntu 20.04.

before building the Dockerbuild or running launcher.sh be sure to update "yourusername" to your user name in both scripts.

Once the build is completed the directory "/built" in the image will contain the files below.
 - /built/ff_creatorx-2560_v7.8.0.en.hex: A firmware for the ffcp that supports custom fanspeed via gcode for the part cooling fan. (https://github.com/jetty840/Sailfish-MightyBoardFirmware/compare/master...46cv8:variable_fan_speed) 
 - /built/prusa-slicer_2.3.0-alpha1-20201018a-1_amd64.deb: PrusaSlicer with a modification to use "M126 S###" to set fanspeed for the FFCP part cooling fan. (https://github.com/prusa3d/PrusaSlicer/compare/version_2.3.0-alpha1...46cv8:variable_fan_speed_2_3_0_alpha1)
You can remove the section from Dockerbuild that installs the nvidia driver if you have no intention of running prusaslicer from within the container.
 - /built/gpx_2.5.2-20201018a-1_amd64.deb: gpx with support to pass through fanspeed instead of setting it to just 0 or 1. (https://github.com/markwal/GPX/compare/master...46cv8:variable_fan_speed)

If you launch the image with ./launcher.sh it will launch the new image using x11docker and you can then copy the built debians files to the "/home/<USER>/shares" folder which is mapped to the folder in shares on your host machine. ("cp -r /built /home/<USER>/shares")
  
You can program the Sailfish firmware to FFCP using avrdude as follows "avrdude -D -p m2560 -P /dev/ttyACM0 -c stk500v2 -b 57600 -U flash:w:ff_creatorx-2560_v7.8.0.en.hex:i".
You will likely want to backup your EEPROM from the FFCP menu first as you are going to probably need ot whipe your EEPROM using ReplicatorG to get things working. ReplicatorG is included in the image and can be executed from within a container as "/opt/replicatorg-0040/replicatorg".

If you install the deb files on your host computer you will find the files are installed to /usr/local/bin. This differs from the default install path of /usr/bin for gpx and prusa-slicer, you may need to update scripts accordingly.

In the "tests" folder "M126_with_speeds.gcode" contains a script that tests fan speeds of 10%,20%,30%,40%,....,100% for 6 seconds each with a 1 second pause in between. You can test building this "gpx" to confirm that the output matches "M126_with_speeds.x3g".
You can then run "M126_with_speeds.x3g" on your FFCP to confirm that the variable fan speeds are indeed working.

Pre-built deb files are included, PrusaSlicer 2.3.0-alpha1 was used for this build. You can build with PrusaSlicer 2.2.0 if you want by updating the Dockerbuild script accordingly.

WARNING: After updating your firmware any x3g scripts you have will need to be rebuilt if you want to make use of the cooling fan in any meaningful way. Otherwise the 1 value signifying use the cooling fan, will simply be interpreted as 1% which will not start the fan at all. (If there is demand for a version that interprets 1% as full speed still, I can add that addition to Sailfish to full backwards and forwards compatability, it will just mean that 1% fan speed will be mapped to 100%)
