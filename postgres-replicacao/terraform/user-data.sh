#!/bin/bash
set -eux

# Atualiza o sistema
apt-get update -y

# Instala dependências
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Adiciona a chave GPG oficial da Docker
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

# Adiciona o repositório oficial da Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualiza novamente
apt-get update -y

# Instala Docker
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Habilita o serviço
systemctl enable docker
systemctl start docker

# Permite que o usuário ubuntu use Docker
usermod -aG docker ubuntu

# Cria um diretório para a aplicação
mkdir -p /home/ubuntu/postgres/replicacao

chown -R ubuntu:ubuntu /home/ubuntu/postgres/replicacao

echo "Instalação concluída!"
