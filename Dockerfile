FROM ubuntu:20.04 as install_dependencies

RUN DEBIAN_FRONTEND=noninteractive apt update -y \
 && DEBIAN_FRONTEND=noninteractive apt --no-install-recommends -y full-upgrade \
 && DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
      software-properties-common \
 && DEBIAN_FRONTEND=noninteractive add-apt-repository universe \
 && DEBIAN_FRONTEND=noninteractive apt update -y \
 && DEBIAN_FRONTEND=noninteractive apt --no-install-recommends -y full-upgrade \
 && DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
      git \
      wget \
      sudo \
      nano \
# for checkinstall
      gettext \
# for building prusaslicer
      ca-certificates \
      cmake \ 
      g++ \
      gcc \
      pkg-config \
      build-essential \
      #libboost-all-dev \
      libboost-dev \
      libcairo2-dev \
      #libcereal-dev \
      #libcgal-dev \
      #libcurl4-openssl-dev \
      #libdbus-1-dev \
      libeigen3-dev \
      libexpat1-dev \ 
      #libgl1-mesa-dev \
      libglew-dev \
      libglib2.0-dev \
      libglib2.0-dev-bin \
      libglu1-mesa-dev \
      libglx-dev \ 
      libgtk2.0-dev \
      libgtk-3-dev \
      libicu-dev \
      libjpeg8-dev \
        libjpeg-dev \
      libjpeg-turbo8-dev \
      #libnlopt-cxx-dev \ 
      #libnlopt-dev \
      libopenvdb-dev \
      libpng-dev \
        libsdl1.2-dev \
        libssl-dev \
      libtbb-dev \
        libtiff5-dev \
        libtiff-dev \
        libudev-dev \
      libwxbase3.0-dev \
      # libwxgtk3.0-gtk3-dev \
      libx11-dev \
        libxml2-dev \
      m4 \
      wx-common \
      wx3.0-headers \
      wx3.0-i18n \
# for building sailfish      
      make gcc-avr binutils-avr gdb-avr avr-libc avrdude scons \
# for building gpx
      build-essential \
# for running ReplicatorG
      curl openjdk-8-jdk python2 python-tk

      
FROM install_dependencies as build_checkinstall
RUN git clone https://github.com/giuliomoro/checkinstall \
 && cd checkinstall \
 && make install \
 && cd .. \
 && rm -rf checkinstall \
 && mkdir /build \
 && mkdir /built
   
FROM build_checkinstall as build_prusaslicer
RUN cd /build \
 && git clone https://github.com/46cv8/PrusaSlicer.git \
 && cd /build/PrusaSlicer/deps \
 && git remote add upstream https://github.com/prusa3d/PrusaSlicer.git \
# && git checkout variable_fan_speed_2_2_0 \
 && git checkout variable_fan_speed_2_3_0_alpha1 \
 && mkdir build \
 && cd /build/PrusaSlicer/deps/build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release -DSLIC3R_BUILD_TESTS=OFF \
 && make
RUN cd /build/PrusaSlicer \
 && mkdir build \
 && cd /build/PrusaSlicer/build \
# && cmake .. -DSLIC3R_STATIC=1 -DCMAKE_PREFIX_PATH=/build/PrusaSlicer/deps/build/destdir/usr/local -DCMAKE_BUILD_TYPE=Release -DSLIC3R_BUILD_TESTS=OFF \
 && cmake .. -DSLIC3R_STATIC=1 -DCMAKE_PREFIX_PATH=/build/PrusaSlicer/deps/build/destdir/usr/local -DCMAKE_BUILD_TYPE=Release -DSLIC3R_BUILD_TESTS=OFF -DSLIC3R_ASAN=1 -DSLIC3R_FHS=1 \
 && make -j8
RUN cd /build/PrusaSlicer/build \
# asan fails to build install via checkinstall so we need the following environment variable set https://github.com/google/sanitizers/issues/796
 && ASAN_OPTIONS=verify_asan_link_order=0 checkinstall -D --install=yes --fstrans=no --pkgname=prusa-slicer --provides=prusa-slicer --pkgversion=2.3.0-alpha1-20201018a --nodoc -y \
 && cp /build/PrusaSlicer/build/prusa-slicer_2.3.0-alpha1-20201018a-1_amd64.deb /built/prusa-slicer_2.3.0-alpha1-20201018a-1_amd64.deb
# required if we want to actually run prusa-slicer in the docker container
RUN DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
      nvidia-driver-440 \
      locales 
RUN locale-gen en_US.UTF-8
RUN locale-gen en_GB.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

FROM build_prusaslicer as build_sailfish
RUN cd /build \
 && git clone https://github.com/46cv8/Sailfish-MightyBoardFirmware.git \
 && cd /build/Sailfish-MightyBoardFirmware/firmware \
 && git remote add upstream https://github.com/jetty840/Sailfish-MightyBoardFirmware.git \
 && git checkout variable_fan_speed \
 && scons platform=ff_creatorx-2560 \
 && cp /build/Sailfish-MightyBoardFirmware/firmware/build/ff_creatorx-2560/ff_creatorx-2560_v7.8.0.en.hex /built/ff_creatorx-2560_v7.8.0.en.hex
 
FROM build_sailfish as build_gpx
RUN cd /build \
 && git clone https://github.com/46cv8/GPX.git \
 && cd /build/GPX \
 && git remote add upstream https://github.com/markwal/GPX.git \
 && git checkout variable_fan_speed \
 && mkdir build \
 && cd /build/GPX/build \
 && ../configure \
 && make \
 && checkinstall -D --install=yes --fstrans=no --pkgname=gpx --provides=gpx --pkgversion=2.5.2-20201018a --nodoc -y \
 && cp /build/GPX/build/gpx_2.5.2-20201018a-1_amd64.deb /built/gpx_2.5.2-20201018a-1_amd64.deb

FROM build_gpx as build_gpx_ui
RUN DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
      qttools5-dev-tools \
      qtbase5-dev \
 && cd /build \
 && git clone https://github.com/46cv8/GpxUi \
 && cd /build/GpxUi \
 && git remote add upstream https://github.com/markwal/GpxUi.git \
 && git checkout variable_fan_speed \
 && git submodule update --init --recursive \
 && cd /build/GpxUi/GPX \
 && git checkout variable_fan_speed \
 && cd /build/GpxUi \
 && make release \
# checkinstall can't build qmake modules to debian so I can't make a package and just do make install (see: https://askubuntu.com/questions/1014619/a-working-version-of-checkinstall)
# && checkinstall -D --install=yes --fstrans=no --pkgname=gpx-ui --provides=gpx-ui --pkgversion=2.5.2-20201018a --nodoc -y \
# && cp /build/GpxUi/gpx-ui_2.5.2-20201018a-1_amd64.deb /built/gpx-ui_2.5.2-20201018a-1_amd64.deb
 && make install

FROM build_gpx_ui as install_replicatorg
RUN cd /opt \
 && wget --no-verbose https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/replicatorg/replicatorg-0040-linux.tgz \
 && tar --extract --ungzip --file replicatorg-0040-linux.tgz \
 && chmod 777 /opt/replicatorg-0040

# sudo docker build -t yourusername/docker-ffcp:20.04-2.3.0a1-20201018a .
