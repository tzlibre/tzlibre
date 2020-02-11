# TzLibre Betanet will launch on Feb 25 2020

[Get ready 🚀](https://docs.betanet.tzlibre.io)

# TzLibre alphanet

## TOC
- [1. 📖  Requirements](#1--requirements)
- [2. 🐳  Run with Docker](#2--run-with-docker)
- [3. 🥖  How to bake](#3--how-to-bake)
- [4. ✅  Check status](#4--check-status)
- [5. 🔑  How to manage keys/accounts](#5--how-to-manage-keysaccounts)
- [6. 🙋  FAQ](#6--faq)
- [7. ⚠️   Troubleshooting](#7-%EF%B8%8F-troubleshooting)
- [8. 🛠️   Build from sources](#8--build-from-sources-advanced-users)

## 1. 📖 Requirements
- Minimum: 2GB RAM, 100GB storage
- Recommended: 8GB RAM, 1TB storage
- SSD recommended

## 2. 🐳 Run with Docker
### Install Docker and docker-compose

1. **Install Docker.** Here are some installation guides: 
   - [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
   - [CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)
   - [Debian](https://docs.docker.com/install/linux/docker-ce/debian/)
   - [Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/)

2. **Post install.** Follow [these post-install steps](https://docs.docker.com/install/linux/linux-postinstall/)

3. **Install docker-compose.** [Install docker-compose](https://docs.docker.com/compose/install/)

4. **Update Docker images.** Force a Docker images update to the latest available version: `docker pull tzlibre/tzlibre:betanet` (_Note_: you can issue this command from anywhere, _e.g._, your home directory `~/`) 

| 🚨 WARNING: If you never installed a TzLibre betanet node before skip step 5 |
| :--- |

5. **Cleanup previous installs.** 
	- Move into the `tzlibre` repository folder with `cd tzlibre`. (_Note_: if you cloned the repository into a different or nested folder, make sure to `cd` into that very folder.) 
	- Stop and remove any previously running TzLibre container with: `docker rm -f $(docker ps -a -q -f name=tzlibre)`. 
	- Cleanup old data from disk with: `docker system prune` (_Note_: your private keys are safely stored and encrypted in a separate docker volume. They will no be deleted)

6. **Clone (or update) repository.** 
	- If you never cloned the repository before, clone it with: `git clone -b betanet https://github.com/tzlibre/tzlibre.git`. 
	- Move inside the repository with: `cd tzlibre`. If you are moving from the **devnet** branch you must checkout the betanet branch from within the `tzlibre` repository folder with: `git fetch` and `git checkout betanet`
	- Update it with: `git pull origin betanet`

7. **Run TzLibre betanet.** 
	- Use the command `docker-compose -f composes/docker-compose-betanet.yml up -d node && docker-compose -f composes/docker-compose-betanet.yml logs -f node`. (_Note_: this may take a while). 
	- To detach from `node` logs hit `Ctrl-c`: `node` will continue to run in background


### Interact with TzLibre `node` via Docker

> All the commands in this section **MUST** be run from inside the repository folder. Move into the `tzlibre` repository folder with `cd tzlibre`. (_Note_: if you cloned the repository into a different or nested folder, make sure to `cd` into that very folder).

- Stop `node`: `docker-compose -f composes/docker-compose-betanet.yml stop node`

- Restart `node`: `docker-compose -f composes/docker-compose-betanet.yml restart node`

- Attach to `node` logs: `docker-compose -f composes/docker-compose-betanet.yml logs -f node` (_Note_: to detach from `node` logs hit `Ctrl-c`: `node` will continue to run in background)


## 3. 🥖 How to bake

You need an account funded with at least 1,000 TZL (1 roll). To import an existing `secret_key` or generate a new one, refer to section [Keys/accounts management](#--how-to-manage-keysaccounts).

### Setup 

Bootstrap bakers included in genesis **MUST NOT** register as delegate (step 2 "Register as delegate").


0. **Attach to the container.** (_Docker users only_) 
   - All commands in the following sections (_i.e., _1. Get a funded address_ and 2. Register as delegate_) should be launched inside the Docker container. To attach to the container run `docker exec -it tzlibre_node /bin/bash`. 
	- Check you are inside the container before issuing the following commands (if your shell prompt looks like `root@d9349d4e7123` you're inside the container)

1. **Wait for bootstrap.** 
   - Wait until your node has bootstrapped (connection and synch). Depending on bandwidth and chain size it may take anything between 30 minutes and few hours
   - [Check status](#4--check-status). Make sure your node has bootstrapped before moving to the next step

| 🚨 WARNING: Bootstrap bakers included in genesis **MUST NOT** register as delegate. If you are a bootstrap baker **SKIP** step 2 and move to step 3. |
| :--- |

2. **Register as delegate.** 
   - Run the command `tzlibre-client register key "my_awesome_baker" as delegate`. (_Note_: if node hasn't bootstrapped you might get [this error](#e2-node-is-bootstrapped-ready-for-injecting-operations-error-empty-implicit-contract))

3. **Detach from the container.** (_Docker users only_)
   - Exit `tzlibre_node` container with `Ctrl-d`. (_Note_: check your shell prompt has returned to your default one)


### Run `baker`, `endorser` and (optional) `accuser`

> All commands in this section **MUST** be run from within the repository folder. Move into `tzlibre` repository folder with `cd tzlibre`. (_Note_: if you cloned the repository into a different or nested folder, make sure to `cd` into that very folder)

- Start `baker`: `docker-compose -f composes/docker-compose-betanet.yml up -d baker && docker attach tzlibre_baker`. Insert your password and hit Enter. Wait for string "`Baker started.`" and detach from container with `Ctrl-p` + `Ctrl-q`

- Start `endorser`: `docker-compose -f composes/docker-compose-betanet.yml up -d endorser && docker attach tzlibre_endorser`. Insert your password and hit Enter. Wait for string "`Endorser started.`" and detach container with `Ctrl-p` + `Ctrl-q`

- (Optional) Start `accuser`: `docker-compose -f composes/docker-compose-betanet.yml up -d accuser && docker attach tzlibre_accuser`. Wait for string "`Accuser started.`" and detach container with `Ctrl-p` + `Ctrl-q`.


### Interact with  `baker`, `endorser` and `accuser`

- Stop `baker`, `endorser` or `accuser` `docker-compose -f composes/docker-compose-betanet.yml stop <baker,endorser,accuser>` (_Note_: customize this using either one or more in `<baker,endorser,accuser>`)

- Restart `baker`: `docker-compose -f composes/docker-compose-betanet.yml restart baker && docker attach tzlibre_baker`. It will ask for encryption password of "my_awesome_baker" key. Type it and press Enter. Then wait for string "`Baker started.`" and detach with `Ctrl-p` + `Ctrl-q`

- Restart `endorser`: `docker-compose -f composes/docker-compose-betanet.yml restart endorser && docker attach tzlibre_endorser`. It will ask for encryption password of "my_awesome_baker" key. Type it and press Enter. Then wait for string "`Endorser started.`" and detach with `Ctrl-p` + `Ctrl-q`

- Restart `accuser`: `docker-compose -f composes/docker-compose-betanet.yml restart accuser`

- Attach to logs: `docker-compose -f composes/docker-compose-betanet.yml logs -f <baker,endorser,accuser>` (_Note_: customize this using one or more in `<baker,endorser,accuser>`)

- Detach from logs: you can detach [`baker`|`endorser`|`accuser`] with `Ctrl-c` in each terminal session

## 4. ✅ Check status

> The command shown in this section **MUST** be run from inside the repository folder. Move into `tzlibre` repository folder with `cd tzlibre`. (_Note_: if you cloned the repository into a different or nested folder, make sure to `cd` into that very folder).

- Check network and node status (software version, latest chain, chain mode, and more): `./composes/scripts/status.sh`

## 5. 🔑 How to manage keys/accounts

An account is controlled by `secret_key`: `public_key` is uniquely derived from `secret_key`, an address (_e.g._, `tz1...`, also known as "public key hash") is a hash of `public_key`. 

> All procedures explained in this section **MUST** be run from inside a `tzlibre_node` container. If you need to run a series of procedures you won't need to detach from the `tzlibre_node` container (always reported as the last command) and reattach to it.

### Import an existing secret key

Following these steps you'll be able to import a `secret_key` from Librebox to `tzlibre-client`:

1. **Export unencrypted key from LibreBox.**
   - go to Settings→Export Private Key. It will show an unencrypted private key (`edsk...`)

2. **Prepare the prefixed private key string.** 
   - Open a text editor, paste the `edsk...` string and prepend it with the string `unencrypted:`
   - You must end up with a string like: `unencrypted:edsk...`
   - Copy this string to the clipboard

3. **Attach to `tzlibre_node` container.**
   - Attach to a running `tzlibre_node` container: `docker exec -it tzlibre_node /bin/bash`

4. **Encrypt the unencrypted private key.**
   - Use the command `tzlibre-client encrypt secret key`. 
   - Paste clipboard content to answer the request  "Enter unencrypted secret key:" and hit Enter. 
   - Type your encryption password (twice). 
   - You will obtain an encrypted private key of the form: `encrypted:edesk...` 
   - (_Note_: if you run this multiple times you will get different outputs while the unencrypted key stays the same)

6. **Import secret key.**
   - Choose an alias for your key (_e.g._, `my_awesome_encrypted_key`)
   - Import the encrypted secret key with: `tzlibre-client import secret key my_awesome_encrypted_key encrypted:edsk...`
   - Type your encryption password when requested
   - (_Note_: you must replace `my_awesome_encrypted_key` with the alias chosen)

7. Detach from `tzlibre_node` container with `Ctrl-d`


### Generate a new secret key

1. Attach to a running `tzlibre_node` container: `docker exec -it tzlibre_node /bin/bash`

2. Choose an alias for your key (_e.g._, `my_awesome_key`), then run `tzlibre-client gen keys my_awesome_key`. Type your encryption password (twice)

3. Detach from `tzlibre_node` container with `Ctrl-d`


### Retrieve known addresses and aliases

1. Attach to a running `tzlibre_node` container: `docker exec -it tzlibre_node /bin/bash`

2. Retrieve list of known addresses with: `tzlibre-client list known addresses`

3. Pick the address associated with your alias

4. Detach from `tzlibre_node` container with `Ctrl-d`


### Check address balance

> Alternatively you can use the [block explorer](https://explorer.tzlibre.io/)

1. Attach to a running `tzlibre_node` container: `docker exec -it tzlibre_node /bin/bash`

2. Retrieve balance with: `tzlibre-client get balance for <my_address>`. (_Note_: you must replace `<my_address>` with the alias of your address. To list known address aliases check this: [Retrieve known addresses and aliases](#retrieve-known-addresses-and-aliases))

3. Detach from the `tzlibre_node` container with `Ctrl-d`. 


## 6. 🙋 FAQ
### Q1. How long is a cycle?
A cycle is composed by 4096 blocks and lasts slightly less than 3 days.

### Q2. When will I be able to bake my first block?
7 cycles after you register as delegate you will become an active delegate. From that point on your chances to bake a block are proportional to your stake.
	
### Q3. What rewards should I expect?
- bake:  `16 / halving_factor` TZL
- endorse: `2 / halving_factor` TZL
- seed nonce revelation: `0.125 / halving_factor` TZL

### Q4. How is halving computed?
Halving factor depends on the halving period. 
Halving period is incremented each 256 cycles (~2 years). 
Halving factor is then computed as `2 ^ halving_period`.

### Q5. How do I find out when's my turn to bake?
Choose a `block_number` and call: `http://rpc.tzlibre.io/chains/main/blocks/head/helpers/baking_rights?level=<block_number>`.

### Q6. Where are my private keys?
Your keys are strored in: `~/.tzlibre-client-betanet`.

### Q7. How long does it take to bootstrap?
Depending on your connection and on chain length it can take anything between 30 minutes and a few hours.

## 7. ⚠️ Troubleshooting
### E1. Fatal error: Resource temporarily unavailable
Sync incomplete, please wait.

### E2. Node is bootstrapped, ready for injecting operations. Error: Empty implicit contract 
Incomplete bootstrap, wait for a complete bootstrap.

### E3. Failed to acquire the protocol version from the node
Make sure you're using encrypted keys.

### E4. Level previously baked
This is caused by an incorrect halt of the baker. Please reinstall.

### E5. Too few connections
Wait for your node to find more connections. If that doesn't work
[check status](#4--check-status)

### E6. Couldn't connect to Docker daemon
You probably didn't install Docker properly. Reinstall Docker from scratch following the official guide, then [test your installation](https://docs.docker.com/samples/library/hello-world/)

### E7. "tzlibre-client get balance for" does not exist
If you are using Docker, check to be attached to a `tzlibre-node` container (step "0. Attach to the container." of [Setup](#setup)) and verify that your alias actually exists (`tzlibre-client list known addresses`)

--- 
```
```
---

## 8. 🛠 Build from sources (advanced users)
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
	
