#!/bin/bash

sudo apt-get update
sudo apt-get -y install build-essential python-dev libevent-dev python-pip liblzma-dev git libssl-dev python-m2crypto swig

git clone https://github.com/dotcloud/docker-registry.git /opt/docker-registry
pushd /opt/docker-registry
pip install -r requirements/main.txt
popd

curl -sSL https://get.docker.com/ubuntu/ | sudo sh

pip_command=`which pip`
pip_build_tmp=$(mktemp --tmpdir -d pip-build.XXXXX)
$pip_command install /opt/docker-registry --build=${pip_build_tmp}

cp /opt/docker-registry/docker_registry/lib/../../config/config_sample.yml /opt/docker-registry/docker_registry/lib/../../config/config.yml
gunicorn --access-logfile - --debug -k gevent -b 0.0.0.0:5042 -w 1 docker_registry.wsgi:application &

rm -rf ${pip_build_tmp}