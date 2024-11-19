#!/bin/bash

apt update
apt install -y docker.io
docker pull ubuntu/bind9

sudo docker run -d --restart always --name dns -e TZ=UTC -p 30053:53 -p 30053:53/udp -v /vagrantDNS:/etc/bind ubuntu/bind9:9.16-20.04_beta