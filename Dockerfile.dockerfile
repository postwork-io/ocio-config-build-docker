FROM centos:7

# Install Packages
RUN yum update -y && yum install -y \
    epel-release && \
    yum groupinstall -y "Development Tools"

RUN yum install -y \
    OpenImageIO \
    python-OpenImageIO \
    OpenColorIO-tools \
    git \
    python-pip \
    gcc \
    gcc-c++ \
    cmake \
    ilmbase-devel \
    OpenEXR-devel \
    libtiff-devel

RUN pip install numpy==1.9.2

# Build aces container
WORKDIR /build
RUN git clone https://github.com/ampas/aces_container.git && \
    cd aces_container && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install

# Build ctlrender
WORKDIR /build
RUN git clone https://github.com/ampas/CTL.git && \
    cd CTL && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install

#Copy ACES config info
WORKDIR /build
RUN mkdir -p /output && \
    git clone --branch v1.1 https://github.com/ampas/aces-dev.git

#Added this during dev to pull down newest configs
#ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

RUN git clone --branch build/aces-1.1-postwork-config https://github.com/postwork-io/postwork-OpenColorIO-Configs.git && \
    chmod u+x ./postwork-OpenColorIO-Configs/aces_1.1/python/bin/create_aces_config

ENTRYPOINT [ "/build/postwork-OpenColorIO-Configs/aces_1.1/python/bin/create_aces_config" ]

CMD ["--dontBakeSecondaryLUTs", "-a", "/build/aces-dev/transforms/ctl", "-c", "/output/aces_1.1_postwork"]