# px4-firmware builder for PixHawk4
FROM ros:foxy as px4-bl-builder

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

RUN echo "deb [trusted=yes] https://artifactory.ssrc.fi/artifactory/debian-public-local $(lsb_release -cs) fog-sw" > /etc/apt/sources.list.d/fogsw-latest.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential wget cmake \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN mkdir /tools

WORKDIR tmp

RUN wget -q https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2017q4/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2
RUN tar xvf gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2 -C /tools
ENV PATH=/tools/gcc-arm-none-eabi-7-2017-q4-major/bin/:$PATH

WORKDIR /build

COPY . .

ENV CRYPTO_HAL=monocypher
ENV PUBLIC_KEY0=/build/crypto_hal/test_key/key0.pub

RUN make px4fmuv5_bl


FROM scratch
COPY --from=px4-bl-builder /build/build/px4fmuv5_bl/px4fmuv5_bl.hex /artifacts/
COPY --from=px4-bl-builder /build/build/px4fmuv5_bl/px4fmuv5_bl.bin /artifacts/
