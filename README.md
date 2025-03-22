# Rubberverse Dockerfiles

This is based off my rather abandoned [qor-nginx](https://github.com/Rubberverse/qor-nginx) project so a lot of stuff been reused from it. If you want to customize it, git clone this repository and change files to your liking.

## What does it do?

Spins up a 4get instance, you can learn more about it in lolcat's git repo https://git.lolcat.ca/lolcat/4get

## Where is 4get stored?

4get website files are stored in `/app/www/4get`

## Maybe a little bit more info?

- Based on `debian:bookworm-slim` image
- Includes curl, tini, nginx, openssl, ca-certificates, imagemagick, php8.2-mbstring, php8.2-dom, php8.2-imagick, php8.2-curl, php8.2-apcu, php8.2-fpm
- Site is reverse proxied via NGINX without TLS termination, do it on your own accord.
- Uses tini to manage sub-processes and reap them in case one of them crashes

## How do I build it?

`git clone` this repository then edit configuration files to your liking (optional)

Afterwards build the container out with `podman build -f Dockerfile -t localhost/4get:latest`. Let it do it's thing and afterwards you should have a container ready.

## Quadlet?

```bash
[Unit]
# Unit description
Description=4get search

[Service]
Restart=on-failure

[Install]
WantedBy=default.target

[Container]
# Base
Image=localhost/4get:latest
ContainerName=4get
# Secrets
# Volumes
Volume=${HOME}/AppData/3_USER/Captcha:/app/www/4get/data/captcha:ro,Z
# Labels
NoNewPrivileges=true
# Capabilities
DropCapability=all
# Container User
Network=pasta:--ipv4-only
# Ports
PublishPort=127.0.0.1:9006:9006
```
