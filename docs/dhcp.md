# Can Wireguard have DHCP?

No

# Explanation

All of the following text is a direct quote from [a Reddit comment][reddit].


I know this is years old and you probably don't need a response anymore, but
this post still ranks prominently on google. Dynamic addresses over wireguard
still isn't a thing; wg-dynamic hasn't had any development in the 3 years since
your question.

    How does it keep a record of what IP's it has assigned to what QR codes /
    peers? I have been allocating individual IP's to each client.

What you're doing is correct.

```
[interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = ... your server private key

[Peer]
PublicKey = ... client1's public key
AllowedIPs = 10.0.0.2/32

[Peer]
PublicKey = ... client2's public key
AllowedIPs = 10.0.0.3/32

[Peer]
...
```

On the server this says "Make a network `10.0.0.0 - 10.0.0.255` and give the
server the IP `10.0.0.1`" and then the /32 mask on each peer prevents that peer
from having any other IP than the assigned IP.

On the clients it would look like:

```
[Interface]
Address = 10.0.0.2/24
PrivateKey = ... the client1's privkey

[Peer]
PublicKey = ... the server's pubkey
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 123.44.55.66:51820
```

This example client config connects to the server (assuming its IP is
`123.44.55.66`; you can of course use a domain name). In the interface section,
you might also want to include something like `DNS = 10.0.0.1` if the wireguard
server is providing DNS. The address assigned by the client must match the
address allowed in the server's peer list. `/24` on the client defines the
network, but I've found `/32` also works. In the client config AllowedIPs is the
list of networks that you want to access via the VPN. If you want to get your
internet through the vpn, use `0.0.0.0/0`. If you only want to access the other
VPN clients, use `10.0.0.0/24`. If you only want to access a home or workplace
LAN, maybe something like `192.168.1.0/24`. It's up to the firewall on the
wireguard server to further limit traffic.

You make a different one of these client configs for each of the peers that the
server knows about. The client configs can be encoded as QR codes.

Compared with something like OpenVPN, a downside is that each peer has a static
IP that's enforced by the server. But, an upside is that each peer has a static
IP that's enforced by the server. Why is that an upside? You can now set up
firewall rules on the server based on those static IPs to limit traffic for
specific clients. Maybe your VPN server is at home. 1 client should only have
access to the internet via the VPN, another should have access to the LAN (for
remote administration, etc). On a corporate network, different clients might
have access to different internal subnets.

[reddit]: https://www.reddit.com/r/WireGuard/comments/bz19cq/comment/iyt3z8e/
