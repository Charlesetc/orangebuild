
test: build
	ocamlbuild -use-ocamlfind test/test_orangebuild.native
	./test_orangebuild.native

build:
	ocamlbuild -use-ocamlfind -pkg unix src/orangebuild.native

.PHONY: build test
