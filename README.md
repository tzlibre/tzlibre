# TzLibre devnet

## Requirements

Minimum: 2GB, 100GB
Recommended: 8GB, 1TB
SSD recommended
No static IP address required

## Run using Docker and docker-compose (beginners)

0. Install Docker. Here are some installation guides:
- [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
- [MacOS](https://docs.docker.com/docker-for-mac/install/)
- [Windows](https://docs.docker.com/docker-for-windows/install/)
- [CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)
- [Debian](https://docs.docker.com/install/linux/docker-ce/debian/)
- [Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/)

1. (Linux users only) Follow [these post-installation steps](https://docs.docker.com/install/linux/linux-postinstall/).

2. [Install docker-compose](https://docs.docker.com/compose/install/).

3. Run a TzLibre devnet node:
```
docker-compose -f composes/docker-compose-devnet.yml up -d
```

## Build from sources (advanced users)
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
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y
```

## How to bake

0. (Docker users only) Attach container:
```
docker exec -it tzlibre_node /bin/bash 
```

1. Create an address:
```
tzlibre-client gen keys my_awesome_baker
```

2. Load at least 1000 devnet TZL from this [faucet](http://faucet.devnet.tzlibre.io) onto your address and register as delegate:
```
tzlibre-client register key "my_awesome_baker" as delegate
```

3. Run the endorser:
```
tzlibre-endorser-003-PsWqDswK run
```

4. Run the baker:
```
tzlibre-baker-003-PsWqDswK run with local node ~/.tezos-node
```
