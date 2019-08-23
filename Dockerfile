FROM ubuntu:16.04

# First: get all the dependencies:

RUN  apt-get update
# wget, unzip
RUN apt-get install -y wget unzip apt-file

# install opencv dependencies
# compiler
RUN apt-get install -y build-essential
# required dependencies
RUN apt-get install -y cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
# optional dependencies
RUN apt-get install -y python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
#dlib
RUN apt-get install -y libx11-dev libatlas-base-dev
RUN apt-get install -y libgtk-3-dev libboost-python-dev
RUN apt-get install -y libopenblas-dev liblapack-dev
RUN apt-get install -y cmake-curses-gui

#get dlib
ARG DLIB_VERSION='19.16'
RUN cd /root/ && \
    wget https://github.com/davisking/dlib/archive/v${DLIB_VERSION}.zip && \
    unzip v${DLIB_VERSION}.zip && \
    rm v${DLIB_VERSION}.zip && \
    cd dlib-${DLIB_VERSION} && \
    mkdir -p build && \
    cd build && \
    echo CMAKE && \
    cmake .. && \
    echo cmakebuildconfigRelease && \
    cmake --build . --config Release && \
    make install && \
    ldconfig
RUN ln -s /root/dlib-${DLIB_VERSION} dlib


# get openCV
ARG OPENCV_VERSION='4.0.1'
RUN cd /root/ && \
    wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
    unzip ${OPENCV_VERSION}.zip && \
    rm ${OPENCV_VERSION}.zip && \
    cd opencv-${OPENCV_VERSION} && \
    mkdir -p build && \
    cd build && \
    echo CMAKE && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    echo MAKEJ8 && \
    make -j4 && \
    echo MAKEINSTALL && \
    make install


#get and install gitlabrunnner

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates wget apt-transport-https vim nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get install curl
RUN apt-get update -y 
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y maven
RUN curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash

RUN wget -q -O - https://packages.gitlab.com/gpg.key | apt-key add - && \
    apt-get update -y && \
    apt-get install -y gitlab-ci-multi-runner && \
    wget -q https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-Linux-x86_64 -O /usr/bin/docker-machine && \
    chmod +x /usr/bin/docker-machine && \
    apt-get clean && \
    mkdir -p /etc/gitlab-runner/certs && \
    chmod -R 700 /etc/gitlab-runner && \
    rm -rf /var/lib/apt/lists/*

# init sets up the environment and launches gitlab-runner
CMD ["run", "--working-directory=/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/gitlab-runner"]
