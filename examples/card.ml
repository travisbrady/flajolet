(*
 * Simple example utility
 * reads strings from stdin and when done prints the count of unique
 * strings stdin to stdout
 * A bit like cat somefile.txt | sort -u | wc -l
 *)
open Core.Std
let printf = Printf.printf

let () =
    let hll = Hyperloglog.create 0.03 in
    In_channel.iter_lines stdin ~f:(fun line ->
        Hyperloglog.offer hll line
    );
    printf "%f\n" (Hyperloglog.card hll)

