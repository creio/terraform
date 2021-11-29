#!/usr/bin/env bash

sudo su
apt update
apt -y install apt-transport-https software-properties-common ca-certificates curl iproute2 gnupg \
    git ufw bash-completion htop nano tmux

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt-cache policy docker-ce
apt -y install docker-ce docker-ce-cli containerd.io

dc_version=$(curl -s "https://github.com/docker/compose/releases/latest" | sed 's#.*tag/\(.*\)\".*#\1#')
curl -L "https://github.com/docker/compose/releases/download/$dc_version/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
systemctl enable docker

# ufw allow ssh
# ufw allow http
# ufw allow https
# ufw enable
