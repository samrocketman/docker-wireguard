# A personal VPN using wireguard

Similar to my personal [OpenVPN server][openvpn] but using [wireguard][wg] as the
underlying technology.

# Features

- Allocates a VPN network at 10.90.80.0/24.
- Automatically create and revoke client IPs.
- VPN service will automatically reconfigure when clients are created or
  revoked.

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
