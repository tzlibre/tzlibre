#! /bin/sh

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
cd "$script_dir"/..

current_hash_alpha=`jq '.hash' < lib_protocol/TEZOS_PROTOCOL | tr -d '"'`
echo "Alpha's current hash: $current_hash_alpha"
alpha_tmpdir=`mktemp -d`
mkdir $alpha_tmpdir/src
cp lib_protocol/*.ml lib_protocol/*.mli $alpha_tmpdir/src/
grep -v '"hash"' < lib_protocol/TEZOS_PROTOCOL > $alpha_tmpdir/src/TEZOS_PROTOCOL
new_hash_alpha=`${HOME}/GIT/tezos/tezos-protocol-compiler -hash-only $alpha_tmpdir/src`
echo "Alpha's new hash: $new_hash_alpha"
