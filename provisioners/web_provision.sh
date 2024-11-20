#!/bin/bash

apt update
apt install -y docker.io vim curl wget git ufw
docker pull httpd

sudo docker run -d -v /VagrantWeb:/usr/local/apache2/htdocs/ --restart always --name web -p 80:80 httpd
