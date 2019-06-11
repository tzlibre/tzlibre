Brest Amendment
===============

This amendment is a successor of the Athens protocol.

This amendment fixes two issues:

* A security issue. The rehashing performed during Athens protocol
  change was not enough to prevent some kinds of attacks. This
  amendment performs a new rehashing that makes these attacks
  ineffective. The path length of addresses is increased from 7 to 9,
  making the attack 65536 times more difficult.
  See: [commit 2f32cfda8e8a50db2ae05715a4998d44d39c1ad0](https://gitlab.com/tzscan/brest-amendment/commit/2f32cfda8e8a50db2ae05715a4998d44d39c1ad0)

* A tooling issue. The way amendment invoices were done in the Athens
  protocol was difficult to track for external tools, as no balance
  updates were generated for these invoices. As a consequence, a block
  explorer cannot detect the changes, and the changes had to be added
  manually. Here, the changes will be included as balance updates in
  the first block of the new protocol.
  See: [commit 26f45a6ea538202fb41f055546107cb11b8a6a9b](https://gitlab.com/tzscan/brest-amendment/commit/26f45a6ea538202fb41f055546107cb11b8a6a9b)


One roll (8 000 XTZ) is proposed to be sent to TzScan Baker as a
reward for this work.

How to test
------------

* Checkout the repository in the src/ subdirectory of Tezos as
    `proto_005_Brest`:
```
git clone https://gitlab.com/tzscan/brest-amendment src/proto_005_Brest
```
* Apply patch from `scripts/0001-Brest-amendment.patch` to Tezos:
```
patch -p1 < src/proto_005_Brest/scripts/0001-Brest-amendment.patch
```
* Build Tezos
```
make
```
* Run in one terminal:
```
./src/bin_node/tezos-sandboxed-node.sh 1 --connections 0
```
* Run in another terminal:
```
eval `./src/bin_client/tezos-init-sandboxed-client.sh 1`
tezos-activate-alpha
tezos-client bake for bootstrap1
tezos-client bake for bootstrap1
tezos-client bake for bootstrap1
tezos-client rpc get /chains/main/blocks/head
```

How to submit a proposal and vote for it
----------------------------------------

```
./tezos-client submit proposals for <DELEGATE> <PROTOCOL-HASH>
```

Contact
-------

Fabrice LE FESSANT <fabrice@ocamlpro.com>
contact@ocamlpro.com
