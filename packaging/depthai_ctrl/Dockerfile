# depthai_ctrl BUILDER
# There should not be need to publish this builder image anywhere
FROM ros:foxy as depthai_ctrl-builder

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
    libusb-1.0-0-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    libgstreamer-plugins-good1.0-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN mkdir -p /build
COPY depthai_ctrl   /build/depthai_ctrl
COPY package.sh /build
WORKDIR /build

RUN ./package.sh ${BUILD_NUMBER} ${DISTRIBUTION} ${ARCHITECTURE}

FROM scratch
COPY --from=depthai_ctrl-builder /build/*.deb /packages/
