## Trabalho Final de Segurança da Informação

Neste projeto, você se concentrará em projetar, implantar e gerenciar uma rede usando tecnologia Linux, com ênfase no serviço Web e virtualização com Vagrant e Docker.

## Instruções de Uso

1. Clone o repositório do Github.
2. Acesse-o pelo terminal a pasta onde o projeto foi clonado e execute o comando "vagrant up" para iniciar a criação das VMs.
3. Verifique os status de cada VM com o comando "vagrant status" e veja se estão criadas ou não.
4. Após verificar os status de cada VM, digite "vagrant ssh" junto com o nome da VM (vm1 ou vm2) para iniciar o shell de cada uma.
5. Por fim, desligue as VMs digitando o comando "vagrant halt", e caso queira apaga-las, digite o comando "vagrant destroy".

## Estrutura do Projeto

- DockerWeb
  - index.html
- provisioners
  - web_provision.sh
  - vm2_provision.sh
- vagrantfile
- README.md

## Pré-requisitos

- Considerar sistema de criação Ubuntu Based
- Vagrant 2.2.19
- VirtualBox 6.1
- Docker 24.0.5
- Imagem ISO do Ubuntu Server 20.04 LTS deverá estar na pasta "/root/.vagrant.d/boxes"
- Imagem Docker do serviço a ser utilizado: Web. 
  - "Web: https://hub.docker.com/_/httpd"

## Topologia

A topologia de rede resultante desse trabalho é uma rede privada com duas máquinas virtuais: uma configurada com IP estático (VM1 - Gateway) e a outra adquirindo seu IP por DHCP (VM2 - Cliente). E todos os container pegando IP da vm1.

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

## Descrição de Rede

- Sub-rede da VM1 (Gateway):

  - Interface 1:
    - Tipo: Rede Privada
    - Endereço IP: 192.168.56.10
    - Máscara de Sub-rede: /24 (255.255.255.0)

- Sub-rede da VM2 (Cliente):
  - Interface 1:
    - Tipo: Rede Privada
    - Endereço IP: 192.168.56.x (de 0 a 254, menos o 10, reservado para vm1) Determinado a partir do DHcP
    - Máscara de Sub-rede: /24 (255.255.255.0)

## Provisionamento

Os scripts de provisionamento de cada VM está localizado na pasta "provisioners". Cada script executa as configurações e a instalação dos serviços necessários para cada VM e cada Container funcionar conforme sua função.

- web_provision.sh

  - apt install -y docker.io: Instala o Docker na máquina virtual
  - docker pull httpd: Baixa a imagem do Docker do repositório Docker Hub
  - sudo docker run -d -v /vagrantWeb:/usr/local/apache2/htdocs/ --restart always -p 80:80 httpd: Inicia um contêiner Docker a partir da imagem do Apache HTTP Server, mapeando o diretório /vagrantWeb da máquina hospedeira para o diretório /usr/local/apache2/htdocs/ dentro do contêiner e faz o mapeamento da porta 80 do host para a porta 80 do contêiner, permitindo o acesso ao servidor web Apache pelo navegador

- vm2_provision.sh
  - apt update: Verifica atualizações

## Configuração dos Serviços

- Servidor Web: O servidor web estará acessível na porta 80 TCP.

## Funcionamento

O arquivo `Vagrantfile` está configurado para criar uma máquina virtual Ubuntu e provisionar contêineres Docker para cada serviço.
A VM1 funciona como um gateway entre as sub-redes, permitindo a comunicação entre a VM2 e a rede conectada à VM1.
A VM2, ao estar em uma sub-rede separada, pode acessar a VM1 (com IP 192.168.56.10) e possivelmente outras máquinas ou serviços na rede conectada à VM1.
As máquinas estão provisionadas com scripts shell para atualização de pacotes, instalação do serviço (Web) e configurações específicas.
O script de provisionamento Web configura e inicia um servidor web Apache dentro de um contêiner Docker na máquina virtual, permitindo o acesso aos arquivos presentes no diretório ./DockerWeb/ da máquina hospedeira através do servidor web no contêiner, com isso ele fornece serviços de hospedagem de sites internos.
O script de provisionamento VM2 realiza uma verificação de atualizações, incluindo a instalação dos pacotes necessários.
A máquina 2 (VM2) serve para acessar todos os serviços dispostos na máquina 1 (VM1) para fins de testes.

## Resultados dos Testes

- Teste servidor Web(Apache)
  - ![servidorweb](https://github.com/orlandofilho04/Trabalho-Final-Administracao-de-Redes/assets/116850972/ed9818d0-04a8-40da-91bc-112ef2c9d4bd) <br> Através da máquina 2 (vm2) utilizando o comando 'wget', o arquivo 'index.html' é baixado através do IP e porta do servidor apache da máquina 1 (vm1).
