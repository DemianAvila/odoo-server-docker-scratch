#!/bin/sh

# set USER to the first argument or default to "runbot-dev"
USER=${1:-runbot-dev}

#reset everything
if [ -d "/root/.oh-my-zsh" ]; then
    rm -rf /root/.oh-my-zsh
fi
chsh -s $(which bash)
chsh --shell $(which bash) $USER
if [ -e "/home/${USER}/.zshrc" ]; then
    rm /home/${USER}/.zshrc
fi
if [ -d "/home/${USER}/.ohmyzsh" ]; then
    rm -rf /home/${USER}/.ohmyzsh
fi
if [ -e "/home/${USER}/docker-26.1.3.tgz" ]; then
    rm -rf /home/${USER}/docker-26.1.3.tgz
fi
if [ -d "/home/${USER}/docker" ]; then
    rm -rf /home/${USER}/docker
fi
if [ -d "/opt/docker" ]; then
    rm -rf /opt/docker
fi
if [ -d "/home/${USER}/.docker" ]; then
    rm -rf "/home/${USER}/.docker"
fi

# Install dev tools from the debian repo
apt update -y
apt install git zsh curl lsof inetutils-ping -y
apt upgrade -y


# Install docker binaries
wget https://download.docker.com/linux/static/stable/x86_64/docker-26.1.3.tgz
tar -xzvf docker-26.1.3.tgz
mv docker /opt
rm docker-26.1.3.tgz
for binary in /opt/docker/*; do
    ln -sf "$binary" "/usr/bin/$(basename $binary)"
done
groupadd docker
usermod -aG docker $USER
dockerd &
if ! crontab -l | grep -q "docker" ; then echo "@reboot dockerd &" | crontab - ; fi
DOCKER_CONFIG=/home/${USER}/.docker
mkdir -p $DOCKER_CONFIG
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod 777 $DOCKER_CONFIG/cli-plugins/docker-compose
wget https://github.com/docker/buildx/releases/download/v0.14.1/buildx-v0.14.1.linux-amd64
mv buildx-v0.14.1.linux-amd64 docker-buildx 
mv docker-buildx $DOCKER_CONFIG/cli-plugins
chmod 777 $DOCKER_CONFIG/cli-plugins/docker-buildx
chown -R ${USER}:${USER} $DOCKER_CONFIG


#install ohmyzsh for the developer :)
echo "ZSH_THEME=\"agnoster\"" > /home/${USER}/.zshrc
echo "source ~/.ohmyzsh/oh-my-zsh.sh" >> /home/${USER}/.zshrc
echo "export DOCKER_CONFIG=/home/${USER}/.docker" >> /home/${USER}/.zshrc
chmod 744 /home/${USER}/.zshrc
chown ${USER}:${USER} /home/${USER}/.zshrc
git clone https://github.com/ohmyzsh/ohmyzsh.git
mv ohmyzsh /home/${USER}/.ohmyzsh
chsh --shell $(which zsh) $USER
shutdown -r 0
