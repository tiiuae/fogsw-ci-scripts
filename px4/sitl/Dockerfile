# PX4 FIRMWARE BUILDER
# There should not be need to publish this builder image anywhere
FROM ros:foxy as px4_firmware_builder

RUN echo "deb [trusted=yes] https://artifactory.ssrc.fi/artifactory/debian-public-local focal fog-sw" >> /etc/apt/sources.list

# Install build tools
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    wget \
    git-core \
    libboost-all-dev \
    libeigen3-dev \
    libgstreamer-plugins-base1.0-dev \
    libopencv-dev \
    openjdk-11-jdk-headless \
    python3 \
    python3-empy \
    python3-jinja2 \
    python3-pip \
    python3-setuptools \
    python3-toml \
    python3-yaml \
    python3-packaging \
    python3-numpy \
    python3-genmsg \
    gazebo11 \
    libgazebo11-dev \
    fast-dds-gen \
    && rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

WORKDIR /px4-firmware

# Copy repository contents
COPY . .

RUN [ -d ./build ] && rm -Rf ./build || :

# Build the PX4 firmware for SITL
RUN . /opt/ros/foxy/setup.sh \
    && DONT_RUN=1 make px4_sitl_rtps gazebo_ssrc_fog_x

RUN mkdir /px4_sitl_plugins \
    && find /px4-firmware/build/px4_sitl_rtps/build_gazebo/*.so -exec cp {} /px4_sitl_plugins \;

# Bare bones image containing only the build results
# This image can be used for retrieving relevant px4 firmware artifacts
FROM scratch

# Copy build artifacts
COPY --from=px4_firmware_builder /px4-firmware/build/px4_sitl_rtps/bin                    /px4_sitl/build/px4_sitl_rtps/bin
COPY --from=px4_firmware_builder /px4-firmware/build/px4_sitl_rtps/etc                    /px4_sitl/build/px4_sitl_rtps/etc

# Copy gazebo_data
COPY --from=px4_firmware_builder /px4_sitl_plugins                                        /px4_gazebo_data/plugins
COPY --from=px4_firmware_builder /px4-firmware/Tools/sitl_gazebo/models/asphalt_plane     /px4_gazebo_data/models/asphalt_plane
COPY --from=px4_firmware_builder /px4-firmware/Tools/sitl_gazebo/models/ground_plane      /px4_gazebo_data/models/ground_plane
COPY --from=px4_firmware_builder /px4-firmware/Tools/sitl_gazebo/models/sun               /px4_gazebo_data/models/sun
COPY --from=px4_firmware_builder /px4-firmware/Tools/sitl_gazebo/models/ssrc_fog_x        /px4_gazebo_data/models/ssrc_fog_x
COPY --from=px4_firmware_builder /px4-firmware/Tools/sitl_gazebo/worlds/empty.world       /px4_gazebo_data/worlds/
COPY --from=px4_firmware_builder /px4-firmware/Tools/sitl_gazebo/worlds/empty_ssrc.world  /px4_gazebo_data/worlds/
COPY --from=px4_firmware_builder /px4-firmware/Tools/sitl_gazebo/scripts/jinja_gen.py     /px4_gazebo_data/scripts/
