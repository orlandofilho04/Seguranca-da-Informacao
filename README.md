## Trabalho Final de Administração de Redes de Computadores

Neste projeto, você se concentrará em projetar, implantar e gerenciar uma rede empresarial usando tecnologia Linux, com ênfase em serviços como DHCP, DNS, Web, FTP, NFS e virtualização com Vagrant e Docker.

## Instruções de Uso

1. Clone o repositório do Github.
2. Acesse-o pelo terminal a pasta onde o projeto foi clonado e execute o comando "vagrant up" para iniciar a criação das VMs.
3. Verifique os status de cada VM com o comando "vagrant status" e veja se estão criadas ou não.
4. Após verificar os status de cada VM, digite "vagrant ssh" junto com o nome da VM (servicos-vm) para iniciar o shell de cada uma.
5. Por fim, desligue as VMs digitando o comando "vagrant halt", e caso queira apaga-las, digite o comando "vagrant destroy".

## Estrutura do Projeto

- DockerDHCP
  - dhcpd.conf
- DockerDNS
  - example.com.zone
  - named.conf
  - named.conf.local
  - rndc.key
- DockerFTP
  - vsftpd.conf
- DockerNFS
  - teste.txt
- DockerWeb
  - index.html
- provisioners
  - dhcp_provision.sh
  - dns_provision.sh
  - ftp_provision.sh
  - nfs_provision.sh
  - web_provision.sh
  - vm2_provision.sh
- vagrantfile
- README.md

## Pré-requisitos

- Considerar sistema de criação Linux Mint 21.2
- Vagrant 2.2.19
- VirtualBox 6.1
- Docker 24.0.5
- Imagem ISO do Ubuntu Server 20.04 LTS já na pasta "/root/.vagrant.d/boxes"
- Imagens Docker dos serviços a serem utilizadas: DHCP, DNS, Web, FTP e NFS. "Web: https://hub.docker.com/_/httpd", "NFS: https://hub.docker.com/r/thiagofelix/nfs_ubuntu", "DNS: https://hub.docker.com/r/ubuntu/bind9", "FTP: https://hub.docker.com/r/bogem/ftp", "DHCP: https://hub.docker.com/r/networkboot/dhcpd"

## Topologia

A topologia de rede resultante desse trabalho é uma rede privada com duas máquinas virtuais: uma configurada com IP estático (VM1 - Gateway) e a outra adquirindo seu IP por DHCP (VM2 - Cliente). E todos os container pegando ip da vm1.

- VM1 (Gateway):

  - Hostname: vm1
  - Box: ubuntu/focal64
  - Atribuição de 2048 MB de memória e 2 CPUs
  - Configuração de rede:
    - Interface de rede privada com IP estático: 192.168.56.10
    - Port forwarding de 80 no guest para 8081 no host (192.168.56.10)
    - Compartilhamento de pastas entre a máquina hospedeira e a máquina virtual
    - Provisionamento de diferentes serviços

- VM2 (Cliente):
  - Hostname: vm2
  - Box: ubuntu/focal64
  - Atribuição de 2048 MB de memória e 2 CPUs
  - Configuração de rede:
    - Interface de rede configurada para obter um endereço IP via DHCP
    - Provisionamento para atualização de pacotes e instalação do nfs-common

## Descrição de Rede

- Sub-rede da VM1 (Gateway):

  - Interface 1:
    - Tipo: Rede Privada
    - Endereço IP: 192.168.56.10
    - Máscara de Sub-rede: /24 (255.255.255.0)

- Sub-rede da VM2 (Cliente):
  - Interface 1:
    - Tipo: Rede Privada
    - Endereço IP: 192.168.56.x (de 0 a 254, menos o 10, reservado para vm1) Determinado a partir do DHP
    - Máscara de Sub-rede: /24 (255.255.255.0)

## Provisionamento

Os scripts de provisionamento de cada VM está localizado na pasta "provisioners". Cada script executa as configurações e a instalação dos serviços necessários para cada VM e cada Container funcionar conforme sua função.

