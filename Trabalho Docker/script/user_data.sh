#!/bin/bash

# Atualiza pacotes
sudo apt update && sudo apt upgrade -y

# Instala dependências
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common nfs-common

# Configura repositório do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Instala Docker e habilita o serviço
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker-ce containerd.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker

# Configura grupo Docker
sudo usermod -aG docker ${USER}
newgrp docker

# Instala Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Configura Docker Compose
sudo mkdir -p /app
cat <<EOF > /app/docker-compose.yml
services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: <DB_HOST>
      WORDPRESS_DB_USER: <DB_USER>
      WORDPRESS_DB_PASSWORD: <DB_PASSWORD>
      WORDPRESS_DB_NAME: <DB_NAME>
    volumes:
      - /mnt/efs:/var/www/html
volumes:
  wordpress-data:
EOF

# Monta EFS
sudo mkdir -p /mnt/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport <EFS_ENDPOINT>:/ /mnt/efs

# Inicia o container
sudo docker-compose -f /app/docker-compose.yml up -d






