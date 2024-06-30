# CLI Help

Output from `./wvpn.sh help`:

```
./wvpn.sh for starting and stopping wireguard container service.

USAGE
  ./wvpn.sh
  ./wvpn.sh [command] [command args]

Common commands:

  Calling without arguments is the same as "./wvpn.sh start"

  ./wvpn.sh start - start the service

  ./wvpn.sh stop - stop the service

  ./wvpn.sh rm - remove the container (and if necessary network)

Geting logs:

  ./wvpn.sh l | log | logs
    Prints the log.  Optionally, arguments pass through to docker so you can
    run "./wvpn.sh l -f" and you can follow container logs.

  ./wvpn.sh ll | llog | llogs
    Same as wvpn.sh but pipes the output into less pager.

Managing clients:

  ./wvpn.sh new_client
    Issues a client starting at IP 10.90.80.1 and increments until 253.

  ./wvpn.sh clients
    List known clients.

  ./wvpn.sh qrcode [IP address]
    Prints a wireguard config as QR code for adding to a phone.

  ./wvpn.sh config [IP address]
    Prints wireguard config as text.

  ./wvpn.sh revoke [IP address]
    Revoke an existing client from VPN server.

Other client management commands:

  ./wvpn.sh new_client "some comment"
    Add a comment to the IP.

  ./wvpn.sh new_client 20 or N
    Issues a client starting at IP 10.90.80.20 or 10.90.80.N and increments
    until 253.

  ./wvpn.sh new_client 20 "some comment"
    Issues a client starting at IP 10.90.80.20 and increments until 253.  When
    it creates a client it includes a comment with the iP.
```
