#!/bin/bash

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
Address = 10.90.80.1/24
ListenPort = 443
PrivateKey = $(cat /wg/private)

$(
if [ -d /wg/peers ]; then
  ls /wg/peers/*.peer | xargs cat
fi
)
EOF
}


umask 077

if ! ip link show wg0; then
  ip link add dev wg0 type wireguard
  ip address add dev wg0 10.90.80.254/24
  genkey
  wg setconf wg0 /wg/conf
  ip link set wg0 up
fi
