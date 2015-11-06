open Core.Std
let printf = Printf.printf

type t = {
    minima : Uint64.t array;
    size : int;
    size_float : float;
    seed1 : int;
    seed2 : int
}

let create size seed1 seed2 =
    {
        minima = Array.create ~len:size Uint64.max_int;
        size = size;
        size_float = Float.of_int size;
        seed1 = seed1;
        seed2 = seed2
    }

let add mh item =
    let v1 = Farmhash.hash64_with_seed item ~seed:mh.seed1 |> Uint64.of_int64 in
    let v2 = Farmhash.hash64_with_seed item ~seed:mh.seed2 |> Uint64.of_int64 in
    for i = 0 to mh.size-1 do
        let hv = Uint64.(add v1 (mul (of_int i) v2)) in
        if (Uint64.compare hv mh.minima.(i)) = -1 then
            mh.minima.(i) <- hv
    done

let merge mh other =
    for i = 0 to mh.size-1 do
        if (Uint64.compare other.minima.(i) mh.minima.(i)) = -1 then
            mh.minima.(i) <- other.minima.(i)
    done

let similarity mh1 mh2 =
    let intersect = Array.fold2_exn mh1.minima mh2.minima ~init:0.0 ~f:(fun acc x y ->
        if (Uint64.compare x y) = 0 then (acc +. 1.0) else acc
    ) in
    intersect /. mh1.size_float

let cardinality mh =
    let hi = Uint64.max_int in
    let denom = Uint64.to_float hi in
    let sum = Array.fold mh.minima ~init:0.0 ~f:(fun acc v ->
        let num = Uint64.to_float (Uint64.sub hi v) in
        let x = (log (num /. denom)) *. -1.0 in
        acc +. x
    ) in
    (*mh.size_float /. sum*)
    (mh.size_float -. 1.0) /. sum
