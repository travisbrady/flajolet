open Core.Std
open OUnit2

let printf = Printf.printf
let fn = "midsummer-nights-dream-gutenberg.txt"

let test_loop _ =
    let lines = In_channel.read_lines fn
        |> List.map ~f:String.lowercase
    in

    let true_set = String.Set.of_list lines in
    let true_card = String.Set.length true_set in

    let sizes = [4; 8; 16; 32; 64; 128; 256; 512; 1024; 2048; 4096] in
    let seeds = [0; 1; 3; 7; 42; 123; 666; 1234] in
    List.iter sizes ~f:(fun size ->
        List.iter seeds ~f:(fun seed ->
            let record = Recordinality.of_list size lines seed in
            let est = Recordinality.estimate_cardinality record in
            let err = (est /. (Float.of_int true_card)) -. 1.0 in
            printf "Size: %d Seed: %d True: %d Est: %f Err: %f\n" size seed true_card est err;
        )
    )

let test_basic _ =
    let r = Recordinality.of_list 512 ["a"; "b"; "c"] 42 in
    let card = Recordinality.estimate_cardinality r in
    printf "Card: %f\n" card;
    assert_equal 3 (Float.to_int card)


let suite = "Test Recordinality" >:::
    ["test_basic" >:: test_basic;
     "test_loop"  >:: test_loop]

let _ =
    run_test_tt_main suite
