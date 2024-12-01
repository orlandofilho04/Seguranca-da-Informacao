## Trabalho Final de Segurança da Informação

Neste projeto, você se concentrará em projetar, implantar e gerenciar uma rede usando tecnologia Linux, com ênfase no serviço Web e virtualização com Vagrant e Docker.
O projeto consiste em uma máquina virtual, onde há um container do serviço Apache, onde podemos hospedar uma site. Esse site em questão é uma dashboard de visualização de dados, todas as configurações foram consideradas para esse cenário em específico

## Instruções de Uso

1. Clone o repositório do Github.
2. Acesse pelo terminal a pasta onde o projeto foi clonado e execute o comando `vagrant up` para iniciar a criação das VMs.
3. Verifique o status de cada VM com o comando `vagrant status` e veja se estão criadas ou não.
4. Após verificar o status de cada VM, digite `vagrant ssh` junto com o nome da VM (vm1 ou vm2) para iniciar o shell de cada uma.
5. Por fim, desligue as VMs digitando o comando `vagrant halt`, e caso queira apagá-las, digite o comando `vagrant destroy`.

## Estrutura do Projeto

- DockerWeb
  - httpd.conf
  - index.html
- provisioners
  - hardening.sh
  - web_provision.sh
  - vm2_provision.sh
- Vagrantfile
- README.md

## Pré-requisitos

- Considerar sistema de criação Ubuntu Based
- Vagrant 2.2.19
- VirtualBox 6.1
- Docker 24.0.5
- Imagem ISO do Ubuntu Server 20.04 LTS deverá estar na pasta "/root/.vagrant.d/boxes"
- Imagem Docker do serviço a ser utilizado: Web.
  - "Web: https://hub.docker.com/_/httpd"

## Planejamento do Hardware

O projeto consiste em uma solução com foco em segurança da informação para uma aplicação web. A arquitetura inclui uma máquina virtual utilizando Vagrant, containers Docker e o serviço web Apache, com configuração de hardening de segurança.

### Configuração de Hardware das VMs

O ambiente utilizará duas VMs com configurações específicas para simular um servidor web e um cliente.

#### VM1: Servidor Web

- **Hostname:** `vm1`
- **Box:** `ubuntu/focal64`
- **Recursos Alocados:**
  - **Memória RAM:** 2048 MB
  - **CPUs:** 2 núcleos
- **Armazenamento:**
  - 20 GB de disco rígido virtual.
- **Rede:**
  - IP estático: `192.168.56.10`
  - Máscara de sub-rede: `/24` (255.255.255.0)
  - Port Forwarding:
    - Porta 80 (HTTP) no guest mapeada para a porta 8080 no host.
    - Porta 22 (SSH) no guest mapeada para a porta 2222 no host.
- **Funcionalidades:**
  - Executar o container Docker com o servidor Apache HTTP.
  - Configurações avançadas de segurança.

#### VM2: Cliente

- **Hostname:** `vm2`
- **Box:** `ubuntu/focal64`
- **Recursos Alocados:**
  - **Memória RAM:** 2048 MB
  - **CPUs:** 2 núcleos
- **Armazenamento:**
  - 10 GB de disco rígido virtual.
- **Rede:**
  - Configurada para obter endereço IP via DHCP.
  - Máscara de sub-rede: `/24` (255.255.255.0).

#### Hardware Recomendado para o Host

- **Sistema Operacional:** Ubuntu-based (versão atualizada e compatível com Vagrant e VirtualBox).
- **Memória RAM:** Pelo menos 8 GB.
- **CPU:** Processador com pelo menos 4 núcleos e suporte a virtualização (VT-x/AMD-V habilitado na BIOS).
- **Armazenamento:** 100 GB de espaço disponível no disco.
- **Placa de Rede:** Suporte a NAT e Rede Privada.

## Descrição de Rede

- Sub-rede da VM1:

  - Interface 1:
    - Tipo: Rede Privada
    - Endereço IP: 192.168.56.10
    - Máscara de Sub-rede: /24 (255.255.255.0)

- Sub-rede da VM2 (Cliente):
  - Interface 1:
    - Tipo: Rede Privada
    - Endereço IP: 192.168.56.x (de 0 a 254, menos o 10, reservado para VM1) determinado a partir do DHCP
    - Máscara de Sub-rede: /24 (255.255.255.0)

