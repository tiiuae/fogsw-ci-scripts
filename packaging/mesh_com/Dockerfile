# mesh_com BUILDER
# There should not be need to publish this builder image anywhere
FROM ros:foxy as mesh_com-builder

ARG BUILD_NUMBER

# Install build dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    dh-make debhelper \
    fakeroot \
    dh-python \
    python3-bloom \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /build
COPY mesh_com   /build/mesh_com
COPY package.sh /build
WORKDIR /build

RUN ./package.sh ${BUILD_NUMBER}

FROM scratch
COPY --from=mesh_com-builder /build/*.deb /packages/
