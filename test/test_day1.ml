open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Day1 = Hardcaml_demo_project.Day1
module Day1_Part2 = Hardcaml_demo_project.Day1_part2
module Harness_Part1 = Cyclesim_harness.Make (Day1.I) (Day1.O)
module Harness_Part2 = Cyclesim_harness.Make (Day1_Part2.I) (Day1_Part2.O)
module Input_Parser = Hardcaml_demo_project.Input_parser

let run_program_part1 (sim : Harness_Part1.Sim.t) file =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  (* reset *)
  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  (* start *)
  inputs.start := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.start := Bits.gnd;

  List.iter (Input_Parser.parse_file file) ~f:(fun { dir; value } ->
    inputs.dir :=
      (match dir with
       | L -> Bits.gnd
       | R -> Bits.vdd);
    inputs.value := Bits.of_int_trunc ~width:10 value;
    Cyclesim.cycle sim;
  );

  Bits.to_int_trunc !(outputs.key)
;;

let run_program_part2 (sim : Harness_Part2.Sim.t) file =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  (* reset *)
  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  (* start *)
  inputs.start := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.start := Bits.gnd;

  List.iter (Input_Parser.parse_file file) ~f:(fun { dir; value } ->
    inputs.dir :=
      (match dir with
       | L -> Bits.gnd
       | R -> Bits.vdd);
    inputs.value := Bits.of_int_trunc ~width:10 value;
    Cyclesim.cycle sim;
  );

  Bits.to_int_trunc !(outputs.key)
;;

let file = "inputs/day1.txt";;

let%expect_test "Day1 Part1 full input" =
  let result =
    Harness_Part1.run_advanced
      ~create:Day1.hierarchical
      (fun sim -> run_program_part1 sim file)
  in
  printf "%d\n" result;
  [%expect {| 0 |}]
;;

let%expect_test "Day1 Part2 full input" =
  let result =
    Harness_Part2.run_advanced
      ~create:Day1_Part2.hierarchical
      (fun sim -> run_program_part2 sim file)
  in
  printf "%d\n" result;
  [%expect {| 0 |}]
;;


