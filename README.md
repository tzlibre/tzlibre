# TzLibre devnet

## TOC
- [Requirements](#requirements)
- [Run with Docker](#install-docker-and-docker-compose)
- [How to bake](#how-to-bake)
- [Check your install](#check-your-install)
- [Check network status](#check-network-status)
- [Faucet](#faucet)
- [FAQ on current devnet parametrization](#faq)
- [Build from sources](#build-from-sources-advanced-users)

## Requirements
- Minimum: 2GB RAM, 100GB storage
- Recommended: 8GB RAM, 1TB storage
- SSD recommended
- No static IP address required

## Run with Docker
### Install Docker and docker-compose

#### 1. Install Docker
Here are some installation guides:
- [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
- [MacOS](https://docs.docker.com/docker-for-mac/install/)
- [Windows](https://docs.docker.com/docker-for-windows/install/)
- [CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)
- [Debian](https://docs.docker.com/install/linux/docker-ce/debian/)
- [Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/)

#### 2. (Linux users only) Follow [these post-install steps](https://docs.docker.com/install/linux/linux-postinstall/).

#### 3. [Install docker-compose](https://docs.docker.com/compose/install/).

#### 4. Update Docker images
Force a Docker images update to the latest available version:

```
docker pull tzlibre/tzlibre
docker pull tzlibre/tzlibre:devnet
```

#### 5. Cleanup previous installs
If you never installed a TzLibre devnet node: skip this section.

##### 5.0 Move into `tzlibre` repository folder

```
cd tzlibre
```

> If you cloned the repository into a different or nested folder, make sure to `cd` into that very folder. 

##### 5.1 Stop any previously running Docker container

```
docker-compose -f composes/docker-compose-devnet.yml stop
```

##### 5.2 Destroy any previous Docker container

```
docker-compose -f composes/docker-compose-devnet.yml rm
```

##### 5.3 Cleanup old data from disk

```
sudo rm -rf ~/.tzlibre-node-devnet ~/.tzlibre-client-devnet ~/.tzlibre-signer-devnet
```

> This is a mandatory step. 
> Old keys will be destroyed (you'll be able to get up to 10M TZL devnet coins for each faucet request).

#### 6. Clone (or update) repository and run a TzLibre devnet `node`
Clone or update the repository. 

If you never cloned the repository before, clone it:

```
git clone https://github.com/tzlibre/tzlibre.git
cd tzlibre
```

Otherwise, if you previously cloned the repository, update it:

```
cd tzlibre
git pull origin devnet
```

Then run the node:

```
docker-compose -f composes/docker-compose-devnet.yml up -d node && docker-compose -f composes/docker-compose-devnet.yml logs -f node
```

> (this may take a while)

> To detach from `node` logs hit `Ctrl-c`: `node` will continue to run in background.


### Interact with TzLibre `node` via Docker

#### Stop `node`

```
docker-compose -f composes/docker-compose-devnet.yml stop node
```

### Restart `node`

```
docker-compose -f composes/docker-compose-devnet.yml restart node
```

### Attach to `node` logs

```
docker-compose -f composes/docker-compose-devnet.yml logs -f node
```

## How to bake

### Setup 

#### (Docker users only) Attach to the container
All commands in the following sections (_i.e., _1. Get a funded address_ and 2. Register as delegate_) should be issued inside the Docker container. To attach to the container run:

```
docker exec -it tzlibre_node /bin/bash 
```

> Check you are inside the container before issuing the following commands (if your shell prompt looks like `root@d9349d4e7123` you're inside the container).

#### 1. Get a funded address

##### 1.1. Generate address
Choose an alias for your address (eg `my_awesome_baker`), then run:

```
tzlibre-client -A none gen keys my_awesome_baker
```

> Ignore the warning ("Failed to acquire the protocol version from the node"). We are currently using unencrypted keys, encrypted keys will be introduced in a later release.

##### 1.2 Retrieve address
```
tzlibre-client list known addresses
```

> Pick the address associated with your alias.

##### 1.3. Fund address
Fund your address with at least 10,000 devnet  coins. Get free devnet coins from this [faucet](http://faucet.devnet.tzlibre.io). 

##### 1.5. Check your balance
Use the [block explorer](http://librexplorer.devnet.tzlibre.io/) or the command line:

```
tzlibre-client get balance for my_awesome_baker
```

#### 2. Register as delegate
```
tzlibre-client register key "my_awesome_baker" as delegate
```

> `tzlibre-client` will wait for node bootstrap (synch and connection) before issuing the related transaction (this may take a while).

### Conclusion
Detach `node` container (Docker users only). Exit container with `Ctrl-d`. 

> Check your shell prompt has returned to your default one.

### Run `baker`, `endorser` and (optional) `accuser`

#### Start `baker`

```
docker-compose -f composes/docker-compose-devnet.yml up -d baker && docker-compose -f composes/docker-compose-devnet.yml logs -f baker
```

#### Start `endorser`

```
docker-compose -f composes/docker-compose-devnet.yml up -d endorser && docker-compose -f composes/docker-compose-devnet.yml logs -f endorser
```

#### (Optional) Start `accuser`

```
docker-compose -f composes/docker-compose-devnet.yml up -d accuser && docker-compose -f composes/docker-compose-devnet.yml logs -f accuser
```

### Interact with  `baker`, `endorser` and `accuser`

#### Detach from logs

You can detach [`baker`|`endorser`|`accuser`] with `Ctrl-c` in each terminal session.

#### Stop, restart

> Customize this using either `<stop|restart>` and one or more in `<baker,endorser,accuser>`.

```
docker-compose -f composes/docker-compose-devnet.yml <stop|restart> <baker,endorser,accuser>
```

#### Attach to logs

> Customize this using one or more in `<baker,endorser,accuser>`.

```
docker-compose -f composes/docker-compose-devnet.yml logs -f <baker,endorser,accuser>
```


## Check your install
Check if you are correctly running the latest version of the software, and that you are actually connected to the latest chain:

```
cd tzlibre
docker-compose -f composes/docker-compose-devnet.yml up status
```

## Check network status

Devnet is a development network, it's regularly restarted and can be put in maintenance mode. 
Check [here](http://status.devnet.tzlibre.io) the current status of the network.


## Faucet
Get TZL devnet coins at the [Faucet](http://faucet.devnet.tzlibre.io). 
For each request the faucet delivers from 1M TZL up to 10M TZL.


## FAQ
### Q1. How long is a cycle?
A cycle is composed by 128 blocks and lasts about 1 hour.

### Q2. When will I be able to bake my first block?
After 7 cycles, almost 8 hours.

### Q3. What rewards should I expect?
- bake:  `16 / halving_factor` TZL
- endorse: `2 / halving_factor` TZL
- seed nonce revelation: `0.125 / halving_factor` TZL

### Q4. How is halving computed?
Halving factor depends on the halving period. 
Halving period is incremented each 32 cycles (~ 35 hours). 
Halving factor is then computed as `2 ^ halving_period`.

### Q5. How do I find out when's my turn to bake?
Choose a `block_number` and call:

```
http://rpc.devnet.tzlibre.io/chains/main/blocks/head/helpers/baking_rights?level=<block_number>
```


### Q6. Where are my private key?
Your keys are here: `~/.tzlibre-node-client-devnet`

--- 
```
```
---



## Build from sources (advanced users)
If you prefer to build the TzLibre node from source follow these steps:

```
sudo apt install -y rsync git m4 build-essential patch unzip bubblewrap wget
wget https://github.com/ocaml/opam/releases/download/2.0.1/opam-2.0.1-x86_64-linux
sudo cp opam-2.0.1-x86_64-linux /usr/local/bin/opam
sudo chmod a+x /usr/local/bin/opam
git clone https://github.com/tzlibre/tzlibre
cd tzlibre
opam init --bare
make build-deps
eval $(opam env)
make
export PATH=~/tzlibre:$PATH
source ./src/bin_client/bash-completion.sh
export TZLIBRE_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y
```
