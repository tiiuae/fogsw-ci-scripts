# px4_msgs BUILDER
# There should not be need to publish this builder image anywhere
FROM ros:foxy as px4_msgs-builder

ARG BUILD_NUMBER
ARG DISTRIBUTION
ARG ARCHITECTURE

# Install build dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    dh-make debhelper \
    fakeroot \
    python3-bloom \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /build
COPY px4_msgs   /build/px4_msgs
COPY package.sh /build
WORKDIR /build

RUN ./package.sh ${BUILD_NUMBER} ${DISTRIBUTION} ${ARCHITECTURE}

FROM scratch
COPY --from=px4_msgs-builder /build/*.deb /packages/
