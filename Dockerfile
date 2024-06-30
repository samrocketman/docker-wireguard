FROM alpine
SHELL ["/bin/sh", "-exc"]

RUN \
  apk add wireguard-tools-wg bash dumb-init curl libqrencode-tools iptables

ADD scripts/*.sh /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD /wireguard-init.sh
