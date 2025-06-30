FROM debian:bookworm

RUN apt-get update -o Acquire::AllowInsecureRepositories=true 
RUN apt-get install -y \
    openconnect \
    iptables \
    iproute2 \
    expect \
    dante-server \
    socat \
    iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ADD scripts/connect.sh /root
RUN chmod +x /root/connect.sh

ADD scripts/danted.conf /etc/danted.conf

CMD ["/root/connect.sh"]
