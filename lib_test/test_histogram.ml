open Core.Std
open OUnit2

let d = List.range 1 10 |> List.map ~f:Float.of_int
let nd = [-10.0; -9.0; -8.0; -7.0; -6.0; -5.0; -4.0; -3.0; -2.0]

let test_zero _ =
    let h = Histogram.create 10 in
    assert_equal None (Histogram.median h)

let test_simple _ =
    let h = List.fold d ~init:(Histogram.create 10) ~f:Histogram.offer in
    assert_equal (Some(5.0)) (Histogram.median h)

let test_percentiles _ =
    let h = List.fold d ~init:(Histogram.create 10) ~f:Histogram.offer in
    assert_equal (Some(9.0)) (Histogram.quantile h 0.9)

let test_merged _ =
    let h = List.fold d ~init:(Histogram.create 5) ~f:Histogram.offer in
    assert_equal (Some(5.0)) (Histogram.median h)

let test_negative _ =
    let h = List.fold nd ~init:(Histogram.create 5) ~f:Histogram.offer in
    assert_equal (Some(-6.0)) (Histogram.median h)

let suite = "Test Histogram" >:::
    ["test_zero"        >:: test_zero;
     "test_percentiles" >:: test_percentiles;
     "test_simple"      >:: test_simple;
     "test_merged"      >:: test_merged;
     "test_negative"    >:: test_negative]

let _ =
    run_test_tt_main suite
