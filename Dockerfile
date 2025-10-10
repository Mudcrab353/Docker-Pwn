# ===============================
# Dockerfile for Pi-Pwn (Stooged)
# ===============================
FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git python3 python3-pip hostapd dnsmasq aircrack-ng iw net-tools iproute2 \
    usbutils curl wget python3-flask \
    && rm -rf /var/lib/apt/lists/*

# Clone Pi-Pwn repo
RUN git clone https://github.com/Mudcrab353/Docker-Pwn.git /opt/pi-pwn

# Install Python requirements (if any)
RUN pip3 install --no-cache-dir -r /opt/pi-pwn/requirements.txt || true

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /opt/pi-pwn
ENTRYPOINT ["/entrypoint.sh"]
