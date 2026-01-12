open! Core
open! Hardcaml
open! Hardcaml_demo_project

let generate_day1_rtl () =
  let module C = Circuit.With_interface (Day1.I) (Day1.O) in
  let scope = Scope.create ~auto_label_hierarchical_ports:true () in
  let circuit = C.create_exn ~name:"day1_top" (Day1.hierarchical scope) in
  let rtl_circuits =
    Rtl.create ~database:(Scope.circuit_database scope) Verilog [ circuit ]
  in
  let rtl = Rtl.full_hierarchy rtl_circuits |> Rope.to_string in
  print_endline rtl
;;

let day1_rtl_command =
  Command.basic
    ~summary:""
    [%map_open.Command
      let () = return () in
      fun () -> generate_day1_rtl ()]
;;

let () =
  Command_unix.run
    (Command.group ~summary:"" [ "day1", day1_rtl_command ])
;;

let generate_day1_part2_rtl () =
  let module C = Circuit.With_interface (Day1_part2.I) (Day1_part2.O) in
  let scope = Scope.create ~auto_label_hierarchical_ports:true () in
  let circuit = C.create_exn ~name:"day1_part2_top" (Day1_part2.hierarchical scope) in
  let rtl_circuits =
    Rtl.create ~database:(Scope.circuit_database scope) Verilog [ circuit ]
  in
  let rtl = Rtl.full_hierarchy rtl_circuits |> Rope.to_string in
  print_endline rtl
;;

let day1_part2_rtl_command =
  Command.basic
    ~summary:""
    [%map_open.Command
      let () = return () in
      fun () -> generate_day1_part2_rtl ()]
;;

let () =
  Command_unix.run
    (Command.group ~summary:"" [ "day1-part2", day1_part2_rtl_command ])
;;


