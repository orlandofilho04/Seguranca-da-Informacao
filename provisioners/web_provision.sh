#!/bin/bash

apt update
apt install -y docker.io vim curl wget git
docker pull httpd

sudo docker run -d -v /VagrantWeb:/usr/local/apache2/htdocs/ --restart always --name web -p 80:80 httpd

# Desabilitar login root por SSH
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd