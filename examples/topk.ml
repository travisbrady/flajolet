(*
 * Reads lines on stdin and then prints the top 5 most common strings
 * to stdout along with their count
 * Similar to:
     * cat somefile.txt | sort | uniq -c | sort -nr
 *)
open Core.Std
let printf = Printf.printf

module String_ss = Stream_summary.Ss(String)

let () =
    let ks = if Array.length Sys.argv > 1 then Sys.argv.(1) else "10" in
    let k = Int.of_string ks in
    let ss = String_ss.empty (k*2) in
    In_channel.iter_lines stdin ~f:(fun line ->
        String_ss.offer ss line 1
    );
    let topk = String_ss.top_k ss k in
    List.iter topk ~f:(fun (key, ct) ->
        printf "%s,%d,%d\n" key ct.String_ss.count ct.String_ss.error
    )
