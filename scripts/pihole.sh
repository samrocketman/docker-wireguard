#!/bin/bash

not_exist() {
  ! docker inspect --format=. "$1" &> /dev/null
}

if [ -f .env ]; then
  source .env
fi

if not_exist etc-pihole; then
  docker volume create etc-pihole
fi
if not_exist etc-pihole-dnsmasq; then
  docker volume create etc-pihole-dnsmasq
fi
if not_exist pihole-net; then
  docker network create --driver bridge \
    --subnet 172.173.174.0/24 \
    --gateway 172.173.174.1 \
    pihole-net
fi

case "${1:-start}" in
  start)
    if [ -z "$(docker ps -a -q -f name=pihole)" ]; then
      docker run \
        --restart always \
        --cap-add NET_ADMIN \
        -e TZ="${PIHOLE_TZ:-America/New_York}" \
        -e WEBPASSWORD="${PIHOLE_WEBPASSWORD:-}" \
        -v 'etc-pihole:/etc/pihole' \
        -v 'etc-pihole-dnsmasq:/etc/dnsmasq.d' \
        -d \
        --network pihole-net \
        --ip 172.173.174.254 \
        --name pihole \
        pihole/pihole:latest
    else
      echo 'pihole already running...'
    fi
    ;;
  stop)
    docker stop pihole
    docker rm -f pihole
    ;;
  *)
    echo 'ERROR: only pihole.sh [start|stop] allowed.' >&2
    exit 1
    ;;
esac
