#load "str.cma"

let old_num = "004"
let old_name = "Pt24m4xi"

let replacements = [
  Str.regexp (old_num ^ "-" ^ old_name),  "005-Brest";
  Str.regexp (old_num ^ "_" ^ old_name),  "005_Brest";
]

let read_file filename =
  let s = Bytes.create 65_000 in
  let b = Buffer.create 1000 in
  let rec iter ic b s =
    let nread = input ic s 0 65_000 in
    if nread > 0 then begin
      Buffer.add_subbytes b s 0 nread;
      iter ic b s
    end
  in
  let ic = open_in_bin filename in
  iter ic b s;
  close_in ic;
  Buffer.contents b

let replace s =
  List.fold_left (fun filename (regexp, repl) ->
      Str.global_replace regexp repl filename
    ) s replacements

let rec iter dir =
  let files = try Sys.readdir dir with _ -> [||] in
  Array.iter (fun file ->
      let filename = Filename.concat dir file in
      iter filename;
      let filename2 = replace filename in
      let filename =
        if filename <> filename2 then begin
          Printf.eprintf "mv %s %s\n%!" filename filename2;
          Sys.rename filename filename2;
          filename2
        end
        else filename
      in
      let content = try read_file filename with _ -> "" in
      let content2 = replace content in
      if content <> content2 then begin
        Printf.eprintf "modify %s\n%!" filename;
        let oc = open_out_bin filename in
        output_string oc content2;
        close_out oc
      end
    ) files
;;

iter ".";;
