# Setup for getting Docker installed
cd /etc/apt/sources.list.d/
touch docker.list
chmod 777 docker.list
echo deb https://get.docker.io/ubuntu docker main > docker.list

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
apt-get update # now we have our new repository to search
apt-get install -y lxc-docker

# Modify `DOCKER_OPTS` so the Docker daemon is accessible from a private ip
# Note: The docker daemon location changes per distro...
#       CentOS => /etc/sysconfig/docker
#       Ubuntu => /etc/default/docker
chmod 777 /etc/default/docker
echo "DOCKER_OPTS=\"--host tcp://172.17.8.100:2375\"" >> /etc/default/docker
service docker restart
