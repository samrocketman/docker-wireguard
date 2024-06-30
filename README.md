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
network_args=(
  --network docker-compose-ha-consul-vault-ui_internal
  --dns 172.16.238.251
  --dns 172.16.238.252
  --ip 172.16.238.250
  -e client_remote=<your public IP>
  -e client_port=443
  -e client_dns="172.16.238.251, 172.16.238.252"
)
strict_firewall=true
```

[openvpn]: https://github.com/samrocketman/docker-openvpn
[wg]: https://www.wireguard.com
