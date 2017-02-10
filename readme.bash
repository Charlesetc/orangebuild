# is this a hack?
# yeah maybe
# do I get an accurate line count?
# yes, yes I do
lines=`find src -name '*.ml' | xargs cat | wc -l`
echo '

I desperately wanted to be able to organize my ocaml code into directories which corresponded to modules. :sun: that"'"s exactly what orangebuild does!

... in "$lines" lines of ocaml.

## usage

Right now there"'"s not much to it.

Given a folder mylib with a bunch of files, run:

```
orangebuild mylib
```

This generates a `mylib.cmo`, which you can compile into the rest of your code with:

```
ocamlc mylib.cmo some_actual_ocaml_file.ml -o some_actual_ocaml_file.byte
```

In `some_actual_ocaml_file`, you can access `Mylib` module, and all of the files and
directories contained within. `Mylib.Beach.Salt.Next.print_something ()` is totally
possible with the right directory structure.

If something's not working or you want a feature that's not around, definitely let me know.

## installation

git clone this repository.

```
make # build and test
sudo make install # install it
```

' > readme.md
