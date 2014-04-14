open Core.Std
open Printf

let test_stdin () =
    let sb = Sbitmap.create 1_000_000 0.03 42 in
    let lines = In_channel.input_lines stdin in
    let words = List.concat_map lines ~f:(fun x -> String.split x ~on:' ') in
    List.iter words ~f:(fun x -> Sbitmap.add sb x);

    let card = Sbitmap.estimate sb in

    let true_set = String.Set.of_list words in
    let true_card = String.Set.length true_set |> Int.to_float in
    printf "CardEst: %f TrueCard: %f Error: %f\n" card true_card (card /. true_card -. 1.0)

let () =
    test_stdin ()
