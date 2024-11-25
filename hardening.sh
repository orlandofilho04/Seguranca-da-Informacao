#!/bin/bash

# Configurações de firewall

# Habilitar o firewall
apt-get update
apt-get install iptables

# Politica padrão: dropar tudo
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Liberar portas para serviço web
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT

# Liberar portas para serviço SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

# Instalando o xinetd
apt-get install xinetd -y

# Configurando o hardening xinetd apache
echo "service apache" >> /etc/xinetd.d/apache
echo "{" >> /etc/xinetd.d/apache
echo "    disable         = no" >> /etc/xinetd.d/apache
echo "    socket_type     = stream" >> /etc/xinetd.d/apache
echo "    wait            = no" >> /etc/xinetd.d/apache
echo "    user            = apache" >> /etc/xinetd.d/apache # Criar usuario apache com as permissões corretas
echo "    group           = apache" >> /etc/xinetd.d/apache # Criar grupo apache com as permissões corretas
echo "    server          = /usr/sbin/httpd" >> /etc/xinetd.d/apache
echo "    server_args     = -f /etc/httpd/conf/httpd.conf" >> /etc/xinetd.d/apache
echo "    log_on_failure  += USERID" >> /etc/xinetd.d/apache
echo "    log_on_success  += PID HOST DURATION" >> /etc/xinetd.d/apache
echo "    only_from       = 192.168.1.0/24" >> /etc/xinetd.d/apache
echo "    no_access       = 0.0.0.0/0" >> /etc/xinetd.d/apache
echo "    access_times    = 09:00-18:00" >> /etc/xinetd.d/apache
echo "    cps             = 50 10" >> /etc/xinetd.d/apache
echo "    instances       = 10" >> /etc/xinetd.d/apache
echo "    per_source      = 5" >> /etc/xinetd.d/apache
echo "    rlimit_as       = 64M" >> /etc/xinetd.d/apache
echo "    rlimit_cpu      = 10" >> /etc/xinetd.d/apache
echo "    rlimit_data     = 32M" >> /etc/xinetd.d/apache
echo "    rlimit_rss      = 32M" >> /etc/xinetd.d/apache
echo "    rlimit_stack    = 16M" >> /etc/xinetd.d/apache
echo "    rlimit_nofile   = 1024" >> /etc/xinetd.d/apache
echo "    nice            = 10" >> /etc/xinetd.d/apache
echo "}" >> /etc/xinetd.d/apache


# Configurando o xinetd para bloquear ssh
echo "service ssh" >> /etc/xinetd.d/ssh
echo "{" >> /etc/xinetd.d/ssh
echo "    disable         = no" >> /etc/xinetd.d/ssh
echo "    socket_type     = stream" >> /etc/xinetd.d/ssh
echo "    wait            = no" >> /etc/xinetd.d/ssh
echo "    user            = root" >> /etc/xinetd.d/ssh
echo "    server          = /usr/sbin/sshd" >> /etc/xinetd.d/ssh
echo "    server_args     = -i" >> /etc/xinetd.d/ssh
echo "    log_on_failure  += USERID" >> /etc/xinetd.d/ssh
echo "    log_on_success  += PID HOST DURATION" >> /etc/xinetd.d/ssh
echo "    only_from       = 192.168.1.0/24" >> /etc/xinetd.d/ssh
echo "    no_access       = 0.0.0.0/0" >> /etc/xinetd.d/ssh
echo "    instances       = 10" >> /etc/xinetd.d/ssh
echo "    per_source      = 5" >> /etc/xinetd.d/ssh
echo "    rlimit_as       = 64M" >> /etc/xinetd.d/ssh
echo "    rlimit_cpu      = 10" >> /etc/xinetd.d/ssh
echo "    rlimit_data     = 32M" >> /etc/xinetd.d/ssh
echo "    rlimit_rss      = 32M" >> /etc/xinetd.d/ssh
echo "    rlimit_stack    = 16M" >> /etc/xinetd.d/ssh
echo "    rlimit_nofile   = 1024" >> /etc/xinetd.d/ssh
echo "    nice            = 10" >> /etc/xinetd.d/ssh
echo "}" >> /etc/xinetd.d/ssh

# Reiniciando o xinetd
/etc/init.d/xinetd restart

# Gerenciar logs do servidor
tail -f /var/log/httpd/access_log
tail -f /var/log/httpd/error_log

