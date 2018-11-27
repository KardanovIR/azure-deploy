#!/bin/bash

#############
# Parameters
#############
AZUREUSER=$1
ARTIFACTS_URL_PREFIX=$2
DNS_NAME=$3

#############
# Waves Parameters
#############

WAVES_NETWORK=$4
WAVES_NODE_NAME=$5
WAVES_WALLET_SEED=$6
WAVES_WALLET_PASSWORD=$7
WAVES_LOG_LEVEL=$8
WAVES_REST_API_ENABLED=$9


###########
# Constants
###########
HOMEDIR="/home/$AZUREUSER";
CONFIG_LOG_FILE_PATH="$HOMEDIR/config.log";

######################
# URL parsing (root)
######################
ARTIFACTS_URL_ROOT=${ARTIFACTS_URL_PREFIX%\/*}

#############
# Use the default user
#############
cd "/home/$AZUREUSER";

###########################
# Cache the scripts locally
###########################
sudo curl -sL --max-time 10 --retry 3 --retry-delay 3 --retry-max-time 60 ${ARTIFACTS_URL_ROOT}/scripts/docker-compose.yml${ARTIFACTS_URL_SASTOKEN} -o $HOMEDIR/docker-compose.yml || exit 1;
echo "==== docker compose download completed =====" >> $CONFIG_LOG_FILE_PATH

###########################################
# Patch the docker compose configuration
###########################################
CURRENT_NODE_IP=`nslookup $HOSTNAME | grep "Address:" | tail -n1| grep -oP '\d+\.\d+\.\d+\.\d+'`
sed -i "s/#EXT-IP/$DNS_NAME/" $HOMEDIR/docker-compose.yml || exit 1;
sed -i "s/#INT-IP/$CURRENT_NODE_IP/" $HOMEDIR/docker-compose.yml || exit 1;

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
sudo curl -L "https://github.com/docker/compose/releases/download/1.11.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#########################################
# Install docker image from private repo
#########################################
sudo mkdir /waves

sudo docker run -dt --restart=always -e WAVES__REST_API__ENABLE=yes -e WAVES__REST_API__BIND_ADDRESS=0.0.0.0 -e WAVES_AUTODETECT_ADDRESS=yes -e WAVES_NETWORK=${WAVES_NETWORK} -e WAVES_NODE_NAME=${WAVES_NODE_NAME} -e WAVES_WALLET_SEED=${WAVES_WALLET_SEED} -e WAVES_WALLET_PASSWORD=${WAVES_WALLET_PASSWORD} -e WAVES_LOG_LEVEL=${WAVES_LOG_LEVEL} -e WAVES__REST_API__ENABLE=${WAVES_REST_API_ENABLED} -v /waves:/waves wavesplatform/node