open Core.Std
open OUnit2

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


let suite = "Test Bloom" >:::
    ["test_create"           >:: test_create;
     "test_add"              >:: test_add;
     "test_check"            >:: test_check;
     "test_check_not_exists" >:: test_check_not_exists]

let _ =
    run_test_tt_main suite
