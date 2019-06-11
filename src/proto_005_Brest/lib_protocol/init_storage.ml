(*****************************************************************************)
(*                                                                           *)
(* Open Source License                                                       *)
(* Copyright (c) 2018 Dynamic Ledger Solutions, Inc. <contact@tezos.com>     *)
(*                                                                           *)
(* Permission is hereby granted, free of charge, to any person obtaining a   *)
(* copy of this software and associated documentation files (the "Software"),*)
(* to deal in the Software without restriction, including without limitation *)
(* the rights to use, copy, modify, merge, publish, distribute, sublicense,  *)
(* and/or sell copies of the Software, and to permit persons to whom the     *)
(* Software is furnished to do so, subject to the following conditions:      *)
(*                                                                           *)
(* The above copyright notice and this permission notice shall be included   *)
(* in all copies or substantial portions of the Software.                    *)
(*                                                                           *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*)
(* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  *)
(* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL   *)
(* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*)
(* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING   *)
(* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER       *)
(* DEALINGS IN THE SOFTWARE.                                                 *)
(*                                                                           *)
(*****************************************************************************)

let implicit_contract_of_pkh pkh =
  Contract_repr.implicit_contract
    (Signature.Public_key_hash.of_b58check_exn pkh)

(* Credit some xtz on a dst from an optional src (to avoid inflation).
   Don't forget to update balance_updates for block explorers ! *)
let invoice ctxt ?src ~dst amount balance_updates =
  let amount = Tez_repr.of_mutez_exn (Int64.(mul 1_000_000L (of_int amount))) in

  begin
    match src with
    | None -> return (ctxt, balance_updates)
    | Some src ->
        let src = implicit_contract_of_pkh src in
        Contract_storage.spend_from_script ctxt src amount >>=
        begin function
          | Error _ -> return (ctxt, balance_updates)
          | Ok ctxt ->
              let balance_updates = [
                Delegate_storage.Contract src, Delegate_storage.Debited amount ;
              ] @ balance_updates in
              return (ctxt, balance_updates)
        end
  end >>=? fun (ctxt, balance_updates) ->
  let dst = implicit_contract_of_pkh dst in
  Contract_storage.credit ctxt dst amount >>=? fun ctxt ->
  let balance_updates = [
    Delegate_storage.Contract dst, Delegate_storage.Credited amount
  ] @ balance_updates in
  return (ctxt, balance_updates)

let prepare_first_block ctxt ~typecheck ~level ~timestamp ~fitness =
  Raw_context.prepare_first_block
    ~level ~timestamp ~fitness ctxt >>=? fun (previous_protocol, ctxt) ->
  match previous_protocol with
  | Genesis param ->
      Commitment_storage.init ctxt param.commitments >>=? fun ctxt ->
      Roll_storage.init ctxt >>=? fun ctxt ->
      Seed_storage.init ctxt >>=? fun ctxt ->
      Contract_storage.init ctxt >>=? fun ctxt ->
      Bootstrap_storage.init ctxt
        ~typecheck
        ?ramp_up_cycles:param.security_deposit_ramp_up_cycles
        ?no_reward_cycles:param.no_reward_cycles
        param.bootstrap_accounts
        param.bootstrap_contracts >>=? fun ctxt ->
      Roll_storage.init_first_cycles ctxt >>=? fun ctxt ->
      Vote_storage.init ctxt >>=? fun ctxt ->
      Storage.Last_block_priority.init ctxt 0 >>=? fun ctxt ->
      Vote_storage.freeze_listings ctxt >>=? fun ctxt ->
      Storage.Pending_protocol_init.init ctxt 0 >>=? fun ctxt ->
      return ctxt
  | Athens_004 ->
      Contract_storage.reindex_contract ctxt >>=? fun ctxt ->
      Storage.Pending_protocol_init.init ctxt 1 >>=? fun ctxt ->
      return ctxt

(* Since prepare_first_block is executed at the end of the last block
  of the previous protocol, we cannot correctly set the balance updates.
  So, we postpone the actions to the first block of the current protocol,
   using a value Pending_protocol_init in the context.
*)
let finish_prepare_first_block ctxt =
  let balance_updates = [] in
  Storage.Pending_protocol_init.get ctxt >>=? fun has_init ->
  if Compare.Int.equal has_init 1 then
    Storage.Pending_protocol_init.set ctxt 0 >>=? fun ctxt ->
    invoice ctxt
      "tz1LWub69XbTxdatJnBkm7caDQoybSgW4T3s" (* TzScan Baker *)
      8_000                                  (* one more roll ! *)
      balance_updates >>=? fun (ctxt, balance_updates) ->
    return (ctxt, balance_updates)
  else
    return (ctxt, balance_updates)

let prepare ctxt ~level ~timestamp ~fitness =
  Raw_context.prepare ~level ~timestamp ~fitness ctxt