## Provisionamento

Os scripts de provisionamento de cada VM estão localizados na pasta "provisioners". Cada script executa as configurações e a instalação dos serviços necessários para cada VM e cada container funcionar conforme sua função.

### Explicação das Linhas de Código - web_provision.sh

1. **Verificar atualizações e instalar serviços necessários**

```sh
apt update
apt install -y docker.io vim curl wget git
```

**Descrição:** Instala os serviços `docker.io`, `vim`, `curl`, `wget` e `git`.

2. **Baixar a imagem oficial do servidor Apache HTTP (httpd) do Docker Hub e subir um container com o seriço necessário**

```sh
docker pull httpd
sudo docker run -d -v /VagrantWeb:/usr/local/apache2/htdocs/ --restart always --name web -p 80:80 httpd
```

**Descrição:** O comando cria e executa um container Docker em segundo plano com o servidor Apache HTTP (httpd). Ele mapeia o diretório local /VagrantWeb para o diretório de hospedagem do Apache no container (/usr/local/apache2/htdocs/), garantindo que os arquivos locais sejam servidos pelo servidor. O container é configurado para reiniciar automaticamente em caso de falhas ou reinicializações do host, utiliza o nome web e redireciona a porta 80 do host para a porta 80 do container, permitindo o acesso ao servidor Apache.

3. **Desabilitar login root por SSH**

```sh
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd
```

**Descrição:** Os comandos desabilitam o login direto como root via SSH, substituindo a configuração PermitRootLogin yes por PermitRootLogin no no arquivo de configuração do SSH e reiniciando o serviço com systemctl restart sshd. Essa medida melhora a segurança, reduzindo o risco de ataques direcionados ao usuário root..

### Explicação das Linhas de Código - hardening.sh

1. **Modificar a configuração do Apache para desativar a listagem de diretórios**

   ```sh
   sed -i 's/Options Indexes/Options -Indexes/' /usr/local/apache2/conf/httpd.conf
   ```

   **Descrição:** Substitui `Options Indexes` por `Options -Indexes` no arquivo de configuração do Apache (`httpd.conf`). Isso desativa a listagem de diretórios, impedindo que os usuários vejam o conteúdo dos diretórios se não houver um arquivo de índice presente.

2. **Configurar o módulo SSL para desativar protocolos inseguros**

   ```sh
   echo '
   <IfModule mod_ssl.c>
       SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
   </IfModule>' >> /usr/local/apache2/conf/httpd.conf
   ```

   **Descrição:** Adiciona uma configuração ao arquivo `httpd.conf` para desativar os protocolos SSLv3, TLSv1 e TLSv1.1, que são considerados inseguros. Apenas os protocolos mais seguros serão permitidos.

3. **Adicionar cabeçalhos de segurança HTTP**

   ```sh
   echo 'Header always set X-Content-Type-Options "nosniff"' >> /usr/local/apache2/conf/httpd.conf
   echo 'Header always set X-Frame-Options "DENY"' >> /usr/local/apache2/conf/httpd.conf
   echo 'Header always set X-XSS-Protection "1; mode=block"' >> /usr/local/apache2/conf/httpd.conf
   echo 'Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"' >> /usr/local/apache2/conf/httpd.conf
   ```

   **Descrição:**

   - `X-Content-Type-Options "nosniff"`: Impede que os navegadores interpretem os tipos de conteúdo incorretamente, ajudando a prevenir ataques de tipo MIME.
   - `X-Frame-Options "DENY"`: Impede que a página seja carregada em um frame ou iframe, protegendo contra ataques de clickjacking.
   - `X-XSS-Protection "1; mode=block"`: Ativa a proteção contra ataques de script entre sites (XSS) no navegador e instrui o navegador a bloquear a página se um ataque for detectado.
   - `Strict-Transport-Security "max-age=31536000; includeSubDomains"`: Habilita o HTTP Strict Transport Security (HSTS), instruindo os navegadores a acessar o site apenas via HTTPS por um ano (31536000 segundos) e a aplicar essa política a todos os subdomínios.

