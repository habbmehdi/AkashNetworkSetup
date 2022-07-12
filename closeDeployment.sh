export AKASH_KEY_NAME=deploy
export AKASH_NET=https://raw.githubusercontent.com/ovrclk/net/master/mainnet
export AKASH_NODE=http://akash.c29r3.xyz:80/rpc 
export AKASH_VERSION=$(curl -s "$AKASH_NET/version.txt")
export AKASH_CHAIN_ID=$(curl -s "$AKASH_NET/chain-id.txt")
export AKASH_NODE=$(curl -s "$AKASH_NET/rpc-nodes.txt" | shuf -n 1)
export AKASH_KEYRING_BACKEND=os
export AKASH_ACCOUNT_ADDRESS=akash1cvp8lcprlwmkg24xk37h2nxh4hqjcsxa2rg9fs
export KEYRING_PASS=Sp24715!

echo $KEYRING_PASS | akash tx deployment close --gas-prices=0.05uakt --gas=auto --gas-adjustment=1.3 --dseq 6651473 --from $AKASH_KEY_NAME --yes 