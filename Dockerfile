FROM ubuntu:20.04
RUN apt-get update && apt-get install -y openconnect iptables expect dante-server socat iputils-ping

ADD scripts/connect.sh /root
RUN chmod +x /root/connect.sh

ADD scripts/danted.conf /etc/danted.conf

EXPOSE 1081 3389

CMD ["/root/connect.sh"]
