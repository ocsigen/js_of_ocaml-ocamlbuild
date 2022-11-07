(lang dune 2.9)
(using menhir 2.0)
(name js_of_ocaml-ocamlbuild)

(generate_opam_files true)

(authors "Ocsigen team <dev@ocsigen.org>")
(maintainers "Ocsigen team <dev@ocsigen.org>")
(source (github ocsigen/js_of_ocaml-ocamlbuild))
(homepage "https://github.com/ocsigen/js_of_ocaml-ocamlbuild")
(license "LGPL-2.1-or-later")

(package
 (name js_of_ocaml-ocamlbuild)
 (synopsis "An ocamlbuild plugin to compile to JavaScript using js_of_ocaml")
 (description
  "An ocamlbuild plugin to compile to JavaScript using js_of_ocaml")
 (depends
  (ocaml (>= 4.04))
  ocamlbuild
  (ocamlfind :with-test)
  (js_of_ocaml :with-test)
  (js_of_ocaml-compiler :with-test)
  (base :with-test)
))
