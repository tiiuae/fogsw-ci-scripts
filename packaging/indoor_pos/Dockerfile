# indoor_pos BUILDER
# There should not be need to publish this builder image anywhere
FROM ros:foxy as indoor_pos-builder

ARG BUILD_NUMBER

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
    nlohmann-json3-dev \
    ros-foxy-geodesy \
    liblapacke-dev \
    libopenblas-dev \
    libsurvive \
    && rm -rf /var/lib/apt/lists/*

# Install px4-msgs
RUN curl -fsSL https://github.com/tiiuae/fog_sw/releases/download/ver_ssrc_rel_2/ros-foxy-px4-msgs_2.0.1-0focal_amd64.deb -o ros-foxy-px4-msgs.deb \
    && dpkg -i ros-foxy-px4-msgs.deb \
    && rm ros-foxy-px4-msgs.deb

WORKDIR /

RUN mkdir -p /build
COPY indoor_pos   /build/indoor_pos
COPY package.sh /build
WORKDIR /build

RUN ./package.sh ${BUILD_NUMBER}

FROM scratch
COPY --from=indoor_pos-builder /build/*.deb /packages/
