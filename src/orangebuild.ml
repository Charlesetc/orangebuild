
(* orangebuild:
   ocaml projects so easy it's like peeling an orange
   which itself is particularily easy to peel
*)

(*
  Outline:

    Jamboree constructs and links together modules for your code.
    It's based on directory structure, so you don't have to worry.
    
    Take this structure:

      /apple
        orange.ml
        /orange
          safari.ml
        /pear
          chrome.ml

    In this case, you coud access functions like so:

      Apple.main ()
      Apple.Orange.main ()
      Apple.Orange.Safari.main()
      Apple.Pear.Chrome.main ()
        
    It should be pretty intuitive.

    The motivation for this is that I was finding it
    hard to structure and compile my ocaml code without
    directory and file structure, and I didn't want to
    deal with the compiler on a very low level. All that
    is involved is `orangebuild apple` and you get `apple`
    built.

*)

(* get the first argument passed orangebuild *)

let first_argument : string = try
  Array.get Sys.argv 1
with Invalid_argument _ ->
  prerr_endline "usage: orangebuild [project]"; exit 0


(* define a function that will execute a command and raise an exception *)

exception Execution_error of string

let execute_command command =
  match (Sys.command command) with
  | 0 -> ()
  | _ -> raise (Execution_error command)

let ocamlc command = execute_command @@ "ocamlc " ^ command

(* make a function that will copy
 * the directory structure and files into the _build directory *)

let rec write_build_directory dir =
  execute_command @@ "mkdir -p _build/" ^ dir#path ;
  List.iter (fun x ->
    execute_command @@ "cp " ^ x ^ " _build/" ^ x 
  ) dir#files ;
  List.iter write_build_directory dir#children

(* define a function for building a library from a file *)

let compile_library (path : string) =
  ocamlc @@
    " -c _build/" ^ path ^
    " -o _build/" ^ Filename.chop_extension path ^ ".cmo"

let compile_directory ~dependencies ~path =
  ocamlc @@
    " -I _build/" ^ path ^
    " -pack " ^ String.concat " " dependencies ^
    " -o _build/" ^ path ^ ".cmo"


(* define a function for building the executable *)

(* let compile executable ~dependencies ~path = *)
(*   ocamlc @@ *)
(*     String.concat " " dependencies ^ " " ^ *)
(*     path ^ *)
(*     " -o " ^ Filename.chop_extension path ^ ".byte" *)

(* 

  define a class that represents directories
  files should be strings within the directory

*)

class directory
        path
        (files : string list)
        (children : directory list)
      = object (self)

  val dependencies = 
    (children |> List.map (fun x -> x#path)) @ files
  val children = children
  val files = files
  val path = path

  method path = path
  method files = files
  method children = children

  method print () =
    print_string ">> " ;
    print_endline path ;
    String.concat " " files |> print_endline ;
    List.iter (fun x -> x#print ()) children

  (* define a representation of a relative module structure *)

(*   method structure : string = *) 
(*     files *)
(*     |> List.map Filename.basename *)
(*     |> List.map Filename.chop_extension *)
(*     |> List.map String.capitalize *)
(*     |> List.map *)
(*       (fun x -> "module " ^ x ^ " = " ^ x) *)
(*     |> String.concat "\n" *)

  method compile_children () =
    List.iter (fun x -> x#compile ()) children ;
    List.iter compile_library files

  (* actually compile each library *)

  method compile () =

    self#compile_children () ;

    let dependencies =
      List.map
        (fun file -> "_build/" ^ Filename.chop_extension file ^ ".cmo")
        files 
      @ List.map
        (fun child -> "_build/" ^ child#path ^ ".cmo")
        children
    in

    compile_directory
      ~dependencies
      ~path

    (* Sys.remove module_file *)

end

(* construct a representation of the required directory structure *)
let rec read_in_directory (path : string) : directory =
  let everything : string list = Sys.readdir path
    |> Array.to_list
    |> List.map (Filename.concat path)
    (* ignore hidden files and folders *)
    |> List.filter (fun x -> String.get (Filename.basename x) 0 != '.')
  in
  let files = everything
    |> List.filter
      (fun x -> try Sys.is_directory x |> not
                with Sys_error _ -> false)
    (* only consider ocaml files *)
    |> List.filter (fun x -> Filename.check_suffix x ".ml")
  in
  let children = everything
    |> List.filter Sys.is_directory
    |> List.map read_in_directory
  in
  new directory path files children

(* define a representation of an absolute module structure
   for each directory, it will have to ignore itself and it's
   children *)

(* start all the processes that need to happen: *)
let()=
  let project = read_in_directory first_argument in
  write_build_directory project ;
  project#compile ()
