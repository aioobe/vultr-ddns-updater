# Vultr ddns updater
Simple shell based ddns server/client for Vultr.

- No dependency on an external services such as No-IP
- No Python. Not even HTTP. Just `curl`, `netcat`, `gpg` and `jq`.
- Allows you to restrict the use of the Vultr API key to a single host

## Prep work on the Vultr side

Enable the API

- Log in to Vultr
- Go to account page > API
- Enable API
- Copy the API key

Create a DNS A record that you want to dynamically update

- Go to Products > DNS
- Select the domain under which you would like to put the dynamic record
- Add an A record with a name that matches the hostname of the server with the dynamic IP address
- Example: `A  frohike  123.123.123.123  3600`

(Use a dummy IP for now, so we can test that the setup works in the end.)

## Setup of server

We'll be picking up the public IP of the dynamic IP host from the incoming connection, so the server needs to run on a host with a public IP address (i.e. not NAT'ed). For example a Vultr instance.

SSH to the server and do

    $ git clone https://github.com/aioobe/vultr-ddns-updater.git
    $ cd vultr-ddns-updater
    $ sudo apt install jq
    $ nano -w ddns-server.sh
    <configure API_KEY, DOMAIN and PASSPHRASE>

Run `$HOME/vultr-ddns-updater/ddns-server.sh` in for example crontab `@reboot`, or in a tmux session.

## Setup of client (the machine with dynamic IP)

SSH to the client and do

    $ git clone https://github.com/aioobe/vultr-ddns-updater.git
    $ cd vultr-ddns-updater
    $ nano -w ddns-client.sh
    <coonfigure DDNS_SERVER and PASSPHRASE>

Use the name or IP of the server you setup in the previous section, and the same passphrase as before.

Test the setup with

    ./ddns-client.sh

Check the Vultr DNS page and make sure the corresponding A record has been updated.

Add this (or something similar) to your crontab:

    @reboot $HOME/vultr-ddns-updater/ddns-client.sh
    */30 * * * * $HOME/vultr-ddns-updater/ddns-client.sh

## Troubleshooting

- Make sure the DNS record has the same name as the output of `hostname` on the client (or update `ddns-client.sh` as you see fit)

If you've run into any other issue, please open a PR to update this section.
