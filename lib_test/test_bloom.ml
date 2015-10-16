open Core.Std
open OUnit2
let sprintf = Printf.sprintf

let test_create _ =
    let b = Bloom.create 100 6 in
    assert_equal (Bloom.capacity b) 100

let test_add _ =
    let b = Bloom.create_with_estimates 1_000 0.03 in
    let ret = Bloom.add b "test" in
    assert_equal ret ()

let test_check _ =
    let b = Bloom.create_with_estimates 1_000 0.03 in
    Bloom.add b "hello";
    assert_equal (Bloom.test b "hello") true

let test_check_not_exists _ =
    let b = Bloom.create_with_estimates 1_000 0.03 in
    assert_equal (Bloom.test b "hello") false

let test_check_and_add _ =
    let b = Bloom.create_with_estimates 1_000 0.03 in
    assert_equal (Bloom.test_and_add b "hi") false;
    assert_equal (Bloom.test_and_add b "hi") true

let test_union _ =
    let b1 = Bloom.create_with_estimates 1_000 0.01 in
    let b2 = Bloom.create_with_estimates 1_000 0.01 in
    Bloom.add b1 "b1";
    Bloom.add b2 "b2";
    let b_union = Bloom.union b1 b2 in
    assert_equal (Bloom.test b_union "b1") true;
    assert_equal (Bloom.test b_union "b2") true

let test_intersection _ =
    let b1 = Bloom.create_with_estimates 1_000 0.001 in
    let b2 = Bloom.create_with_estimates 1_000 0.001 in
    Bloom.add b1 "b1";
    Bloom.add b1 "common";
    Bloom.add b2 "b2";
    Bloom.add b2 "common";
    let b_inter = Bloom.intersection b1 b2 in
    assert_equal (Bloom.test b_inter "common") true;
    assert_equal (Bloom.test b_inter "b1") false;
    assert_equal (Bloom.test b_inter "b2") false

let test_add_many _ =
    let b = Bloom.create_with_estimates 100_000 0.01 in
    for i = 0 to 5_000 do
        Bloom.add b (sprintf "key_%d" i)
    done;
    assert_equal (Bloom.test b "not_in_there") false

let suite = "Test Bloom" >:::
    [
        "test_create"           >:: test_create;
        "test_add"              >:: test_add;
        "test_check"            >:: test_check;
        "test_check_not_exists" >:: test_check_not_exists;
        "test_check_and_add"    >:: test_check_and_add;
        "test_union"            >:: test_union;
        "test_intersection"     >:: test_intersection;
        "test_add_many"         >:: test_add_many
    ]

let _ =
    run_test_tt_main suite
