all:
	dune build @all

tests:
	dune runtest

promote:
	dune promote

fmt:
	dune build @fmt --auto-promote 2> /dev/null || true
	git diff --exit-code

clean:
	dune clean

.PHONY: all tests promote fmt clean
