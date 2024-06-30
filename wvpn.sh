#!/bin/bash

declare -a network_args
[ ! -f .env ] || source .env

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
  restart|r)
    stop || true
    $0 remove || true
    start
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
    $0 log | less
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
  client_peers)
    docker exec wireguard /bin/bash -ec 'cd /wg/peers; for x in *.peer; do echo "${x%.peer}";done'
    ;;
  *)
    echo "ERROR: argument '$1' not supported." >&2
    echo "Usage: $0 [start|stop|restart|log|llog|log -f|remove]" >&2
    echo "Short usage (start no arguments): $0 [s|r|l|ll|l -f|rm]" >&2
    exit 1
    ;;
esac
