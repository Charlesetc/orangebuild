
build:
	ocamlbuild -use-ocamlfind -pkg unix -pkg extlib src/orangebuild.native

.PHONY: build
