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
    && tar xvf htslib-${HTSLIB_VERSION}.tar.bz2 \
    && cd htslib-${HTSLIB_VERSION} \
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
# Minigraph
###############################################################################
FROM ${LINUX_DISTRO}:${LINUX_DISTRO_VERSION} AS minigraph

# Ensure apt-get won't prompt for selecting options
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /opt/lh3/minigraph/build

# Install dependencies for htslib and Clara Genomics SDK
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        build-essential \
        make \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --recursive https://github.com/lh3/minigraph.git \
    && cd minigraph \
    && make


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
ENV PATH=/opt/nvidia/clara-genomics/bin:/opt/nvidia/clara-genomics/racon-gpu/bin:/opt/lh3/minigraph/bin:${PATH}
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
COPY --from=cga /opt/nvidia/clara-genomics/build/htslib-1.9/install/ /usr/local/
# Copy minigraph binary
COPY --from=minigraph /opt/lh3/minigraph/build/minigraph /opt/lh3/minigraph/bin/

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
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /usr/bin/python /usr/bin/pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && pip install --no-cache-dir --upgrade wheel setuptools \
    && pip install --no-cache-dir -r /opt/nvidia/clara-genomics/pyclaragenomics/requirements.txt \
    && pip install --no-cache-dir /opt/nvidia/clara-genomics/pyclaragenomics/dist/*.whl \
    && rm -rf /var/lib/apt/lists/*
