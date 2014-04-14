open Core.Std
open Printf

module String_ss = Stream_summary.Ss(String)

let () =
    let ss = String_ss.empty 10 in
    In_channel.iter_lines stdin ~f:(fun line ->
        String_ss.offer ss line 1
    );
    let topk = String_ss.top_k ss 5 in
    List.iter topk ~f:(fun (key, ct) ->
        printf "%s,%d,%d\n" key ct.String_ss.count ct.String_ss.error
    )

