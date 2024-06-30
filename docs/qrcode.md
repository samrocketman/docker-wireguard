# QR encoding

### Prereququisite

Install `qrencode` on Ubuntu:

    sudo apt install qrencode

Or on alpine:

    apk add libqrencode

### Create a client config qrcode


Print QR code on terminal

    qrencode -t ansiutf8 -r wg-client.conf
    # or read from stdin
    qrencode -t ansiutf8 < wg-client.conf

Or save to PNG.

    qrencode -t png -o wg-client.png -r wg-client.conf
