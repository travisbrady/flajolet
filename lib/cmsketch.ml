open Core.Std
module B=Bigarray
let printf = Printf.printf

type t = {
    depth : int;
    width : int;
    total : int;
    sk : (int, B.int_elt, B.c_layout) B.Array2.t;
}

let create depth width =
    let sk = B.Array2.create B.int B.c_layout depth width in
    B.Array2.fill sk 0;
    {depth; width; sk; total=0}

let hash item width i =
    let h1 = Farmhash.hash item in
    let h2 = Farmhash.hash_with_seed item ~seed:h1 in
    abs ((h1 + i * h2) mod width)

let get_estimates epsilon delta =
    let w = Float.to_int (Float.round_up(2.0 /. epsilon)) in
    let d = (log (1.0 -. delta)) /. (log 0.5) |> Float.round_up |> Float.to_int in
    d, w

let create_with_estimates epsilon delta =
    let d, w = get_estimates epsilon delta in
    create d w

let add t ?(count=1) x =
    for i = 0 to t.depth-1 do
        let loc = hash x t.width i in
        t.sk.{i, loc} <- t.sk.{i, loc} + count
    done;
    {t with sk=t.sk; total = t.total + count}

let count t x =
    let minimum = ref Int.max_value in
    for i = 0 to t.depth-1 do
        let loc = hash x t.width i in
        let v = t.sk.{i, loc} in
        if v < !minimum then begin
            minimum := v;
        end
    done;
    !minimum

let delete t ?(count=1) x =
    for i = 0 to t.depth-1 do
        let loc = hash x t.width i in
        t.sk.{i, loc} <- t.sk.{i, loc} - count
    done;
    {t with sk=t.sk; total = t.total - count}
