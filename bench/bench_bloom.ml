open Core.Std
open Core_bench.Std

let main () =
    let b = Bloom.create_with_estimates 100_000 0.03 in

    let t_add = Bench.Test.create ~name:"add"
        (fun () -> Bloom.add b "hi") 
    in

    let t_test = Bench.Test.create ~name:"test"
        (fun () -> Bloom.test b "hi")
    in

    let b_1 = Bloom.create_with_estimates 10_000 0.03 in
    let b_2 = Bloom.create_with_estimates 10_000 0.03 in
    Bloom.add b_1 "a";
    Bloom.add b_1 "b";
    Bloom.add b_2 "b";
    Bloom.add b_2 "c";
    let t_union = Bench.Test.create ~name:"union"
        (fun () ->
            let _ = Bloom.union b_1 b_2 in
            ()
        )
    in

    let tests = [t_add; t_test; t_union] in

    let command = Bench.make_command tests in

    Command.run command

let () = main ()
