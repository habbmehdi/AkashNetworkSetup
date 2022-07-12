export AKASH_KEY_NAME=deploy
export AKASH_NET=https://raw.githubusercontent.com/ovrclk/net/master/mainnet
export AKASH_NODE=http://akash.c29r3.xyz:80/rpc 
export AKASH_VERSION=$(curl -s "$AKASH_NET/version.txt")
export AKASH_CHAIN_ID=$(curl -s "$AKASH_NET/chain-id.txt")
export AKASH_NODE=$(curl -s "$AKASH_NET/rpc-nodes.txt" | shuf -n 1)
export AKASH_KEYRING_BACKEND=os
export AKASH_ACCOUNT_ADDRESS=akash1cvp8lcprlwmkg24xk37h2nxh4hqjcsxa2rg9fs
export KEYRING_PASS=Sp24715!

echo "CREATING THE MANIFEST"

export CREATE_MANIFEST=$(echo $KEYRING_PASS | akash tx deployment create deploy.yml --from $AKASH_KEY_NAME --node $AKASH_NODE --chain-id $AKASH_CHAIN_ID --gas-prices="0.025uakt" --gas="auto" --gas-adjustment=1.15 --yes)

echo "$CREATE_MANIFEST"

echo "GETTING THE DSEQ"

export AKASH_DSEQ=$( echo "$CREATE_MANIFEST" | jq -r '.logs[0].events[0].attributes[4].value')

echo "$AKASH_DSEQ"

sleep 15

echo "GETTING THE PROVIDER FOR THE DEPLOYMENT"

export BIDS=$(akash query market bid list --owner=$AKASH_ACCOUNT_ADDRESS --output json --state open --node $AKASH_NODE --dseq $AKASH_DSEQ)

export AKASH_PROVIDER=$( echo "$BIDS" | jq -r '.bids[0].bid.bid_id.provider' )

echo "$AKASH_PROVIDER"

echo "CREATING THE DEPLOYMENT"

sleep 10

echo $KEYRING_PASS | akash tx market lease create --chain-id $AKASH_CHAIN_ID --node $AKASH_NODE --owner $AKASH_ACCOUNT_ADDRESS --dseq $AKASH_DSEQ --gseq 1 --oseq 1 --provider $AKASH_PROVIDER --from $AKASH_KEY_NAME --gas-prices="0.025uakt" --gas="auto" --gas-adjustment=1.15 --yes

sleep 30

echo "SENDING THE LEASE"

echo $KEYRING_PASS | akash provider send-manifest deploy.yml --node $AKASH_NODE --dseq $AKASH_DSEQ --from $AKASH_KEY_NAME --provider $AKASH_PROVIDER

echo "GETTING THE PORTS"

sleep 30

echo $KEYRING_PASS | akash provider lease-status --node $AKASH_NODE --home ~/.akash --gseq 1 --oseq 1 --dseq $AKASH_DSEQ --from $AKASH_KEY_NAME --provider $AKASH_PROVIDER

export LEASE_STATUS=$( echo $KEYRING_PASS | akash provider lease-status --node $AKASH_NODE --home ~/.akash --gseq 1 --oseq 1 --dseq $AKASH_DSEQ --from $AKASH_KEY_NAME --provider $AKASH_PROVIDER )

export LEASE_STATUS2=$(echo $LEASE_STATUS | tr -d ' ')

export HOST=$(node getLeaseInfo.js $LEASE_STATUS2 host ip)

export INTERNAL_PORT=$(node getLeaseInfo.js $LEASE_STATUS2 port 9005 )

export EXTERNAL_PORT=$( node getLeaseInfo.js $LEASE_STATUS2 port 9001 )

export PORTTWENTYTWOK=$( node getLeaseInfo.js $LEASE_STATUS2 port 22000 )

echo "$HOST"

echo "$INTERNAL_PORT"

echo "$EXTERNAL_PORT"

echo "$PORTTWENTYTWOK"

ssh-keyscan -p $PORTTWENTYTWOK -H  $HOST >> ~/.ssh/known_hosts

ssh -p $PORTTWENTYTWOK root@$HOST 'bash -t' << EOF 
! /bin/bash
git clone https://github.com/habbmehdi/Coin-App-Template.git
cd Coin-App-Template
echo "Y" | sudo apt-get install jq
sudo jq -n --arg HOST "$HOST" --arg INTERNAL_PORT "$INTERNAL_PORT" --arg EXTERNAL_PORT "$EXTERNAL_PORT" '{ "server": { "p2p": { "existingArchivers": [{"ip": "70.81.221.194","port": 4000,"publicKey": "758b1c119412298802cd28dbfa394cdfeecc4074492d60844cc192d632d84de3"}],"minNodes": 50,"maxNodes": 300,"maxJoinedPerCycle": 50,"maxSyncingPerCycle": 50,"maxRotatedPerCycle": 0, "minNodesToAllowTxs": 10,"amountToGrow": 50},  "ip": {"externalIp": "$HOST","externalPort": $EXTERNAL_PORT,"internalIp": "$HOST","internalPort": $INTERNAL_PORT},"reporting": {"report": true,"recipient": "http://70.81.221.194:3000/api",},"loadDetection": {"queueLimit": 100000,"desiredTxTime": 15,"highThreshold": 0.9,"lowThreshold": 0.2},"rateLimiting": {"limitRate": false},"sharding": {"nodesPerConsensusGroup": 25}}}' > config.json
EOF

ssh -p 31440 root@provider.xeon.computer 'bash -s'<<'EOF' 
! /bin/bash
# source ~/.bash_profile
sudo apt update
echo "Y" | sudo apt install software-properties-common
echo [ENTER] | sudo add-apt-repository ppa:deadsnakes/ppa
echo "Y" | sudo apt install python3.9
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup install stable
rustup default stable
PATH=$HOME/.cargo/bin:$PATH
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.nvm/nvm.sh
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" 
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
nvm install 16.11.1
nvm use 16.11.1 
echo "Y" | sudo apt-get install npm
cd Coin-App-Template
echo [ENTER] | sudo apt install python2.7 make g++
npm config set python python2.7
npm install
npm install pm2@latest -g
pm2 start index.js
EOF

# ssh -p 31332 root@provider.xeon.computer 'bash -s'<<'EOF' 
# cd Coin-App-Template
# npm install pm2@latest -g
# pm2 start index.js
# EOF