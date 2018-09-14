#!/bin/bash

#############
# Parameters
#############
AZUREUSER=$1
ARTIFACTS_URL_PREFIX=$2
ARTIFACTS_URL_SASTOKEN=$3
DNS_NAME=$4
WALLET_PASSWORD=$5
NETWORK=$6

###########
# Constants
###########
HOMEDIR="/home/$AZUREUSER";
WAVES_VERSION="latest";
WAVES_NODE_NAME="node1";
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

###########################
# Generate a random seed 
###########################
echo "==== generating random wallet seed =====" >> $CONFIG_LOG_FILE_PATH
WALLET_SEED=$(date +%N | sha512sum | head -c 120)
echo "==== random seed generated: $WALLET_SEED" >> $CONFIG_LOG_FILE_PATH

###########################################
# Patch the docker compose configuration
###########################################
sed -i "s/#WAVES-VERSION/$WAVES_VERSION/" $HOMEDIR/docker-compose.yml || exit 1;
sed -i "s/#WAVES-NETWORK/$NETWORK/" $HOMEDIR/docker-compose.yml || exit 1;
sed -i "s/#WAVES-WALLET-SEED/$WALLET_SEED/" $HOMEDIR/docker-compose.yml || exit 1;
sed -i "s/#WAVES-WALLET-PASSWORD/$WALLET_PASSWORD/" $HOMEDIR/docker-compose.yml || exit 1;
sed -i "s/#WAVES-NODE-NAME/$WAVES_NODE_NAME/" $HOMEDIR/docker-compose.yml || exit 1;

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
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo gpasswd -a $AZUREUSER docker

#########################################
# Install docker image from private repo
#########################################
sudo docker-compose up -d