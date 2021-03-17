# px4_mavlink_ctrl BUILDER
# There should not be need to publish this builder image anywhere
FROM ros:foxy as px4_mavlink_ctrl-builder

ARG BUILD_NUMBER

# Install build dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    dh-make debhelper \
    cmake \
    git-core \
    fakeroot \
    python3-bloom \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/mavlink/MAVSDK/releases/download/v0.34.0/mavsdk_0.34.0_ubuntu20.04_amd64.deb -o mavsdk_0.34.0_ubuntu20.04_amd64.deb \
    && dpkg -i mavsdk_0.34.0_ubuntu20.04_amd64.deb \
    && rm mavsdk_0.34.0_ubuntu20.04_amd64.deb

RUN mkdir -p /build
COPY px4_mavlink_ctrl   /build/px4_mavlink_ctrl
COPY package.sh /build
WORKDIR /build

RUN ./package.sh ${BUILD_NUMBER}

FROM scratch
COPY --from=px4_mavlink_ctrl-builder /build/*.deb /packages/