- dhcp_provision.sh

  - apt install -y docker.io: Instala o Docker na máquina virtual
  - docker pull networkboot/dhcpd: Baixa a imagem do repositório Docker Hub
  - sudo docker run -v dhcpd_data:/data --name temp_container busybox true: Cria um contêiner temporário para copiar o arquivo dhcpd.conf para dentro do volume /data
  - sudo docker cp "/vagrantDHCP/dhcpd.conf" temp_container:/data/dhcpd.conf: Copia o arquivo dhcpd.conf do diretório /vagrantDHCP da máquina hospedeira para dentro do contêiner temporário, no diretório /data
  - sudo docker rm temp_container: Remove o contêiner temporário
  - sudo docker run -d --net=host -v dhcpd_data:/data --restart always -p 67:67/udp networkboot/dhcpd: Inicia um contêiner Docker a partir da imagem DHCP, permitindo que o DHCP seja distribuído na rede da máquina virtual, define o volume dhcpd_data como /data, e mapeia a porta 67 UDP do contêiner para a porta 67 UDP da máquina virtual

- dns_provision.sh

  - apt install -y docker.io: Instala o Docker na máquina virtual
  - docker pull ubuntu/bind9: Baixa a imagem do Docker do repositório Docker Hub
  - sudo docker run -d --restart always --name dns -e TZ=UTC -p 30053:53 -p 30053:53/udp -v /vagrantDNS:/etc/bind ubuntu/bind9:9.16-20.04_beta: Inicia um contêiner Docker a partir da imagem do Bind9, mapeando a porta 300053 do host para a porta 53 do contêiner (TCP e UDP) e mapeia os arquivos de configurações do Bind9 da máquina hospedeira (localizado em /vagrantDNS) para dentro do contêiner no diretório /etc/bind

- ftp_provision.sh

  - apt install -y docker.io: Instala o Docker na máquina virtual
  - docker pull bogem/ftp: Baixa a imagem do Docker do repositório Docker Hub
  - sudo docker run -d -v /vagrantFTP:/home/vsftpd \: Inicia um contêiner Docker a partir da imagem do servidor FTP, mapeando o diretório /vagrantFTP da máquina hospedeira para o diretório /home/vsftpd dentro do contêiner, mapeia as portas necessárias para o funcionamento do servidor FTP, mapeia a porta 21 para dados, fefine o nome de usuário e senha para acesso ao servidor FTP e define o endereço IP para o modo de conexão passiva

- nfs_provision.sh

  - apt install -y docker.io: Instala o Docker na máquina virtual
  - docker pull thiagofelix/nfs_ubuntu: Baixa a imagem do Docker do repositório Docker Hub
  - sudo docker run -d --restart always -e SYNC=true --name nfs -p 2049:2049 --privileged -v /vagrantNFS:/nfsshare -e SHARED_DIRECTORY=/nfsshare thiagofelix/nfs_ubuntu: Inicia um contêiner Docker a partir da imagem, define a política de reinicialização do contêiner como "always", ou seja, o contêiner será reiniciado automaticamente se parar por algum motivo, define a variável de ambiente SYNC como true , atribui o nome "nfs" ao contêiner para identificação mais fácil, mapeia a porta 2049 do host para a porta 2049 do contêiner, concede ao contêiner privilégios adicionais, mapeia o diretório /vagrantNFS da máquina hospedeira para o diretório /nfsshare dentro do contêiner, este diretório compartilhado será disponibilizado via NFS e define o diretório a ser compartilhado via NFS como /nfsshare

- web_provision.sh

  - apt install -y docker.io: Instala o Docker na máquina virtual
  - docker pull httpd: Baixa a imagem do Docker do repositório Docker Hub
  - sudo docker run -d -v /vagrantWeb:/usr/local/apache2/htdocs/ --restart always -p 80:80 httpd: Inicia um contêiner Docker a partir da imagem do Apache HTTP Server, mapeando o diretório /vagrantWeb da máquina hospedeira para o diretório /usr/local/apache2/htdocs/ dentro do contêiner e faz o mapeamento da porta 80 do host para a porta 80 do contêiner, permitindo o acesso ao servidor web Apache pelo navegador

- vm2_provision.sh
  - apt install -y nfs-common: Instala o pacote nfs-common na máquina virtual
  - sudo mkdir /acesso: Cria um diretório chamado acesso na raiz do sistema de arquivos

## Configuração dos Serviços

- DHCP: O serviço DHCP estará ouvindo na porta 67 UDP.
- DNS: O serviço DNS estará ouvindo na porta 53 TCP/UDP.
- Servidor Web: O servidor web estará acessível na porta 80 TCP.
- Servidor FTP: O servidor FTP estará acessível na porta 21 TCP.
- Servidor NFS: O servidor NFS estará acessível na porta 2049 TCP/UDP.

## Funcionamento

