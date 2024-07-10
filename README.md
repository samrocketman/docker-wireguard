# A personal VPN using wireguard

Similar to my personal [OpenVPN server][openvpn] but using [wireguard][wg] as the
underlying technology.

# Features

- Allocates a VPN network at 10.90.80.0/24.
- Automatically create and revoke client IPs.
- VPN service will automatically reconfigure when clients are created or
  revoked.
- Performs full tunnel with NAT masquerade by default in client config.  All
  device traffic goes through the VPN tunnel.

# Prerequisite

Your host kernel must be Linux 5.6 or greater.

The `wireguard` kernel module must be activated.

```bash
modprobe wireguard

# load module on reboot
echo wireguard >> /etc/modules
```

# Quickstart

```bash
./wvpn.sh
./wvpn.sh new_client "My phone"

# generate a QR code for wireguard mobile app
./wvpn.sh qrcode 10.90.80.1

# or create a text config for the same IP
./wvpn.sh config 10.90.80.1 > wg-config.conf
```

Later, if you want to revoke a client you do so by IP.

```bash
# list clients
./wvpn.sh clients

# revoke by IP
./wvpn.sh revoke 10.90.80.1
```

Learn [more commands](docs/help.md).

# Environment for docker compose consul server

Add a file named `.env` before running `./wvpn.sh` commands.

```bash
environment_args=(
  -e client_remote=<your public IP>
  -e client_port=443
  -e client_dns="172.16.238.251, 172.16.238.252"
)
network_args=(
  --network docker-compose-ha-consul-vault-ui_internal
  --dns 172.16.238.251
  --dns 172.16.238.252
  --ip 172.16.238.250
)
strict_firewall=true
```

# Environment for pihole container

If you only want pihole as your DNS server, then you may optionally use

    ./scripts/pihole.sh start

With `.env` configuration:

```bash
environment_args=(
  -e client_remote=<your ip>
  -e client_port=443
  -e client_dns="172.173.174.254"
)
network_args=(
  --network pihole-net
  --dns 172.173.174.254
  --ip 172.173.174.253
)
strict_firewall=true
#PIHOLE_TZ=America/New_York
#PIHOLE_WEBPASSWORD=yourpass
```

[openvpn]: https://github.com/samrocketman/docker-openvpn
[wg]: https://www.wireguard.com
