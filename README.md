# A personal VPN using wireguard

Similar to my personal [OpenVPN server][openvpn] but using [wireguard][wg] as the
underlying technology.

# Environment for docker compose consul server

```bash
network_args=(
  --network docker-compose-ha-consul-vault-ui_internal
  --dns 172.16.238.251
  --dns 172.16.238.252
  --ip 172.16.238.250
  -e client_remote=***REMOVED***
  -e client_port=443
  -e client_dns="172.16.238.251, 172.16.238.252"
)
strict_firewall=true
```

[openvpn]: https://github.com/samrocketman/docker-openvpn
[wg]: https://www.wireguard.com
