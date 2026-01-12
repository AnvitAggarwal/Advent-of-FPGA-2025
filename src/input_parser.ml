open! Core
open! Hardcaml
open! Signal
type dir = L | R
type inst = 
  { dir : dir  (* dir = 0 is right, dir = 1 is left *)
  ; value : int
  }

let parse_line (input : string) =
  let dir =
    match input.[0] with 
    | 'L' -> L
    | 'R' -> R
    | _ -> failwith "Invalid direction character"
  in
  let value = 
    let number_str = String.sub input ~pos:1 ~len:(String.length input - 1) in
    Int.of_string number_str
  in
  {dir; value}

  let parse_file (filename : string) =
    In_channel.read_lines filename
    |> List.map ~f:parse_line
