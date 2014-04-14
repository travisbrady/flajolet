open Core.Std
open Printf
open OUnit

let test_create _ =
    let hll = Hyperloglog.create 0.05 in
    let hll2 = Hyperloglog.create 0.05 in
    assert_equal hll hll2

let test_zero _ =
    let hll = Hyperloglog.create 0.03 in
    assert_equal 0.0 (Hyperloglog.card hll)

let test_loop _ =
    let hll = Hyperloglog.create 0.03 in
    for i = 1 to 1_000 do
        Hyperloglog.offer hll (Int.to_string i)
    done;
    let est = Hyperloglog.card hll in
    let err = Float.abs ( est /. 1000.0 -. 1.0) in
    printf "Error: %f Est: %f\n" err est;
    assert_bool "test_loop" (err <= 0.03)

let test_merge _ =
    let h1 = Hyperloglog.create 0.05 in
    let h2 = Hyperloglog.create 0.05 in
    Hyperloglog.offer h1 "hello";
    Hyperloglog.offer h1 "hi";
    Hyperloglog.offer h2 "hi";
    Hyperloglog.offer h2 "bye";
    match Hyperloglog.merge h1 h2 with
    | Some m ->
        let mc = Hyperloglog.card m in
        assert_bool "test_merge" ((Float.to_int mc) = 3)
    | None -> assert_bool "hll_merge_failure" false

let suite = "Test HLL" >:::
    ["test_create"  >:: test_create;
     "test_zero"    >:: test_zero;
     "test_loop"    >:: test_loop;
     "test_merge"   >:: test_merge]

let _ =
    run_test_tt_main suite

