open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock  : 'a
    ; clear  : 'a
    ; start  : 'a
    ; finish : 'a
    ; dir    : 'a (*dir = 0 is forward, dir = 1 is backward*)
    ; value  : 'a [@bits 10]
    }
  [@@deriving sexp_of, hardcaml]
end

module O = struct
  type 'a t =
    { key : 'a [@bits 13] }
  [@@deriving sexp_of, hardcaml]
end

module States = struct
  type t =
    | Idle
    | Running
  [@@deriving sexp_of, compare ~localize, enumerate]
end

let create scope ({ clock; clear; start; finish; dir; value } : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in

  let sm = State_machine.create (module States) spec in

  let%hw_var loc = Variable.reg spec ~width:8 in
  let%hw_var key = Variable.reg spec ~width:13 in

  (* ---------- helpers ---------- *)

  let const_100 = Signal.of_int_trunc ~width:8 100 in
  let const_50  = Signal.of_int_trunc ~width:8 50 in
  let one_13    = Signal.of_int_trunc ~width:13 1 in

  let effective_value = Signal.wire 10 in

  let () = Signal.assign effective_value
    (
       List.init 10 ~f:(fun i -> (i + 1) * 100)
      |> List.fold ~init:value ~f:(fun acc threshold ->
          mux2 (value >: Signal.of_int_trunc ~width:10 threshold) 
                (value -: Signal.of_int_trunc ~width:10 threshold) 
                acc)
    )
  in

  let effective_value_8 = Signal.wire 8 in
  let () = Signal.assign effective_value_8 (Signal.uresize effective_value ~width:8) in

  (* forward movement *)

  let forward_next = Signal.wire 8 in
  let () = Signal.assign forward_next
    (
    mux2 ((loc.value +: effective_value_8) >=: const_100) ((loc.value +: effective_value_8) -: const_100) (loc.value +: effective_value_8)
    )
  in

  (* backward movement *)

  let backward_next = Signal.wire 8 in
  let () = Signal.assign backward_next
    (
    mux2 (loc.value >=: effective_value_8) (loc.value -: effective_value_8) (const_100 -: (effective_value_8 -: loc.value))
    )
  in

  let next_loc = Signal.wire 8 in
  let () = Signal.assign next_loc
    (
    mux2 dir backward_next forward_next
    )
  in

  compile
    [ sm.switch
        [ ( Idle
          , [ when_ start
                [ loc <-- const_50
                ; key <-- zero 13
                ; sm.set_next Running
                ]
            ] )

        ; ( Running
          , [ (* update location *)
              loc <-- next_loc

            ; (* increment key if wrapped to zero *)
              when_ (next_loc ==: Signal.of_int_trunc ~width:8 0)
              [ key <-- key.value +: one_13 ]

            ; when_ finish
                [ sm.set_next Idle ]
            ] )
        ]
    ];

  { key = key.value }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"day1" create
;;