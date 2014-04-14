open Core.Std
open Printf
open OUnit2

let seeds = [
    -1618012; 1202261; 4278475; 2451164; 4459047; 5832028; 9080711; 7535596;
    5670520; -819332; 468876; 3324754; 2708466; 2825476; -4295153; 6615075;
    8780111; -9732284; -5222388; 6336841; 1427035; -2636169; 3319563; -8967923;
    7972976; 9470610; 1103673; -6076615; 5467440; 3591610; -6384288; -2918436;
    9945080; -6982071; 3675122; 3561610; 4801648; 5826637; -6465915; -3023256;
    8455145; 9915892; -5079311; 9583019; -6316101; 9835322; 9805962; 7251690;
    -8633247; -8138029; -6438861; -5067646; -3776542; -165383; -287157; -8725182;
    -7923370; 8363439; 2647889; 2604939; -8968504; -5380820; 971101; -1792881;
    1289493; 9753716; 2065509; 355668; -3825598; -9354801; -9050609; -2627436;
    1308810; -7895483; 7295507; 6399303; 4707399; 5177056; 665728; -7069352;
    8385178; -4559890; -8982494; 1474621; -9110282; -5656604; 753978; -7572080;
    -8890745; 3485684; -9604541; 7118201; 4756137; 6119190; -3953187; -763667;
    -8117332; -5552040; -5568932; 8044033] 
    
let mean x =
    let len, sum = List.fold x ~init:(0.0, 0.0) ~f:(fun (len, sum) x -> (len +. 1.0, sum +. x)) in
    sum /. len

let test_create _ =
    let sb = Sbitmap.create 1_000_000 0.03 200 in
    assert_equal 0.0 (Sbitmap.estimate sb)

let test_synthetic _ =
    let err_sum = ref 0.0 in
    List.iter seeds ~f:(fun seed ->
        let sb = Sbitmap.create 1_000_000 0.03 seed in
        let n = 100_000 in
        for i = 0 to n do
            Sbitmap.add sb (Int.to_string i)
        done;
        let card = Sbitmap.estimate sb in
        let err = (card /. (Float.of_int n)) -. 1.0 in
        err_sum := !err_sum +. err;
    );
    let mean_err = !err_sum /. (List.length seeds |> Float.of_int) in
    printf "Mean Error: %f\n" mean_err;
    assert_bool "SBitmap Mean Error" ((Float.abs mean_err) <= 0.03)

let test_midsummer _ =
    let fn = "lib_test/midsummer-nights-dream-gutenberg.txt" in
    let lines = In_channel.read_lines fn in

    let desired_error = 0.015 in
    let errors = List.map seeds ~f:(fun seed ->
        let sb = Sbitmap.create 500_000 desired_error seed in
        List.iter lines ~f:(fun line -> Sbitmap.add sb line);
        let card = Sbitmap.estimate sb in
        let true_set = String.Set.of_list lines in
        let true_card = String.Set.length true_set |> Int.to_float in
        let error = (card /. true_card -. 1.0) in
        (error ** 2.0)
    ) in
    let mse = mean errors in
    assert_bool "midsummer_error" (mse <= desired_error)

let test_merge _ =
    let sb1 = Sbitmap.create 1_000_000 0.03 42 in
    let sb2 = Sbitmap.create 1_000_000 0.03 42 in
    Sbitmap.add sb1 "a";
    Sbitmap.add sb2 "b";
    match Sbitmap.merge sb1 sb2 with
    | Some merged ->
        assert_equal 2 (Sbitmap.estimate merged |> Float.to_int)
    | None -> assert_equal 0.0 1.0

let suite = "Test SBitmap"  >:::
    ["test_midsummer"       >:: test_midsummer;
     "test_synthetic"       >:: test_synthetic;
     "test_merge"           >:: test_merge]

let _ =
    run_test_tt_main suite