O arquivo `Vagrantfile` está configurado para criar uma máquina virtual Ubuntu e provisionar contêineres Docker para cada serviço.
A VM1 funciona como um gateway entre as sub-redes, permitindo a comunicação entre a VM2 e a rede conectada à VM1.
A VM2, ao estar em uma sub-rede separada, pode acessar a VM1 (com IP 192.168.56.10) e possivelmente outras máquinas ou serviços na rede conectada à VM1.
As máquinas estão provisionadas com scripts shell para atualização de pacotes, instalação de serviços (como DHCP, DNS, FTP, NFS e Web.) e configurações específicas.
O script de provisionamento DHCP automatiza o processo de instalação do Docker na máquina virtual, baixa a imagem de um servidor DHCP, copia o arquivo de configuração dhcpd.conf para dentro do contêiner e inicia um contêiner Docker com a configuração apropriada para servir como servidor DHCP na rede da máquina virtual, com isso ele atribui endereços IP automaticamente aos dispositivos na rede.
O script de provisionamento DNS automatiza a configuração de um contêiner Docker com o CoreDNS, especificando os arquivos de configuração e de banco de dados necessários para o funcionamento do servidor DNS e redirecionando as portas apropriadas para permitir o tráfego DNS, com isso ele resolve os nomes de domínio dentro da rede e configura registros DNS.
O script de provisionamento FTP configura um servidor FTP dentro de um contêiner Docker, especificando as portas a serem usadas, mapeando um diretório da máquina hospedeira para o contêiner, definindo credenciais de acesso e permitindo o reinício automático do contêiner em caso de falha, com isso ele permiti a transferência de arquivos na rede.
O script de provisionamento NFS configura um servidor NFS em um contêiner Docker na máquina virtual, compartilhando o diretório /vagrantNFS da máquina hospedeira para que possa ser acessado por outros dispositivos na rede através do protocolo NFS, com isso ele permite compartilhar diretórios e arquivos entre máquinas na rede.
O script de provisionamento Web configura e inicia um servidor web Apache dentro de um contêiner Docker na máquina virtual, permitindo o acesso aos arquivos presentes no diretório ./DockerWeb/ da máquina hospedeira através do servidor web no contêiner, com isso ele fornece serviços de hospedagem de sites internos.
O script de provisionamento VM2 realiza as etapas necessárias para configurar o cliente NFS na máquina virtual, incluindo a instalação dos pacotes necessários e a criação de um diretório onde sistemas de arquivos remotos podem ser montados.
A máquina 2 (VM2) serve para acessar todos os serviços dispostos na máquina 1 (VM1) para fins de testes.

## Resultados dos Testes

- Teste servidor DHCP
  - ![servidordhcp1](https://github.com/orlandofilho04/Trabalho-Final-Administracao-de-Redes/assets/116850972/c794d18e-334b-403f-9b06-4abd270d05fd) <br> Demostra o log do container, configurado, DHCP na máquina 1 (vm1) e testa a conexão a máquina 2 (vm2)
  - ![servidordhcp2](https://github.com/orlandofilho04/Trabalho-Final-Administracao-de-Redes/assets/116850972/b91c204e-8fec-43f6-9b4b-d1efeb8c8b71) <br> Demonstra na máquina 2 (vm2) que a rede está configurada como DHCP, estando na mesma rede (faixa de IP) e conecta a máquina 1 (vm1)
- Teste servidor DNS
  - ![servidordns](https://github.com/orlandofilho04/Trabalho-Final-Administracao-de-Redes/assets/116850972/1fc3ad10-4435-4b5d-8cab-e4bdfa534b8a) <br> Demostra o comando 'dig' com o domínio 'example.com' e também usa a ferramente 'nslookup', mostrando a resolução de nomes nesse domínio, e mostra o arquivo resolv.conf os nomes.
- Teste servidor Web(Apache)
  - ![servidorweb](https://github.com/orlandofilho04/Trabalho-Final-Administracao-de-Redes/assets/116850972/ed9818d0-04a8-40da-91bc-112ef2c9d4bd) <br> Através da máquina 2 (vm2) utilizando o comando 'wget', o arquivo 'index.html' é baixado através do IP e porta do servidor apache da máquina 1 (vm1)
- Teste servidor FTP
  - ![servidorftp](https://github.com/orlandofilho04/Trabalho-Final-Administracao-de-Redes/assets/116850972/84276ac8-9a4c-48b8-b88f-9a086b53e95f) <br> Utilizando o comando 'ftp' na máquina 2 (vm2) com IP e porta da máquina 1 (vm1), servidor FTP, realiza o login e com o comando 'get' realiza o download do arquivo para a máquina 2 (vm2)
