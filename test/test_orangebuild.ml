
exception Assertion_error of string

let assert_true boolean msg = if (not boolean) then raise (Assertion_error msg)

let run command ?redirect arg =
  let redirect = match redirect with 
    | Some s ->  " > " ^ s
    | None -> ""
  in
  match Sys.command @@ command ^ " " ^ arg ^ redirect with
  | 0 -> ()
  | _ -> raise (Assertion_error (arg ^ " failed " ^ command))

let orangebuild = run "./orangebuild.native"
let ocamlc = run "ocamlc"

let()=
  orangebuild "pear" ;

  run "cp" "test/example1.ml _build/example1.ml" ;

  ocamlc "-I _build _build/pear.cmo _build/example1.ml -o _build/example1.byte" ;

  let tempfile = Filename.temp_file "orangebuild_test" ".out" in
  run "./_build/example1.byte" ~redirect:tempfile "" ;
  let input = open_in tempfile in
  let input_string = input_line input in
  close_in input ;

  assert_true (input_string = "2hi there5") "the output of the executable should be waht we expect"
