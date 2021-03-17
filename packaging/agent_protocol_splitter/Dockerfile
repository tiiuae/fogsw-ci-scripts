# agent_protocol_splitter BUILDER
# There should not be need to publish this builder image anywhere
FROM ubuntu:20.04 as agent_protocol_splitter-builder

ARG BUILD_NUMBER

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
    cmake \
    git-core \
    fakeroot \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /build
COPY agent_protocol_splitter   /build/agent_protocol_splitter
COPY debian /build/debian
COPY package.sh /build
WORKDIR /build

RUN ./package.sh ${BUILD_NUMBER}

FROM scratch
COPY --from=agent_protocol_splitter-builder /build/*.deb /packages/
