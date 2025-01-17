l2tp-ipsec-vpn-client
===
[![](https://images.microbadger.com/badges/image/jesusdf/l2tp-ipsec-vpn-client.svg)](https://microbadger.com/images/jesusdf/l2tp-ipsec-vpn-client) [![](https://images.microbadger.com/badges/version/jesusdf/l2tp-ipsec-vpn-client.svg)](https://microbadger.com/images/jesusdf/l2tp-ipsec-vpn-client) [![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/jesusdf/l2tp-ipsec-vpn-client/blob/master/LICENSE)

A tiny Alpine based docker image to quickly setup an L2TP over IPsec VPN client w/ PSK.

Forked from https://github.com/ubergarm/l2tp-ipsec-vpn-client to meet custom needs.

## Motivation
Does your office or a client have a VPN server already setup and you
just need to connect to it? Do you use Linux and are jealous that the
one thing a MAC can do better is quickly setup this kind of VPN? Then
here is all you need:

1. VPN Server Address (public and private if behind NAT)
2. Pre Shared Key
3. Username
4. Password

## Run
Setup environment variables for your credentials and config:

    export VPN_PUBLIC_IP='1.2.3.4'
    export VPN_PRIVATE_IP='192.168.2.34'
    export VPN_PSK='my pre shared key'
    export VPN_USERNAME='myuser@myhost.com'
    export VPN_PASSWORD='mypass'

Now run it (you can daemonize of course after debugging):

    docker run --rm -it --privileged --net=host \
               -v /lib/modules:/lib/modules:ro \
               -e TZ \
               -e VPN_PUBLIC_IP \
               -e VPN_PRIVATE_IP \
               -e VPN_PSK \
               -e VPN_USERNAME \
               -e VPN_PASSWORD \
                  jesusdf/l2tp-ipsec-vpn-client

Example docker compose file:

version: '2'
services:
  l2tp-ipsec-vpn-client:
    image: jesusdf/l2tp-ipsec-vpn-client
    container_name: l2tp-ipsec-vpn-client
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/ppp
    environment:
      - TZ=Europe/Madrid
      - VPN_PUBLIC_IP=123.123.123.123
      - VPN_PRIVATE_IP=172.16.123.123
      - VPN_PSK=my-preshared-key
      - VPN_USERNAME=my-domain\\\\my-username
      - VPN_PASSWORD=my-password
    #logging:
    #  driver: none
    healthcheck:
      test: ["CMD", "/sbin/ifconfig", "ppp0"]
      interval: 30s
      timeout: 5s
      retries: 2
    restart: unless-stopped

## Route
From the host machine configure traffic to route through VPN link:

    # confirm the ppp0 link and get the peer e.g. (192.0.2.1) IPV4 address
    ip a show ppp0
    # route traffic for a specific target ip through VPN tunnel address
    sudo ip route add 1.2.3.4 via 192.0.2.1 dev ppp0
    # route all traffice through VPN tunnel address
    sudo ip route add default via 192.0.2.1 dev ppp0
    # or
    sudo route add -net default gw 192.0.2.1 dev ppp0
    # and delete old default routes e.g.
    sudo route del -net default gw 10.0.1.1 dev eth0
    # when your done add your normal routes and delete the VPN routes
    # or just `docker stop` and you'll probably be okay

## Test
You can see if your IP address changes after adding appropriate routes e.g.:

    curl icanhazip.com

## Debugging
On your VPN client localhost machine you may need to `sudo modprobe af_key`
if you're getting this error when starting:
```
pluto[17]: No XFRM/NETKEY kernel interface detected
pluto[17]: seccomp security for crypto helper not supported
```

Also, it is advised to load the module pppoe on the host using `sudo modprobe pppoe`, so the docker container works with only NET_ADMIN capability.

## TODO
- [x] `ipsec` connection works
- [x] `xl2tpd` ppp0 device creates
- [x] Can forward traffic through tunnel from host
- [x] Pass in credentials as environment variables
- [x] Dynamically template out the default config files with `sed` on start
- [x] Update to use `libreswan` instead of `strongswan`
- [ ] See if this can work without privileged and net=host modes to be more portable

## References
* [royhills/ike-scan](https://github.com/royhills/ike-scan)
* [libreswan reference config](https://libreswan.org/wiki/VPN_server_for_remote_clients_using_IKEv1_with_L2TP)
* [Useful Config Example](https://lists.libreswan.org/pipermail/swan/2016/001921.html)
* [libreswan and Cisco ASA 5500](https://sgros.blogspot.com/2013/08/getting-libreswan-connect-to-cisco-asa.html)
* [NetDev0x12 IPSEC and IKE Tutorial](https://youtu.be/7oldcYljp4U?t=1586)
