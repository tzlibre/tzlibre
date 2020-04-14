# TzLibre betanet

- [TzLibre](https://tzlibre.io)
- [Explorer](https://explorer.betanet.tzlibre.io)
- [Documentation](https://docs.betanet.tzlibre.io)
- [Buy delegations](https://pod.tzlibre.io)

## 🛠 Build from sources

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
	
