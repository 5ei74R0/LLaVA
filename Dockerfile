# $ docker build -t local/llava ./
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install wget curl

ENV CUDA_HOME /usr/local/cuda

# Install and update tools to minimize security vulnerabilities
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common wget apt-utils patchelf git libprotobuf-dev protobuf-compiler cmake
RUN unattended-upgrade
RUN apt-get -y autoremove

# Python and pip
# https://devguide.python.org/setup/#linux
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential gdb lcov pkg-config \
    libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
    lzma lzma-dev tk-dev uuid-dev zlib1g-dev
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
RUN pip install -U pip

# Huggingface
# (do `-v <persistent volume's TRANSFORMERS_CACHE>:/hub` to cache models and avoid downloading them every time)
ENV TRANSFORMERS_CACHE /hub

# Setup LLaVA
WORKDIR /src
COPY . /src
RUN pip install -e .[train]
RUN pip install flash-attn --no-build-isolation
