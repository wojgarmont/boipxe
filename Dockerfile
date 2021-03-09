FROM alpine
LABEL maintainer="wojciech.gabryjelski@p.lodz.pl"

ENV BASEDIR /srv
ENV CONFDIR $BASEDIR/etc

# Instalacja iPXE
ADD ipxe/embed.ipxe /tmp/embed.ipxe 
RUN apk --update --no-cache add --virtual .build-deps build-base perl git \
  && git clone http://git.ipxe.org/ipxe.git \
  && cd ipxe/src \
  && echo "make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe" \
  && make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe \
  && cp -a /ipxe/src/bin-x86_64-efi/ipxe.efi $BASEDIR/ \
  && rm /tmp/embed.ipxe \
  && cd / \
  && rm -rf /ipxe \
  && apk del .build-deps

# Konfiguracja DNS
ADD resolv.conf /etc/resolv.conf

# Instalacja utils i dnsmasq 
RUN apk --no-cache add \
 bash \
 tcpdump \
# iproute2-ss \
# bind-tools \
 dnsmasq 
ADD dnsmasq/dnsmasq.conf $CONFDIR/dnsmasq/dnsmasq.conf
ADD dnsmasq/dnsmasq_root.conf /etc/dnsmasq.conf

# Instalacja nginx
ADD nginx $CONFDIR/nginx
RUN apk add --no-cache nginx \
  && rm -rf /etc/nginx \
  && ln -sf $CONFDIR/nginx /etc/

# Instalacja monit
RUN apk add --no-cache monit \
  && rm -rf /etc/monit.d/*
ADD monit/monitrc /etc/monitrc
ADD monit/*.conf /etc/monit.d/
ADD monit/*.sh /etc/monit.d/
RUN chmod 700 /etc/monitrc
RUN chmod 700 /etc/monit.d/*.sh

# Dodanie skryptu startowego
ADD start.sh /start.sh

ENTRYPOINT ["/start.sh"]
