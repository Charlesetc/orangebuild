
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

(* get the last part of a path without the extension *)
let safe_chop f =
  let f = Filename.basename f in
  try
    Filename.chop_extension f
  with Invalid_argument _ -> f

(* define a function that will execute a command and raise an exception *)

exception Execution_error of string

let execute_command command =
  match (Unix.system command) with
  | Unix.WEXITED 0 -> ()
  | _ -> raise (Execution_error command)

(* determine which compiler and which options to use *)
let prefix = ""
let prefix = "echo "
let ocamlc command = execute_command @@ prefix ^ "ocamlc " ^ command
let cd path = execute_command @@ prefix ^ "cd " ^ path

let starting_dir = Sys.getcwd ()

let cd_back () =  cd starting_dir

(* make a function that will copy
 * the directory structure and files into the _build directory *)

let rec write_build_directory dir =
  execute_command @@ "mkdir -p _build/" ^ dir#name ;
  List.iter (fun x ->
    execute_command @@ "cp " ^ x ^ " _build/" ^ x 
  ) dir#files ;
  List.iter write_build_directory dir#children

(* define a function for building a library from a file *)

let compile_library (name : string) =
  cd ("_build/" ^ Filename.dirname name) ;
  ocamlc @@
    " -a " ^ Filename.basename name ^
    " -o " ^ safe_chop name ^ ".cma" ;
  cd_back ()

(* define a function for building a library from a directory *)

let compile_directory ~dependencies ~module_file =
  cd ("_build/" ^ Filename.dirname module_file) ;

  let cma_file = safe_chop module_file ^ ".cma" in

  let target_cma_file = Filename.basename (Filename.dirname module_file ^ ".cma") in

  ocamlc @@
    " -a " ^
    String.concat " " dependencies ^ " " ^
    Filename.basename module_file ^
    " -o " ^ safe_chop module_file ^ ".cma" ;

  execute_command @@ prefix ^ "cp " ^ cma_file ^ " ../" ^ target_cma_file ;
  cd_back ()

(* define a function for building an executable *)

(* 

  define a class that represents directories
  files should be strings within the directory

*)

let orangebuild_temp directory = 
  directory#name ^ "/orangebuild_temp_file_avoid.ml"

class directory
        name
        (files : string list)
        (children : directory list)
      = object (self)

  val dependencies = 
    (children |> List.map (fun x -> x#name)) @ files
  val children = children
  val files = files
  val name = name

  method name = name
  method files = files
  method children = children

  method print () =
    print_string ">> " ;
    print_endline name ;
    String.concat " " files |> print_endline ;
    List.iter (fun x -> x#print ()) children

  (* define a representation of a relative module structure *)

  method structure : string = 
    dependencies
    |> List.map Filename.basename
    |> List.map safe_chop
    |> List.map String.capitalize
    |> List.map
      (fun x -> "module " ^ x ^ " = " ^ x)
    |> String.concat "\n"

  method compile_children () =
    List.iter (fun x -> x#compile ()) children ;
    List.iter compile_library files

  (* actually compile each library *)

  method compile () =

    self#compile_children () ;

    let dependencies = List.map
      (fun child -> safe_chop child ^ ".cma" )
      dependencies
    in

    let module_file = orangebuild_temp self in

    ExtLib.output_file
      ~filename:("_build/" ^ module_file)
      ~text:self#structure ;

    compile_directory
      ~dependencies
      ~module_file;

    (* Sys.remove module_file *)

end

(* construct a representation of the required directory structure *)
let rec read_in_directory (name : string) : directory =
  let everything : string list = Sys.readdir name
    |> Array.to_list
    |> List.map (Filename.concat name)
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
  new directory name files children

(* define a representation of an absolute module structure
   for each directory, it will have to ignore itself and it's
   children *)

(* start all the processes that need to happen: *)
let()=
  let project = read_in_directory first_argument in
  write_build_directory project ;
  project#compile ()
