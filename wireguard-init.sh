#!/bin/bash
# Created by Sam Gleske
# Copyright 2024 (c) Sam Gleske https://github.com/samrocketman/docker-wireguard
# Ubuntu 22.04.4 LTS
# Linux 6.5.0-41-generic x86_64
# GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)

exec 2>&1
set -euxo pipefail

# bash-based envsubst with all the power of bash string interpolation
envsubst() (
eval "
cat <<EOF
$(cat)
EOF
"
)

function genkey() {
  if [ -f /wg/conf ]; then
    return
  fi
  if [ ! -d /wg ]; then
    mkdir /wg
  fi
  if [ ! -f /wg/private ]; then
    wg genkey > /wg/private
    wg pubkey < /wg/private > /wg/public
  fi
  template | envsubst | grep -v '^$' > /wg/conf
}

template() {
cat <<'EOF'
[interface]
ListenPort = 51820
PrivateKey = $(cat /wg/private)

$(
if [ -d /wg/peers ]; then
  ls /wg/peers/*.peer | xargs cat
fi
)
EOF
}

umask 077

trap 'ip link delete wg0; echo "$(date)" removed wg0 interface.' EXIT

if ! ip link show wg0; then
  ip link add dev wg0 type wireguard
  ip address add dev wg0 10.90.80.254/24
fi

if ! iptables -t nat -L POSTROUTING | grep MASQUERADE | grep -F 10.90.80.0/24; then
  iptables -t nat -A POSTROUTING -s 10.90.80.0/24 -o eth0 -j MASQUERADE
fi

set +x
echo "$(date)" 'Entering container loop.'
while true; do
  if [ -f /wg/conf ]; then
    calculated="$(sha256sum /wg/conf)"
  else
    calculated=none
  fi
  if [ "${checksum:-}" = "${calculated}" ]; then
    sleep 5
    continue
  fi
  echo "$(date)" 'Checksum differs.  Restarting wg0 interface.'
  genkey
  calculated="$(sha256sum /wg/conf)"
  checksum="$calculated"
  ip link set wg0 down
  wg setconf wg0 /wg/conf
  ip link set wg0 up
  wg | grep -iv private
done
