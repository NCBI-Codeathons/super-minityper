ARG FROM_IMAGE=nvidia/cuda
ARG CUDA_VERSION=10.1
ARG LINUX_DISTRO=ubuntu
ARG LINUX_DISTRO_VERSION=18.04
ARG LINUX_VERSION=${LINUX_DISTRO}${LINUX_DISTRO_VERSION}

###############################################################################
# Clara Genomics Analysis
###############################################################################
FROM ${FROM_IMAGE}:${CUDA_VERSION}-devel-${LINUX_VERSION} AS cga

ARG CC_VERSION=7
ARG CXX_VERSION=7
ARG CMAKE_VERSION=3.14.7
ARG HTSLIB_VERSION=1.9
ARG CGA_VERSION=0.3.0
ARG RACON_GPU_VERSION=integrate-cga-v0.3.0

ENV CC_VERSION=${CC_VERSION}
ENV CXX_VERSION=${CC_VERSION}
ENV CMAKE_VERSION=${CMAKE_VERSION}
ENV HTSLIB_VERSION=${HTSLIB_VERSION}
ENV CGA_VERSION=${CGA_VERSION}
ENV RACON_GPU_VERSION=${RACON_GPU_VERSION}

# Ensure apt-get won't prompt for selecting options
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Environment variables for compilers
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
ENV CUDA_HOME=/usr/local/cuda
ENV CC=/usr/bin/gcc-${CC_VERSION}
ENV CXX=/usr/bin/g++-${CXX_VERSION}
ENV CUDAHOSTCXX=/usr/bin/g++-${CXX_VERSION}

# Install dependencies for htslib and Clara Genomics SDK
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        gcc-${CC_VERSION} \
        g++-${CXX_VERSION} \
        python3 \
        python3-pip \
        autoconf \
        automake \
        make \
        perl \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        libcurl4-gnutls-dev \
        libssl-dev \
        wget \
        rsync \
        python3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/bin/python /usr/bin/pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip

WORKDIR /opt/nvidia/clara-genomics/build

