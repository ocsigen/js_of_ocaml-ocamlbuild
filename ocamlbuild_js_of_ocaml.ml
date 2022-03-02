(* Js_of_ocaml library
 * http://www.ocsigen.org/js_of_ocaml/
 * Copyright (C) 2013 Jacques-Pascal Deplaix
 * Laboratoire PPS - CNRS Université Paris Diderot
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

open Ocamlbuild_plugin
module Pack = Ocamlbuild_pack

let fold f =
  let l = ref [] in
  (try
     while true do
       match f () with
       | None -> ()
       | Some x -> l := x :: !l
     done
   with _ -> ());
  List.rev !l

let split_comma = Str.split_delim (Str.regexp " *[, ] *")

let fold_pflag scan =
  List.fold_left
    (fun acc x -> try split_comma (scan x (fun x -> x)) @ acc with _ -> acc)
    []

let ocamlfind cmd f =
  let p = Printf.sprintf in
  let cmd = List.map (p "\"%s\"") cmd in
  let cmd = p "ocamlfind query %s" (String.concat " " cmd) in
  Pack.My_unix.run_and_open cmd (fun ic -> fold (fun () -> f ic))

let packages_and_predicates prod =
  let all_pkgs, predicates =
    let tags = Tags.elements (tags_of_pathname prod) in
    let pkgs = fold_pflag (fun x -> Scanf.sscanf x "package(%[^)])") tags in
    let predicates = fold_pflag (fun x -> Scanf.sscanf x "predicate(%[^)])") tags in
    "js_of_ocaml" :: pkgs, predicates
  in
  (* Findlib usually set pkg_* predicate for all selected packages *)
  (* It doesn't do it with 'query' command, we have to it manually. *)
  let cmd = "-format" :: "pkg_%p" :: "-r" :: all_pkgs in
  let predicates_pkgs = ocamlfind cmd (fun ic -> Some (input_line ic)) in
  all_pkgs, predicates @ predicates_pkgs

let old_linkopts prod =
  let all_pkgs, all_predicates = packages_and_predicates prod in
  let predicates = String.concat "," ("javascript" :: all_predicates) in
  (* query findlib for linking option *)
  let cmd = "-o-format" :: "-r" :: "-predicates" :: predicates :: all_pkgs in
  ocamlfind cmd (fun ic ->
      let s = String.trim (input_line ic) in
      if String.length s = 0 then None else Some s)

let runtime_files prod =
  let all_pkgs, all_predicates = packages_and_predicates prod in
  let predicates = String.concat "," all_predicates in
  (* query findlib for jsoo runtime files *)
  let cmd =
    "-format" :: "%+(jsoo_runtime)" :: "-r" :: "-predicates" :: predicates :: all_pkgs
  in
  ocamlfind cmd (fun ic ->
      let s = String.trim (input_line ic) in
      if String.length s = 0 then None else Some s)

let init mode =
  let dep = "%.byte" in
  let prod = "%.js" in
  let f env _ =
    let dep = env dep in
    let prod = env prod in
    let link_opts =
      match mode with
      | `Default -> List.map (fun x -> P x) (runtime_files prod)
      | `Legacy -> List.map (fun x -> A x) (old_linkopts prod)
    in
    let tags = tags_of_pathname prod ++ "js_of_ocaml" in
    Cmd (S [ A "js_of_ocaml"; T tags; S link_opts; A "-o"; Px prod; P dep ])
  in
  rule "js_of_ocaml: .byte -> .js" ~dep ~prod f;
  flag [ "js_of_ocaml"; "debug" ] (S [ A "--pretty"; A "--debug-info"; A "--source-map" ]);
  flag [ "js_of_ocaml"; "pretty" ] (A "--pretty");
  flag [ "js_of_ocaml"; "debuginfo" ] (A "--debug-info");
  flag [ "js_of_ocaml"; "noinline" ] (A "--no-inline");
  flag [ "js_of_ocaml"; "sourcemap" ] (A "--source-map");
  pflag [ "js_of_ocaml" ] "opt" (fun n -> S [ A "--opt"; A n ]);
  pflag [ "js_of_ocaml" ] "set" (fun n -> S [ A "--set"; A n ])

let oasis_support ~executables =
  let aux x = if List.mem x executables then Pathname.update_extension "js" x else x in
  Options.targets := List.map aux !Options.targets

let dispatcher ?(mode = `Default) ?(oasis_executables = []) = function
  | After_rules -> init mode
  | After_options -> oasis_support ~executables:oasis_executables
  | _ -> ()
