#!/bin/bash

###############
# Parameters
###############
AZUREUSER=$1
ARTIFACTS_URL_PREFIX=$2
ARTIFACTS_URL_SASTOKEN=$3
DNS_NAME=$4
DOCKER_REPOSITORY=$5
DOCKER_LOGIN=$6
DOCKER_PASSWORD=$7
DOCKER_IMAGE=$8

####################
# Waves Parameters
####################
WAVES_NETWORK=$9
WAVES_NODE_NAME=${10}
WAVES_WALLET_SEED=${11}
WAVES_WALLET_PASSWORD=${12}
WAVES_LOG_LEVEL=${13}
WAVES_REST_API_ENABLED=${14}

#############
# Constants
#############
HOMEDIR="/home/$AZUREUSER";
CONFIG_LOG_FILE_PATH="$HOMEDIR/config.log";

#########################################
# Install docker and compose on all nodes
#########################################
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo systemctl enable docker
sleep 5
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#########################################
# Install docker image from private repo
#########################################

# cache the image before instantiating
docker pull wavesplatform/node:latest

# start the image
WAVES_NETWORK=${WAVES_NETWORK} WAVES_NODE_NAME=${WAVES_NODE_NAME} WAVES_WALLET_SEED=${WAVES_WALLET_SEED} WAVES_WALLET_PASSWORD=${WAVES_WALLET_PASSWORD} WAVES_LOG_LEVEL=${WAVES_LOG_LEVEL} WAVES__REST_API__ENABLE=${WAVES_REST_API_ENABLED} docker-compose up -d

#sudo mkdir /waves
#sudo docker run -dt --restart=always -e WAVES__REST_API__ENABLE=yes -e WAVES__REST_API__BIND_ADDRESS=0.0.0.0 -e WAVES_AUTODETECT_ADDRESS=yes -e WAVES_NETWORK=${WAVES_NETWORK} -e WAVES_NODE_NAME=${WAVES_NODE_NAME} -e WAVES_WALLET_SEED=${WAVES_WALLET_SEED} -e WAVES_WALLET_PASSWORD=${WAVES_WALLET_PASSWORD} -e WAVES_LOG_LEVEL=${WAVES_LOG_LEVEL} -e WAVES__REST_API__ENABLE=${WAVES_REST_API_ENABLED} -v /waves:/waves wavesplatform/node