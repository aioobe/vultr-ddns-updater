#!/bin/sh

DDNS_SERVER="..." # The server running ddns-server.sh
PASSPHRASE="..."  # The same passphrase as configured on the server.

{ hostname; ifconfig; } \
    | gpg --symmetric --batch --yes --passphrase "$PASSPHRASE" \
    | netcat -N "$DDNS_SERVER" 5353
