
build:
	ocamlbuild -use-ocamlfind -pkg unix src/orangebuild.native

.PHONY: build
