# px4_ros_com BUILDER
# There should not be need to publish this builder image anywhere
FROM ros:foxy as px4_ros_com-builder

ARG BUILD_NUMBER
ARG DISTRIBUTION
ARG ARCHITECTURE

RUN echo "deb [trusted=yes] https://artifactory.ssrc.fi/artifactory/debian-public-local focal fog-sw" >> /etc/apt/sources.list

# Install build dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    dh-make debhelper \
    cmake \
    git-core \
    fakeroot \
    python3-bloom \
    python3-genmsg \
    openjdk-11-jdk-headless \
    fast-rtps-lib \
    fast-rtps-gen \
    && rm -rf /var/lib/apt/lists/*

# Install px4-msgs
RUN curl -fsSL https://github.com/tiiuae/fog_sw/releases/download/ver_ssrc_rel_2/ros-foxy-px4-msgs_2.0.1-0focal_amd64.deb -o ros-foxy-px4-msgs.deb \
    && dpkg -i ros-foxy-px4-msgs.deb \
    && rm ros-foxy-px4-msgs.deb

WORKDIR /

RUN mkdir -p /build
COPY px4_ros_com   /build/px4_ros_com
COPY package.sh /build
WORKDIR /build

RUN ./package.sh ${BUILD_NUMBER} ${DISTRIBUTION} ${ARCHITECTURE}

FROM scratch
COPY --from=px4_ros_com-builder /build/*.deb /packages/
