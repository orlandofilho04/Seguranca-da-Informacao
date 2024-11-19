#!/bin/bash

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

apt update
apt install -y docker.io
apt install -y net-tools
docker pull networkboot/dhcpd

sudo docker run -v dhcpd_data:/data --name temp_container busybox true
sudo docker cp "/vagrantDHCP/dhcpd.conf" temp_container:/data/dhcpd.conf
sudo docker rm temp_container


sudo docker run -d --net=host -v dhcpd_data:/data --restart always --name dhcp -p 67:67/udp networkboot/dhcpd