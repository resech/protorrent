<p align="center">
    <a href="https://github.com/resech/protorrent"><img src="https://raw.githubusercontent.com/resech/protorrent/main/.github/header.png"/></a>
</p>

# Protorrent
Proton VPN + qBittorrent (+ and VueTorrent UI)

Based heavily and forked from the work that [bubuntux](https://github.com/bubuntux/protorrent) did. If you like this image, consider supporting [him](https://github.com/sponsors/bubuntux).

# How to use this image
First you need to obtain the wireguard configurations from https://account.protonvpn.com/downloads: 
- Enable VPN Accelerator
- Enable NAT-PMP (Port Forwarding)
- Select a server that supports p2p.
  
Save this configuration file as /config/wireguard/wg0.conf

Start the container using (or equivalent)  

    docker run -d --privileged -v <localDir>:/config -p 8080:8080 ghcr.io/resech/protorrent:main

The container is only accessible locally or through the docker network, meaning that you will need a reverse proxy like [swag](https://github.com/linuxserver/docker-swag) or [traeffik](https://doc.traefik.io/traefik/providers/docker/) to access it when not running locally.

You can also add an environment variable that would open the traffic to the specified network
    
    docker run -d --privileged -v <localDir>:/config -p 8080:8080 -e NET_LOCAL=192.168.0.0/24 ghcr.io/resech/protorrent:main

This container also contains [VueTorrent](https://github.com/VueTorrent/VueTorrent/), an alternative WebUI for qBittorrent. To use it, tick the Alternative WebUI option and point it to `/vuetorrent`

# Environent ( -e )

|                 Variable                 |    Default     | Description |
|:-----------------------------------------|:--------------:| --- |
|                 `PUID`                |        1000    |   for UserID |
|                 `PGID`                |        1000    |   for GroupID |
|               `NET_LOCAL`               |          | CIDR networks (IE 192.168.1.0/24), add a route to allows replies once the VPN is up.
|                   `TZ`                  |               UTC             | Specify a timezone to use EG Europe/London.


# Disclaimer 
This project is independently developed for personal use, there is no affiliation with ProtonVPN, ProtonAG or qBittorrent,
ProtonAG companies are not responsible for and have no control over the nature, content and availability of this project.
