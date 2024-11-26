#!/bin/bash

# Atualizar repositórios e instalar pacotes necessários
apt-get update -y
apt-get install -y iptables ssh curl wget logrotate

# Configuração do firewall (iptables)
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Permitir tráfego essencial
iptables -A INPUT -p tcp --dport 80 -j ACCEPT  # HTTP
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # SSH
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT  # DNS
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT  # HTTPS
iptables -A INPUT -p tcp --sport 443 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT  # Loopback
iptables -A OUTPUT -o lo -j ACCEPT

# Salvar configurações do iptables
iptables-save > /etc/iptables/rules.v4

# Configurar UFW como camada adicional
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw enable

# Configuração de Hardening no Container Apache
docker exec -it web bash -c "
apt-get update -y && apt-get install -y vim
sed -i 's/Options Indexes/Options -Indexes/' /usr/local/apache2/conf/httpd.conf
echo '
<IfModule mod_ssl.c>
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
</IfModule>' >> /usr/local/apache2/conf/httpd.conf
"

# Reiniciar Apache no container para aplicar configurações
docker restart web
