# TzLibre devnet

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

#### 5. Cleanup old data
If you ran a previous version of TzLibre devnet, clean it up:

```
sudo rm -rf ~/.tzlibre-node-devnet ~/.tzlibre-client-devnet ~/.tzlibre-signer-devnet
```

#### 6. Clone repository and run a TzLibre devnet `node`

```
git clone https://github.com/tzlibre/tzlibre.git
cd tzlibre
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

- - -

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