# Install htslib
RUN wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 \
    && mkdir htslib \
	&& tar xvf htslib-${HTSLIB_VERSION}.tar.bz2 -C htslib --strip-components=1 \
    && cd htslib \
    && ./configure \
    && make -j16 prefix=install install \
    && rsync -avz install/* /usr/local/

# Install cmake
RUN wget -O- "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz" \
    | tar --strip-components=1 -xz -C /usr/local

RUN git clone --recursive -b ${CGA_VERSION} --single-branch https://github.com/clara-genomics/ClaraGenomicsAnalysis.git \
    && cd ClaraGenomicsAnalysis/pyclaragenomics \
    && pip install --no-cache-dir --upgrade wheel setuptools \
    && pip install --no-cache-dir -r requirements.txt \
    && python setup.py sdist bdist_wheel

RUN git clone --recursive -b ${RACON_GPU_VERSION} --single-branch https://github.com/clara-genomics/racon-gpu.git \
    && cd racon-gpu \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -Dracon_build_tests=ON -Dracon_build_wrapper=ON -Dracon_enable_cuda=ON .. \
    && make


###############################################################################
# Minimap2
###############################################################################
FROM ${LINUX_DISTRO}:${LINUX_DISTRO_VERSION} AS minimap2

ARG MINIMAP2_VERSION=v2.17
ENV MINIMAP2_VERSION=${MINIMAP2_VERSION}

# Ensure apt-get won't prompt for selecting options
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install dependencies for htslib and Clara Genomics SDK
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        build-essential \
        make \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/lh3/minimap2/build

RUN git clone --recursive -b ${MINIMAP2_VERSION} --single-branch https://github.com/lh3/minimap2.git \
    && cd minimap2 \
    && make


###############################################################################
# Minigraph
###############################################################################
FROM ${LINUX_DISTRO}:${LINUX_DISTRO_VERSION} AS minigraph

ARG MINIGRAPH_VERSION=v0.5
ENV MINIGRAPH_VERSION=${MINIGRAPH_VERSION}

# Ensure apt-get won't prompt for selecting options
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install dependencies for htslib and Clara Genomics SDK
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        build-essential \
        make \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/lh3/minigraph/build

RUN git clone --recursive -b ${MINIGRAPH_VERSION} --single-branch https://github.com/lh3/minigraph.git \
    && cd minigraph \
    && make


###############################################################################
# Seqwish
###############################################################################
# reused author's Dockerfile from https://github.com/ekg/seqwish/blob/master/Dockerfile

# load base image
FROM ${LINUX_DISTRO}:${LINUX_DISTRO_VERSION} AS seqwish

# master commit ID is 3e94aa8 on 10/12/2019
ARG SEQWISH_VERSION=3e94aa8
ENV SEQWISH_VERSION=${SEQWISH_VERSION}

# update system
RUN apt-get update > /dev/null

# install dependencies
RUN apt-get -qqy install zlib1g zlib1g-dev libomp-dev

# install build tools
RUN apt-get -qqy install build-essential software-properties-common && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update > /dev/null && \
    apt-get -qqy install gcc-snapshot && \
    apt-get update > /dev/null && \
    apt-get -qqy install gcc-8 g++-8 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 --slave /usr/bin/g++ g++ /usr/bin/g++-8 && \
    apt-get -qqy install cmake git

# set working directory
WORKDIR /opt/ekg/seqwish/build

# clone repository and build
RUN git clone --recursive -b master --single-branch https://github.com/ekg/seqwish.git \
	&& cd seqwish \
	&& git reset --hard ${SEQWISH_VERSION} \
	&& cmake -H. -Bbuild && cmake --build build -- -j3

# cleanup
RUN apt-get -qy autoremove

# add seqwish to the PATH
ENV PATH /opt/ekg/seqwish/build/bin:$PATH


###############################################################################
# Svaha2 : https://github.com/edawson/svaha2
###############################################################################
FROM ${LINUX_DISTRO}:${LINUX_DISTRO_VERSION} AS svaha2

# master commit ID is fea13b9 on 10/12/2019
ARG SVAHA2_VERSION=fea13b9
ENV SVAHA2_VERSION=${SVAHA2_VERSION}

# Ensure apt-get won't prompt for selecting options
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install dependencies for htslib and Clara Genomics SDK
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        build-essential \
        make \
        autoconf \
        automake \
        make \
        perl \
		tabix \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        libcurl4-gnutls-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/edawson/svaha2/build

RUN git clone --recursive -b master --single-branch https://github.com/edawson/svaha2.git \
    && cd svaha2 \
	&& git reset --hard ${SVAHA2_VERSION} \
    && make


###############################################################################
# dxWDL builder
###############################################################################
FROM openjdk:8u222 AS dx-wdl-builder

ARG DXWDL_VERSION=1.00
ENV DXWDL_VERSION=${DXWDL_VERSION}

WORKDIR /workspace

RUN wget https://dnanexus-sdk.s3.amazonaws.com/dx-toolkit-v0.288.0-ubuntu-16.04-amd64.tar.gz \
	&& tar -xzf dx-toolkit*.tar.gz \
	&& wget https://github.com/dnanexus/dxWDL/releases/download/$DXWDL_VERSION/dxWDL-$DXWDL_VERSION.jar \
    && chmod +x dxWDL-$DXWDL_VERSION.jar \
	&& mv dxWDL-$DXWDL_VERSION.jar dxWDL.jar


###############################################################################
# Super Minityper CPU
###############################################################################
FROM ${LINUX_DISTRO}:${LINUX_DISTRO_VERSION} AS super-minityper-cpu

# Ensure apt-get won't prompt for selecting options
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Copy minmap2 binary
COPY --from=minimap2 /opt/lh3/minimap2/build/minimap2 /opt/lh3/minimap2/bin/
# Copy minigraph binary
COPY --from=minigraph /opt/lh3/minigraph/build/minigraph /opt/lh3/minigraph/bin/
# Copy seqwish binary
COPY --from=seqwish /opt/ekg/seqwish/build/seqwish/bin/seqwish /opt/ekg/seqwish/bin/
# Copy svaha2 binary
COPY --from=svaha2 /opt/edawson/svaha2/build/svaha2 /opt/edawson/svaha2/bin/

ENV PATH=/opt/lh3/minimap2/bin:/opt/lh3/minigraph/bin:/opt/ekg/seqwish/bin:/opt/edawson/svaha2/bin:${PATH}
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

RUN apt-get update && apt-get install -y --no-install-recommends \
		zlib1g \
		libgomp1 \
		libatomic1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace


###############################################################################
# Super Minityper
###############################################################################
FROM ${FROM_IMAGE}:${CUDA_VERSION}-base-${LINUX_VERSION} AS super-minityper

# Ensure apt-get won't prompt for selecting options
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Set environment variables
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=/opt/nvidia/clara-genomics/bin:/opt/nvidia/clara-genomics/racon-gpu/bin:/opt/lh3/minimap2/bin:/opt/lh3/minigraph/bin:/opt/ekg/seqwish/bin:/opt/edawson/svaha2/bin:${PATH}
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib:/opt/nvidia/clara-genomics/lib

WORKDIR /workspace

# Copy Clara Genomics Analysis binaries
COPY --from=cga /opt/nvidia/clara-genomics/build/ClaraGenomicsAnalysis/pyclaragenomics/requirements.txt /opt/nvidia/clara-genomics/pyclaragenomics/
COPY --from=cga /opt/nvidia/clara-genomics/build/ClaraGenomicsAnalysis/pyclaragenomics/dist/*.whl /opt/nvidia/clara-genomics/pyclaragenomics/dist/
COPY --from=cga /opt/nvidia/clara-genomics/build/ClaraGenomicsAnalysis/pyclaragenomics/cga_build/install/ /opt/nvidia/clara-genomics/
# Copy Racon GPU binaries
COPY --from=cga /opt/nvidia/clara-genomics/build/racon-gpu/build/bin/ /opt/nvidia/clara-genomics/racon-gpu/bin/
COPY --from=cga /opt/nvidia/clara-genomics/build/racon-gpu/build/vendor/rampler/bin/ /opt/nvidia/clara-genomics/racon-gpu/bin/
COPY --from=cga /opt/nvidia/clara-genomics/build/racon-gpu/test/data/ /opt/nvidia/clara-genomics/build/racon-gpu/test/data/
# Copy htslib binaries
COPY --from=cga /opt/nvidia/clara-genomics/build/htslib/install/ /usr/local/
# Copy minmap2 binary
COPY --from=minimap2 /opt/lh3/minimap2/build/minimap2 /opt/lh3/minimap2/bin/
# Copy minigraph binary
COPY --from=minigraph /opt/lh3/minigraph/build/minigraph /opt/lh3/minigraph/bin/
# Copy seqwish binary
COPY --from=seqwish /opt/ekg/seqwish/build/seqwish/bin/seqwish /opt/ekg/seqwish/bin/
# Copy svaha2 binary
COPY --from=svaha2 /opt/edawson/svaha2/build/svaha2 /opt/edawson/svaha2/bin/

# Correct binary locations for racon_wrapper
RUN sed -i -e 's#/opt/nvidia/clara-genomics/build/racon-gpu/build/bin/racon#/opt/nvidia/clara-genomics/racon-gpu/bin/racon#' \
        -e 's#/opt/nvidia/clara-genomics/build/racon-gpu/build/vendor/rampler/bin/rampler#/opt/nvidia/clara-genomics/racon-gpu/bin/rampler#' \
        /opt/nvidia/clara-genomics/racon-gpu/bin/racon_wrapper

# Install dependencies for Clara Genomics SDK
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        libcurl4 \
        libcurl3-gnutls \
        wget \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/bin/python /usr/bin/pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && pip install --no-cache-dir --upgrade wheel setuptools \
    && pip install --no-cache-dir -r /opt/nvidia/clara-genomics/pyclaragenomics/requirements.txt \
    && pip install --no-cache-dir /opt/nvidia/clara-genomics/pyclaragenomics/dist/*.whl \
    && rm -rf /var/lib/apt/lists/*

#============================
# OpenJDK JRE 8 for Nextflow
#   From 8u222-jre-slim : https://github.com/docker-library/openjdk/blob/451e66427f3c53fada288aaff950617c5864745f/8/jre/slim/Dockerfile
#============================

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
# utilities for keeping Debian and OpenJDK CA certificates in sync
		ca-certificates p11-kit \
	; \
	rm -rf /var/lib/apt/lists/*

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_HOME /usr/local/openjdk-8
ENV PATH $JAVA_HOME/bin:$PATH

# backwards compatibility shim
RUN { echo '#/bin/sh'; echo 'echo "$JAVA_HOME"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home && [ "$JAVA_HOME" = "$(docker-java-home)" ]

# https://adoptopenjdk.net/upstream.html
ENV JAVA_VERSION 8u222
ENV JAVA_BASE_URL https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u222-b10/OpenJDK8U-jre_
ENV JAVA_URL_VERSION 8u222b10
# https://github.com/docker-library/openjdk/issues/320#issuecomment-494050246

RUN set -eux; \
	\
	dpkgArch="$(dpkg --print-architecture)"; \
	case "$dpkgArch" in \
		amd64) upstreamArch='x64' ;; \
		arm64) upstreamArch='aarch64' ;; \
		*) echo >&2 "error: unsupported architecture: $dpkgArch" ;; \
	esac; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		dirmngr \
		gnupg \
		wget \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	wget -O openjdk.tgz.asc "${JAVA_BASE_URL}${upstreamArch}_linux_${JAVA_URL_VERSION}.tar.gz.sign"; \
	wget -O openjdk.tgz "${JAVA_BASE_URL}${upstreamArch}_linux_${JAVA_URL_VERSION}.tar.gz" --progress=dot:giga; \
	\
	export GNUPGHOME="$(mktemp -d)"; \
# TODO find a good link for users to verify this key is right (https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2019-April/000951.html is one of the only mentions of it I can find); perhaps a note added to https://adoptopenjdk.net/upstream.html would make sense?
# no-self-sigs-only: https://salsa.debian.org/debian/gnupg2/commit/c93ca04a53569916308b369c8b218dad5ae8fe07
	gpg --batch --keyserver ha.pool.sks-keyservers.net --keyserver-options no-self-sigs-only --recv-keys CA5F11C6CE22644D42C6AC4492EF8D39DC13168F; \
# also verify that key was signed by Andrew Haley (the OpenJDK 8 and 11 Updates OpenJDK project lead)
# (https://github.com/docker-library/openjdk/pull/322#discussion_r286839190)
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys EAC843EBD3EFDB98CC772FADA5CD6035332FA671; \
	gpg --batch --list-sigs --keyid-format 0xLONG CA5F11C6CE22644D42C6AC4492EF8D39DC13168F \
		| tee /dev/stderr \
		| grep '0xA5CD6035332FA671' \
		| grep 'Andrew Haley'; \
	gpg --batch --verify openjdk.tgz.asc openjdk.tgz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME"; \
	\
	mkdir -p "$JAVA_HOME"; \
	tar --extract \
		--file openjdk.tgz \
		--directory "$JAVA_HOME" \
		--strip-components 1 \
		--no-same-owner \
	; \
	rm openjdk.tgz*; \
	\
# TODO strip "demo" and "man" folders?
	\
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
# update "cacerts" bundle to use Debian's CA certificates (and make sure it stays up-to-date with changes to Debian's store)
# see https://github.com/docker-library/openjdk/issues/327
#     http://rabexc.org/posts/certificates-not-working-java#comment-4099504075
#     https://salsa.debian.org/java-team/ca-certificates-java/blob/3e51a84e9104823319abeb31f880580e46f45a98/debian/jks-keystore.hook.in
#     https://git.alpinelinux.org/aports/tree/community/java-cacerts/APKBUILD?id=761af65f38b4570093461e6546dcf6b179d2b624#n29
	{ \
		echo '#!/usr/bin/env bash'; \
		echo 'set -Eeuo pipefail'; \
		echo 'if ! [ -d "$JAVA_HOME" ]; then echo >&2 "error: missing JAVA_HOME environment variable"; exit 1; fi'; \
# 8-jdk uses "$JAVA_HOME/jre/lib/security/cacerts" and 8-jre and 11+ uses "$JAVA_HOME/lib/security/cacerts" directly (no "jre" directory)
		echo 'cacertsFile=; for f in "$JAVA_HOME/lib/security/cacerts" "$JAVA_HOME/jre/lib/security/cacerts"; do if [ -e "$f" ]; then cacertsFile="$f"; break; fi; done'; \
		echo 'if [ -z "$cacertsFile" ] || ! [ -f "$cacertsFile" ]; then echo >&2 "error: failed to find cacerts file in $JAVA_HOME"; exit 1; fi'; \
		echo 'trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$cacertsFile"'; \
	} > /etc/ca-certificates/update.d/docker-openjdk; \
	chmod +x /etc/ca-certificates/update.d/docker-openjdk; \
	/etc/ca-certificates/update.d/docker-openjdk; \
	\
# https://github.com/docker-library/openjdk/issues/331#issuecomment-498834472
	find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
	ldconfig; \
	\
# basic smoke test
	java -version

#==========
# Nextflow
#==========
RUN wget -qO- https://get.nextflow.io | bash \
	&& mv nextflow /usr/local/bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
        graphviz \
    && rm -rf /var/lib/apt/lists/*
