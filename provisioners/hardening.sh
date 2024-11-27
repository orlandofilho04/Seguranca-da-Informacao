#!/bin/bash

# Atualizar repositórios e instalar pacotes necessários
apt-get update -y
apt-get install -y iptables ssh curl wget

# Configuração do firewall (iptables)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Permitir conexões já estabelecidas ou relacionadas
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitir novas conexões para portas específicas
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT  # HTTP
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT # HTTPS
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT  # SSH
iptables -A INPUT -i lo -j ACCEPT  # Loopback
iptables -A OUTPUT -o lo -j ACCEPT

# Salvar configurações do iptables
mkdir -p /etc/iptables
touch /etc/iptables/rules.v4
iptables-save > /etc/iptables/rules.v4

# Configuração de Hardening no Container Apache
sudo docker exec -it web bash -c "
apt-get update -y && apt-get install -y vim
sed -i 's/Options Indexes/Options -Indexes/' /usr/local/apache2/conf/httpd.conf
echo '
<IfModule mod_ssl.c>
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
</IfModule>' >> /usr/local/apache2/conf/httpd.conf
echo 'Header always set X-Content-Type-Options "nosniff"' >> /usr/local/apache2/conf/httpd.conf
echo 'Header always set X-Frame-Options "DENY"' >> /usr/local/apache2/conf/httpd.conf
"

# Reiniciar Apache no container para aplicar configurações
docker restart web
