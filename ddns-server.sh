#!/bin/sh

API_KEY="..."    # The Vultr API key
DOMAIN="..."     # The domain under which you have the dynamic A record
PASSPHRASE="..." # Random string of characters, such as the output of `pwgen 25 1`

while true
do
    netcat -lnvp 5353 2> err.txt \
        | gpg --decrypt --batch --yes --passphrase "$PASSPHRASE" > out.txt 2> /dev/null

    ip=$(grep "^Connection from" err.txt | cut -d' ' -f3)
    name=$(head -n 1 out.txt)

    # Log remaining body (ifconfig output) to ease port forwarding setup.
    tail -n +2 out.txt > "ifconfig-$name.txt"

    # Get current A record
    curl \
        --silent \
        --header "API-Key: $API_KEY" \
        "https://api.vultr.com/v1/dns/records?domain=$DOMAIN" \
            | jq ".[] | select(.name==\"$name\" and .type==\"A\")" > record.json

    if [ ! -s record.json ]
    then
        echo "No A record found for $name under $DOMAIN. Please fix configuration."
    elif [ "$(jq -r .data < record.json)" = "$ip" ]
    then
        echo "$(date): DNS record for $name already set to $ip."
    else
        echo "$(date): Updating $name to $ip"
        curl \
            --request POST \
            --header "API-Key: $API_KEY" \
            --data "domain=$DOMAIN" \
            --data "RECORDID=$(jq .RECORDID < record.json)" \
            --data "data=$ip" \
            "https://api.vultr.com/v1/dns/update_record"
    fi
done
