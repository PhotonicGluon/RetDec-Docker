#############
#  BUILDER  #
#############

FROM debian:trixie-slim AS builder

RUN echo "===> Updating packages..." \
    && apt-get update -y

RUN echo "===> Installing dependencies..." \
    && apt-get install -y build-essential \
    cmake \
    git \
    openssl \
    libssl-dev \
    python3 \
    autoconf \
    automake \
    libtool \
    pkg-config \
    m4 \
    zlib1g-dev \
    upx \
    doxygen \
    graphviz

# TODO: Allow cloning of specific version, this just takes master branch
RUN echo "===> Cloning RetDec..." \
    && cd /tmp \
    && git clone https://github.com/avast/retdec.git

RUN echo "===> Building RetDec..."\
    && cd /tmp/retdec \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/usr/share/retdec -DRETDEC_ENABLE_ALL=ON\
    && make -j$(nproc)

RUN echo "===> Installing RetDec..." \
    && cd /tmp/retdec/build \
    && make install

RUN echo "===> Builder tasks complete!"

############
#  RUNNER  #
############

FROM debian:trixie-slim as runner

LABEL maintainer "https://github.com/PhotonicGluon"

RUN echo "===> Updating packages..." \
    && apt-get update -y

RUN echo "===> Installing dependencies..."\
    && apt-get install -y openssl graphviz upx python3

RUN echo "===> Clean up files..." \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives /tmp/* /var/tmp/*

COPY --from=builder /usr/share/retdec /usr/share/retdec

RUN echo "===> Creating RetDec user..." \
    && groupadd --gid 1000 retdec \
    && useradd -lm --uid 1000 --gid 1000 --home-dir /usr/share/retdec retdec

RUN echo "===> Updating RetDec executable permissions..." \
    && chown retdec:retdec /usr/share/retdec \
    && du -sh /usr/share/retdec

RUN echo "===> Updating RetDec config file permissions..." \
    && chmod 777 /usr/share/retdec/share/retdec/decompiler-config.json \
    && chmod 777 /usr/share/retdec/share/retdec/fileinfo-config.json

ENV PATH /usr/share/retdec/bin:$PATH

# Set up entry point
USER retdec
WORKDIR /samples

RUN echo "===> Runner tasks complete!"
