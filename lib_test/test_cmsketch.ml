open Core.Std
open OUnit2
let sprintf = Printf.sprintf
let printf = Printf.printf

let test_add _ =
    let s = "hello" in
    let cms = Cmsketch.add (Cmsketch.create 1_000 4) s in
    let ct = Cmsketch.count cms s in
    assert_equal ct 1

let test_count_not_present _ =
    let cms = Cmsketch.create 5 1_000 in
    assert_equal (Cmsketch.count cms "hello") 0

let test_add_many _ =
    let cms = Cmsketch.create 8 1_000 in
    for i = 0 to 200 do
        let key = sprintf "key_%d" i in
        let cms = Cmsketch.add cms key in
        ()
    done;
    let ret = Cmsketch.count cms "key_0" in
    printf "RET: %d\n" ret;
    assert_equal ret 1

let test_delete _ =
    let cms = Cmsketch.create 5 10_000 in
    let s = "test_this" in
    let cms = Cmsketch.add cms s in
    assert_equal (Cmsketch.count cms s) 1;
    let cms = Cmsketch.delete cms s in
    assert_equal (Cmsketch.count cms s) 0

let test_error_rate _ =
    Random.init 9968;
    let ht = String.Table.create () in
    let cms = Cmsketch.create 10 1_000 in
    for i = 0 to 10_000 do
        let key = sprintf "blah_%d" (Random.int 1_000) in
        let cms = Cmsketch.add cms key in
        String.Table.incr ht key
    done;
    let sum_abs_error = String.Table.fold ht ~init:0.0 ~f:(fun ~key ~data acc ->
        let truth = Float.of_int data in
        let est = Float.of_int (Cmsketch.count cms key) in
        let abs_error = Float.abs (est /. truth -. 1.0) in
        printf "%s abs_error: %f truth: %d est: %.1f\n" key abs_error data est;
        acc +. abs_error
    ) in
    let n = Float.of_int (String.Table.length ht) in
    let mean_absolute_error = sum_abs_error /. n in
    printf "MAE = %f\n" mean_absolute_error;
    assert_bool "test_error_rate" (mean_absolute_error <= 0.05)

let suite = "Test CMSketch" >:::
    [
        "test_add"              >:: test_add;
        "test_count_not_present">:: test_count_not_present;
        "test_add_many"         >:: test_add_many;
        "test_delete"           >:: test_delete;
        "test_error_rate"       >:: test_error_rate
    ]

let _ =
    run_test_tt_main suite
