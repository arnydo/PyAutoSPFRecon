FROM debian:sid-slim
MAINTAINER arnydo@pm.com

ENV BIND_USER=bind \
    DATA_DIR=/data

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && apt-get update

RUN apt-get -y dist-upgrade

RUN apt-get install -y wget gnupg procps busybox less

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y bind9 bind9-host

RUN apt-get install -y dnsutils net-tools nano

RUN rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp
VOLUME ["${DATA_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/named"]