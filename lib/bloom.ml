open Core.Std
module Bitarray = Core_extended.Bitarray
let printf = Printf.printf

let log2 = log 2.0
let log2sq = log2 ** 2.0

type t = {
    m : int;
    k : int;
    b : Bitarray.t
}

let create m k =
    {m=m; k=k; b=Bitarray.create m}

let capacity t = t.m
let num_hash_functions t = t.k

let base_hashes data =
    Array.map ~f:(fun x -> Farmhash.hash_with_seed data ~seed:x) [|0; 1; 2; 3|]

let location t h i =
    let loc = (h.(i mod 2) + i * h.(2 + (((i + (i mod 2)) mod 4)/2))) mod t.m in
    abs loc 

let estimate_parameters n p =
    let nf = Float.of_int n in
    let m = Float.round_up (-1.0 *. nf *. (log p) /. log2sq) in
    let k = Float.round_up (log2 *. m /. nf) in
    m, k

let create_with_estimates n_items false_pos_rate =
    let m, k = estimate_parameters n_items false_pos_rate in
    create (Float.to_int m) (Float.to_int k)

let add t data =
    let h = base_hashes data in
    for i = 0 to t.k-1 do
        let loc = location t h i in
        Bitarray.set t.b loc true
    done

let test t data =
    let h = base_hashes data in
    let rec aux res i =
        if i = t.k then res
        else if not res then res
        else begin
            let loc = location t h i in
            let res = Bitarray.get t.b loc in
            aux res (i + 1)
        end
    in
    aux true 0

let test_and_add t data =
    let h = base_hashes data in
    let rec aux res i =
        if i = t.k then res
        else begin
            let loc = location t h i in
            let res = Bitarray.get t.b loc in
            Bitarray.set t.b loc true;
            aux res (i + 1)
        end
    in
    aux true 0

let union t other =
    let ret = Bitarray.create t.m in
    for i = 0 to t.m-1 do
        let u = (Bitarray.get t.b i) || (Bitarray.get other.b i) in
        Bitarray.set ret i u
    done;
    {t with b = ret}

let intersection t other =
    let ret = Bitarray.create t.m in
    for i = 0 to t.m-1 do
        let u = (Bitarray.get t.b i) && (Bitarray.get other.b i) in
        Bitarray.set ret i u
    done;
    {t with b = ret}
