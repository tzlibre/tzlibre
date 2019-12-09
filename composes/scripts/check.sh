#!/usr/bin/env bash

LOCAL_COMMIT=$(git --git-dir .git rev-parse --verify master)
REMOTE_COMMIT=$(git ls-remote https://github.com/tzlibre/tzlibre.git master | awk '{print $1}')
if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
    echo "Git repo latest version   [YES]"
else
    echo "Git repo latest version   [NO]"
fi

CHAIN_IS_LIVE=$(curl -L --max-time 30 -s https://api-explorer.tzlibre.io/explorer/status | jq -r '.status')
if [[ "$CHAIN_IS_LIVE" == "synced" ]]; then
    echo "TzLibre betanet is up     [YES]"
else
    echo "TzLibre betanet is up     [NO]"
fi

NODE_UP=$(docker ps | grep tzlibre_node | grep -v Restarting | wc | awk '{print $1}')
if [[ "$NODE_UP" == "1" ]]; then
    echo "Local node is up          [YES]"
else
    echo "Local node is up          [NO]"
fi

CURRENT_BLOCK=$(curl -L --max-time 5 -s http://node:8732/monitor/bootstrapped | jq .block 2> /dev/null)
LIVE_BLOCK=$(curl -L --max-time 5 -s http://rpc.tzlibre.io/monitor/bootstrapped | jq .block 2> /dev/null)
if [[ "$CURRENT_BLOCK" == "$LIVE_BLOCK" ]]; then
    echo "Local node bootstrapped   [YES]"
else
    echo "Local node bootstrapped   [NO]"
fi

CURRENT_CHAIN=$(curl -L --max-time 5 -s http://node:8732/network/version | jq .chain_name 2> /dev/null)
LIVE_CHAIN=$(curl -L --max-time 5 -s http://rpc.tzlibre.io/network/version | jq .chain_name 2> /dev/null)
if [[ "$CURRENT_CHAIN" == "$LIVE_CHAIN" ]]; then
    echo "Latest chain              [YES]"
else
    echo "Latest chain              [NO]"
fi

ENDORSER_UP=$(docker ps | grep tzlibre_endorser | grep -v Restarting | wc | awk '{print $1}')
if [[ "$ENDORSER_UP" == "1" ]]; then
    echo "Endorser up               [YES]"
else
    echo "Endorser up               [NO]"
fi

BAKER_UP=$(docker ps | grep tzlibre_baker | grep -v Restarting | wc | awk '{print $1}')
if [[ "$BAKER_UP" == "1" ]]; then
    echo "Baker up                  [YES]"
else
    echo "Baker up                  [NO]"
fi

ACCUSER_UP=$(docker ps | grep tzlibre_accuser | grep -v Restarting | wc | awk '{print $1}')
if [[ "$ACCUSER_UP" == "1" ]]; then
    echo "Accuser up                [YES]"
else
    echo "Accuser up                [NO]"
fi

if test -f ~/.tzlibre-client/public_keys; then
    echo "Address created           [YES]"
else
    echo "Address created           [NO]"
fi
