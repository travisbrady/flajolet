open Core.Std
open Printf

let () =
    let hll = Hyperloglog.create 0.03 in
    In_channel.iter_lines stdin ~f:(fun line ->
        Hyperloglog.offer hll line
    );
    printf "%f\n" (Hyperloglog.card hll)