4. **Definir as políticas de firewall**

   ```sh
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

   # Loopback
   iptables -A INPUT -i lo -j ACCEPT
   iptables -A OUTPUT -o lo -j ACCEPT
   ```

   **Descrição:** Define as políticas de firewall para permitir conexões estabelecidas ou relacionadas, novas conexões para portas específicas e tráfego de loopback.

5. **Definir as políticas dos serviços principais utilizando o xinetd**

   - **Apache**
     ```sh
     echo 'includedir /etc/xinetd.d' >> /etc/xinetd.conf
     echo "service apache" >> /etc/xinetd.d/apache
     echo "{" >> /etc/xinetd.d/apache
     echo "    disable         = no" >> /etc/xinetd.d/apache
     echo "    socket_type     = stream" >> /etc/xinetd.d/apache
     echo "    wait            = no" >> /etc/xinetd.d/apache
     echo "    server          = /usr/sbin/httpd" >> /etc/xinetd.d/apache
     echo "    server          = /usr/bin/docker server_args = exec -i web /usr/sbin/httpd -DFOREGROUND" >> /etc/xinetd.d/apache
     echo "    log_on_failure  += USERID" >> /etc/xinetd.d/apache
     echo "    log_on_success  += PID HOST DURATION" >> /etc/xinetd.d/apache
     echo "    only_from       = 192.168.1.0/24" >> /etc/xinetd.d/apache
     echo "    no_access       = 0.0.0.0/0" >> /etc/xinetd.d/apache
     echo "    access_times    = 09:00-18:00" >> /etc/xinetd.d/apache
     echo "    port            = 80" >> /etc/xinetd.d/apache
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
     ```
   - **SSH**

     ```sh
     echo "service ssh" >> /etc/xinetd.d/ssh
     echo "{" >> /etc/xinetd.d/ssh
     echo "    disable         = no" >> /etc/xinetd.d/ssh
     echo "    socket_type     = stream" >> /etc/xinetd.d/ssh
     echo "    wait            = no" >> /etc/xinetd.d/ssh
     echo "    user            = root" >> /etc/xinetd.d/ssh
     echo "    server          = /usr/sbin/sshd" >> /etc/xinetd.d/ssh
     echo "    server_args     = -i" >> /etc/xinetd.d/ssh
     echo "    port            = 22" >> /etc/xinetd.d/ssh
     echo "    log_on_failure  += USERID" >> /etc/xinetd.d/ssh
     echo "    log_on_success  += PID HOST DURATION" >> /etc/xinetd.d/ssh
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

     service xinetd restart
     ```

     **Descrição:** Configuram serviços para serem gerenciados pelo xinetd, um daemon que gerencia a inicialização de serviços sob demanda.

## Configuração dos Serviços

- **Servidor Web:** O servidor web estará acessível na porta 80 TCP.

## Funcionamento

- Este Vagrantfile configura duas máquinas virtuais (VMs) usando Vagrant e VirtualBox como provedor. As VMs são configuradas com o sistema operacional Ubuntu 20.04 LTS (focal64).

- A primeira máquina, chamada "vm1" recebe o hostname "vm1" e utiliza a box "ubuntu/focal64". A VM é configurada com 2048 MB de memória e 2 CPUs. A rede privada é configurada com o IP estático 192.168.56.10, e há redirecionamento de portas: a porta 80 (HTTP) da VM é redirecionada para a porta 8080 do host, e a porta 22 (SSH) da VM é redirecionada para a porta 2222 do host. Além disso, a pasta local ./DockerWeb é sincronizada com a pasta /VagrantWeb na VM. Dois scripts de provisionamento, web_provision.sh e hardening.sh, são executados para configurar a VM.

- A segunda máquina, chamada "vm2", é configurada como cliente. Ela recebe o hostname "vm2" e utiliza a mesma box "ubuntu/focal64". A VM também é configurada com 2048 MB de memória e 2 CPUs. A rede privada é configurada para obter um endereço IP via DHCP. Um script de provisionamento, vm2_provision.sh, é executado para configurar a VM.

- Essas configurações permitem criar um ambiente de rede privado com duas VMs, onde a "vm1" atua como gateway e a "vm2" como cliente, facilitando o desenvolvimento e testes de aplicações em um ambiente controlado.
