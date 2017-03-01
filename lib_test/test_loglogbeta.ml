open Core.Std

let test_zero () =
    let llb = Loglogbeta.create 12 in
    Alcotest.(check bool) "Card should be 0" true ((Loglogbeta.card llb) = 0.0)

let test_loop () =
    let llb = Loglogbeta.create 14 in
    for i = 1 to 1_000 do
        Loglogbeta.add llb (Int.to_string i)
    done;
    let est = Loglogbeta.card llb in
    let err = Float.abs ( est /. 1000.0 -. 1.0) in
    printf "Error: %f Est: %f\n" err est;
    Alcotest.(check bool) "Error should be <= 0.03" true (err <= 0.03)

let test_merge () =
    let llb = Loglogbeta.create 14 in
    let llb2 = Loglogbeta.create 14 in
    Loglogbeta.add llb "test";
    Loglogbeta.add llb "yex";
    Loglogbeta.add llb2 "something else";
    Loglogbeta.add llb2 "and another";
    Loglogbeta.merge_mut llb llb2;
    Alcotest.(check bool) "Should be >= 2" true ((Loglogbeta.card llb) >= 2.0)


let test_set = [
  "test_zero" , `Quick, test_zero;
  "test_loop" , `Quick, test_loop;
  "test_merge" , `Quick, test_merge;
]


let () =
  Alcotest.run "Test Loglogbeta" [
    "test_set", test_set;
  ]
