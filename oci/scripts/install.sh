#!/usr/bin/env bash

sudo apt update
sudo apt -y install apt-transport-https software-properties-common ca-certificates curl iproute2 gnupg \
    git ufw bash-completion htop nano tmux

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt-cache policy docker-ce
sudo apt -y install docker-ce docker-ce-cli containerd.io

# dc_version=$(curl -s "https://github.com/docker/compose/releases/latest" | sed 's#.*tag/\(.*\)\".*#\1#')
# sudo curl -L "https://github.com/docker/compose/releases/download/$dc_version/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo systemctl enable docker
sudo usermod -aG docker ${USER}

# ufw allow ssh
# ufw allow http
# ufw allow https
# ufw enable

mkdir -p ~/apps
