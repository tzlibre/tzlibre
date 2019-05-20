#!/usr/bin/env bash

if [ ! -f /root/.tezos-node/identity.json ]; then
    echo "Generating identity..."
    /tzlibre/tezos-node identity generate 26
fi

/tzlibre/tezos-node run --net-addr=0.0.0.0:9732 --rpc-addr=0.0.0.0:8732
