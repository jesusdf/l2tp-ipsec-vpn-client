# To support modp1024 VPNs, use alpine 3.8
FROM alpine:3.8
# If a better dhgroup can be used, go to the last LTS version
#FROM alpine:3.17.2

ENV LANG C.UTF-8

RUN set -x && \
    apk add --no-cache \
              openrc \
              libreswan \
              xl2tpd \
              ppp \
              bash

COPY ipsec.conf /etc/ipsec.conf
COPY ipsec.secrets /etc/ipsec.secrets
COPY xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
COPY options.l2tpd.client /etc/ppp/options.l2tpd.client
COPY startup.sh /

CMD ["/startup.sh"]
