#!/bin/bash
# Created by Sam Gleske
# Copyright 2024 (c) Sam Gleske https://github.com/samrocketman/docker-wireguard
# Ubuntu 22.04.4 LTS
# Linux 6.5.0-41-generic x86_64
# GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)

declare -a network_args
[ ! -f .env ] || source .env

helpdoc() {
cat <<'EOF'
./wvpn.sh for starting and stopping wireguard container service.

USAGE
  ./wvpn.sh
  ./wvpn.sh [command] [command args]

Common commands:

  Calling without arguments is the same as "./wvpn.sh start"

  ./wvpn.sh start - start the service

  ./wvpn.sh stop - stop the service

  ./wvpn.sh rm - remove the container (and if necessary network)

Geting logs:

  ./wvpn.sh l | log | logs
    Prints the log.  Optionally, arguments pass through to docker so you can
    run "./wvpn.sh l -f" and you can follow container logs.

  ./wvpn.sh ll | llog | llogs
    Same as wvpn.sh but pipes the output into less pager.

Managing clients:

  ./wvpn.sh new_client
    Issues a client starting at IP 10.90.80.1 and increments until 253.

  ./wvpn.sh clients
    List known clients.

  ./wvpn.sh qrcode [IP address]
    Prints a wireguard config as QR code for adding to a phone.

  ./wvpn.sh config [IP address]
    Prints wireguard config as text.

  ./wvpn.sh revoke [IP address]
    Revoke an existing client from VPN server.

Other client management commands:

  ./wvpn.sh new_client "some comment"
    Add a comment to the IP.

  ./wvpn.sh new_client 20 or N
    Issues a client starting at IP 10.90.80.20 or 10.90.80.N and increments
    until 253.

  ./wvpn.sh new_client 20 "some comment"
    Issues a client starting at IP 10.90.80.20 and increments until 253.  When
    it creates a client it includes a comment with the iP.

EOF
}

start() {
  if ! docker inspect -f . wg &> /dev/null; then
    docker build -t wg .
  fi

  if [ -n "${strict_firewall:-}" ]; then
    ports_map=443:51820/udp
  else
    ports_map="${ports_map:-51820:51820/udp}"
  fi

  if [ "${#network_args[@]}" -eq 0 ]; then
    if [ -z "$(docker network ls -q -f name=wireguard)" ]; then
      docker network create --driver=bridge --subnet=172.9.8.0/24 wireguard
    fi
    network_args=( --network wireguard )
  fi

  if [ -z "$(docker ps -a -q -f name=wireguard)" ]; then
    echo 'Created new wireguard service.' >&2
    docker run \
      -p "${ports_map}" \
      --cap-add NET_ADMIN \
      -v "$PWD"/wg:/wg \
      -w /wg \
      --name wireguard \
      "${network_args[@]}" \
      --sysctl net.ipv6.conf.all.disable_ipv6=0 \
      --sysctl net.ipv6.conf.default.forwarding=1 \
      --sysctl net.ipv6.conf.all.forwarding=1 \
      --sysctl net.ipv4.ip_forward=1 \
      -d \
      --restart always \
      wg
  else
    echo -n "Started "
    docker start wireguard
    echo >&2
    echo "Run command '$0 llog'" >&2
  fi
}

stop() {
  echo -n "Stopped "
  docker stop wireguard
}

case "${1:-start}" in
  start)
    start
    ;;
  stop|s)
    stop
    ;;
  remove|rm)
    docker rm -f wireguard
    if [ "${#network_args[@]}" -eq 0 ]; then
      docker network rm wireguard
    fi
    ;;
  log|logs|l)
    shift
    docker logs "$@" wireguard
    ;;
  llog|llogs|ll)
    $0 log 2>&1 | less
    ;;
  revoke)
    docker exec wireguard /bin/bash -exc "if [ ! -f /wg/peers/'${2:-}' ]; then echo peer does not exist;exit;fi; rm -f /wg/peers/'${2}'*; rm -f /wg/conf; echo wireguard server restarting."
    ;;
  qrcode)
    docker exec wireguard /bin/bash -ec "qrencode -t ansiutf8 < /wg/peers/'${2:-}'"
    ;;
  new_client)
    shift
    docker exec wireguard /client.sh "$@"
    ;;
  clients)
    docker exec wireguard /bin/bash -ec 'cd /wg/peers; for x in *.peer; do msg="${x%.peer}"; comment="$(grep "^#" "$x" | sed "s/^# //" | head -n1)"; if [ -n "${comment:-}" ]; then msg+=" - ${comment}";fi; echo "${msg}";done'
    ;;
  help)
    helpdoc
    ;;
  *)
    echo "ERROR: argument '$1' not supported." >&2
    echo "Usage: $0 [start|stop|log|llog|log -f|remove]" >&2
    echo "Short usage (start no arguments): $0 [s|l|ll|l -f|rm]" >&2
    exit 1
    ;;
esac
