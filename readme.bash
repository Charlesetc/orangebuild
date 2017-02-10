# is this a hack?
# yeah maybe
# do I get an accurate line count?
# yes, yes I do
lines=`find src -name '*.ml' | xargs cat | wc -l`
echo '

I desperately wanted to be able to organize my ocaml code into directories which corresponded to modules. So that"'"s exactly what orangebuild does!

... in "$lines" lines of ocaml.

## usage

Right now there"'"s not much to it.

Given a folder `library` with a bunch of files, run:

```
orangebuild library
```

This generates a `library.cmo`, which you can compile into the rest of your code with:

```
ocamlc library.cmo some_actual_ocaml_file.ml -o some_actual_ocaml_file.byte
```

In `some_actual_ocaml_file`, you can access `Mylib` module, and all of the files and
directories contained within. `Mylib.Beach.Salt.Next.print_something ()` is totally
possible with the right directory structure.

If something's not working or you want a feature that's not around, definitely let me know.

## limitations

A file only has access to modules that are its siblings or in a folder
that"s a sibling to it or farther down. You won"t be able to do things
like have a top level `utils/` directory or have recursive modules (which
you can"t do anyways in ocaml). Basically, you"re got to keep the
layout a real tree.

Also, there is no way to add functions that are first-hand to a module.
By this, I mean if I have "apple.ml" in "grape/" directory, you can access
"Grape.Apple", but there"s no way to put a function at "Grape.myfunction
()". I"m ok with this for now, but there is a way to add this feature if anyone
really wants it. For now you can just make a module `Grape.Core` or `Grape.Main` or something similar.

Lastly! There's no support yet for ocamlopt. It's easy if anyone wants it.

## installation

git clone this repository.

```
make # build and test
sudo make install # install it
```

' > readme.md
