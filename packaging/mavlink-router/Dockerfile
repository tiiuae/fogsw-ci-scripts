# mavlink-router BUILDER
# There should not be need to publish this builder image anywhere
FROM ubuntu:20.04 as mavlink-router-builder

ARG BUILD_NUMBER
ARG DISTRIBUTION
ARG ARCHITECTURE

# Setup timezone
RUN echo 'Etc/UTC' > /etc/timezone \
    && ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime

ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install build dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    tzdata \
    build-essential \
    dh-make debhelper \
    cmake \
    git-core \
    fakeroot \
    pkg-config \
    python3-future \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /build
COPY mavlink-router   /build/mavlink-router
COPY main.conf   /build/main.conf
COPY debian /build/debian
COPY package.sh /build
WORKDIR /build

RUN ./package.sh ${BUILD_NUMBER} ${DISTRIBUTION} ${ARCHITECTURE}

FROM scratch
COPY --from=mavlink-router-builder /build/*.deb /packages/
