open Core.Std

type bucket_array = (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array3.t
type t = {
    buckets : bucket_array
    num_buckets : int;
    num_items : int;
}

let get_next_pow2 n =
    let n' = Array.fold [|1; 2; 4; 8; 16; 32|]
        ~init:(n - 1) ~f:(fun acc i -> acc lor (acc asr i))
    in
    n' + 1

let create ?(bucket_size=4) capacity =
    let capacity' = (get_next_pow2 capacity) / bucket_size in
    let ba = Bigarray.Array2.create Bigarray.int8_unsigned Bigarray.c_layout capacity' bucket_size in
    {buckets = ba; num_items = 0}

let insert t data =
    ()


let lookup t data =
    let h = Farmhash.hash64 data in
    let i1 = Int64.rem h t.num_buckets in
    let f = Int64.shift_left h 32 in
