#!/bin/bash

set -exuo pipefail
umask 077

start_ip_at="${1:-1}"

if [ "$start_ip_at" -lt 1 -o "$start_ip_at" -gt 253 ]; then
  echo 'ERROR: starting IP must be 1-253' >&2
  exit 1
fi

if [ ! -d /wg/peers ]; then
  mkdir -p /wg/peers
fi

# bash-based envsubst with all the power of bash string interpolation
envsubst() (
eval "
cat <<EOF
$(cat)
EOF
"
)

template() {
cat <<'EOF'
[Interface]
Address = ${ip}/32
PrivateKey = $(wg genkey)
DNS = ${client_dns}

[Peer]
PublicKey = $(cat /wg/public)
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${client_remote}:${client_port}
EOF
}

peer_template() {
cat <<'EOF'
[Peer]
PublicKey = $(grep PrivateKey /wg/peers/"${ip}" | sed 's/^[^=]\+ *= *//' | wg pubkey)
AllowedIPs = ${ip}/32
PersistentKeepalive = 25
EOF
}

create_client() (
  export ip="$1"
  template | envsubst > "/wg/peers/${ip}"
  peer_template | envsubst > "/wg/peers/${ip}.peer"
  echo 'Restart the wireguard server.'
  rm -f /wg/conf
)

eval "for x in {${start_ip_at:-1}..253}; do echo \$x;done" | while read host; do
  if [ ! -f "/wg/peers/10.90.80.$host" ]; then
    create_client "10.90.80.$host"
    exit
  fi
done

echo 'ERROR: ran out of IP space.'
exit 1
