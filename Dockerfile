# Dockerfile - minimal Ubuntu environment for Pi-Pwn / PPPwn
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    python3-venv \
    iproute2 \
    net-tools \
    iputils-ping \
    wget \
    ca-certificates \
    libpcap-dev \
    clang \
    cmake \
    locales \
    curl \
    sudo \
    udev \
    && rm -rf /var/lib/apt/lists/*

# create a user to avoid running everything as root (optional)
RUN useradd -m -s /bin/bash docker-pwn && echo "docker-pwn ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/docker-pwn
USER docker-pwn

# keep container running by default; override with docker exec to run tools
ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["while true; do sleep 3600; done"]
