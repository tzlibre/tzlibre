#!/usr/bin/env bash

NODE_UP=$(docker ps | grep tzlibre_node | grep -v Restarting | wc | awk '{print $1}')
if [[ "$NODE_UP" == "1" ]]; then
    echo "Node up               [YES]"
else
    echo "Node up               [NO]"
fi

CURRENT_BLOCK=$(curl -s http://node:8732/monitor/bootstrapped | jq .block)
LIVE_BLOCK=$(curl -s http://rpc.devnet.tzlibre.io/monitor/bootstrapped | jq .block)
if [[ "$CURRENT_BLOCK" == "$LIVE_BLOCK" ]]; then
    echo "Node bootstrapped     [YES]"
else
    echo "Node bootstrapped     [NO]"
fi

CURRENT_CHAIN=$(curl -s http://node:8732/network/version | jq .chain_name)
LIVE_CHAIN=$(curl -s http://rpc.devnet.tzlibre.io/network/version | jq .chain_name)
if [[ "$CURRENT_CHAIN" == "$LIVE_CHAIN" ]]; then
    echo "Latest chain          [YES]"
else
    echo "Latest chain          [NO]"
fi

ENDORSER_UP=$(docker ps | grep tzlibre_endorser | grep -v Restarting | wc | awk '{print $1}')
if [[ "$ENDORSER_UP" == "1" ]]; then
    echo "Endorser up           [YES]"
else
    echo "Endorser up           [NO]"
fi

BAKER_UP=$(docker ps | grep tzlibre_baker | grep -v Restarting | wc | awk '{print $1}')
if [[ "$BAKER_UP" == "1" ]]; then
    echo "Baker up              [YES]"
else
    echo "Baker up              [NO]"
fi

ACCUSER_UP=$(docker ps | grep tzlibre_accuser | grep -v Restarting | wc | awk '{print $1}')
if [[ "$ACCUSER_UP" == "1" ]]; then
    echo "Accuser up            [YES]"
else
    echo "Accuser up            [NO]"
fi
