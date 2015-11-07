open Core.Std
open OUnit2
let sprintf = Printf.sprintf
let printf = Printf.printf

let test_add _ =
    let mh = Minhash.create 100 2983 7 in
    Minhash.add mh "__test__";
    let card = Minhash.cardinality mh in
    let diff = Float.abs (1.0 -. card) in
    printf "Card: %f Diff: %f\n" card diff;
    assert_bool "test_add" (diff < 0.05)

let test_count_not_present _ =
    let mh = Minhash.create 100 4555 42 in
    assert_equal (Minhash.cardinality mh) 0.0

let test_similarity _ =
    let mh1 = Minhash.create 100 97098 669 in
    let mh2 = Minhash.create 100 97098 669 in
    List.iter ["bob"; "sally"; "juanita"; "rudy"] ~f:(fun x -> Minhash.add mh1 x);
    List.iter ["tom"; "megan"; "juanita"; "rudy"] ~f:(fun x -> Minhash.add mh2 x);
    let j = Minhash.similarity mh1 mh2 in
    let expected = 2.0 /. 6.0 in
    let diff = Float.abs (expected -. j) in
    assert_bool "test_similarity" (diff < 0.05)

let test_merge _ =
    let mh1 = Minhash.create 100 97098 669 in
    let mh2 = Minhash.create 100 97098 669 in
    List.iter ["bob"; "sally"; "juanita"; "rudy"] ~f:(fun x -> Minhash.add mh1 x);
    List.iter ["tom"; "megan"; "juanita"; "rudy"] ~f:(fun x -> Minhash.add mh2 x);
    Minhash.merge mh1 mh2;
    let expected = 6.0 in
    let pct_diff = (Float.abs (expected -. (Minhash.cardinality mh1))) /. expected in
    assert_bool "test_merge" (pct_diff < 0.05)

let suite = "Test Minhash" >:::
    [
        "test_add"              >:: test_add;
        "test_count_not_present">:: test_count_not_present;
        "test_similarity"       >:: test_similarity;
        "test_merge"            >:: test_merge;
    ]

let _ =
    run_test_tt_main suite
