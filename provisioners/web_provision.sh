#!/bin/bash

apt update
apt install -y docker.io
docker pull httpd

sudo docker run -d -v /vagrantWeb:/usr/local/apache2/htdocs/ --restart always --name web -p 80:80 httpd