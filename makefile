
test: readme build
	ocamlbuild -use-ocamlfind test/test_orangebuild.native
	./test_orangebuild.native

build:
	ocamlbuild -use-ocamlfind -pkg unix src/orangebuild.native

install: build
	cp ./orangebuild.native /usr/local/bin/orangebuild
	chmod +x /usr/local/bin/orangebuild

readme:
	bash readme.bash

.PHONY: build test
