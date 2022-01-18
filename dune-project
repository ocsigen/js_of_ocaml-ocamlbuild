(lang dune 2.9)
(using menhir 2.0)
(name js_of_ocaml-ocamlbuild)

(generate_opam_files true)

(authors "Ocsigen team <dev@ocsigen.org>")
(maintainers "Ocsigen team <dev@ocsigen.org>")
(source (github ocsigen/js_of_ocaml-ocamlbuild))
(homepage "https://github.com/ocsigen/js_of_ocaml-ocamlbuild")
(documentation "https://github.com/ocsigen/js_of_ocaml-ocamlbuild")
(license "GPL-2.0-or-later AND LGPL-2.1-or-later WITH OCaml-LGPL-linking-exception")

(package
 (name js_of_ocaml-ocamlbuild)
 (synopsis "An ocamlbuild plugin to compile to JavaScript using js_of_ocaml")
 (description
  "An ocamlbuild plugin to compile to JavaScript using js_of_ocaml")
 (depends
  (ocaml (>= 4.04))
  ocamlbuild
))
