open Core.Std

let _E = exp 1.0

type element = {
    value: string;
    count: int
}

type t = {
    sample_size:        int;
    ssf:                float;
    num_modifications:  int;
    k_map:              element Int64.Map.t;
    seed:               int
}

let empty sample_size seed =
    
    {
        sample_size;
        ssf = Float.of_int sample_size;
        num_modifications = 0;
        k_map = Int64.Map.empty;
        seed
    }

let min_key t =
    match Int64.Map.min_elt t.k_map with
    | Some (x, _) -> x
    | None -> Int64.min_value

let rincr m k s =
    match Int64.Map.find m k with
    | None -> 
            let x = {value=s; count=1} in
            let m = Int64.Map.add m ~key:k ~data:x in
            (m, 1)
    | Some el -> 

            let x = {value=el.value; count = (succ el.count)} in
            let m = Int64.Map.add m ~key:k ~data:x in
            (m, 0)

let offer t el =
    let (h, h2) = Hashing.murmurHash3_x64_128 el t.seed in
    let ms = Int64.Map.length t.k_map in
    let mk = min_key t in
    if h < mk && ms >= t.sample_size then t
    else if h > mk || ms < t.sample_size then begin
        let (k_map', mod_incr) = rincr t.k_map h el in
        (* Trim if needed *)
        let k_map'' = if (Int64.Map.length k_map' > t.sample_size) 
               then Int64.Map.remove k_map' mk 
               else k_map'
        in
        let nm = t.num_modifications + mod_incr in
        {t with k_map = k_map''; num_modifications = nm}
    end 
    else t

let of_list sample_size lst seed =
    let e = empty sample_size seed in
    List.fold lst ~init:e ~f:offer

let est num_mods ss ssf =
    let pow = Float.of_int (num_mods - ss + 1) in
    let a = 1.0 +. 1.0 /. ssf in
    let b = a ** pow in
    let c = ssf *. b in
    c -. 1.0

let estimate_cardinality t =
    let curr_size = Int64.Map.length t.k_map in
    if curr_size < t.sample_size then (Float.of_int curr_size)
    else
        let pow = Float.of_int(t.num_modifications - t.sample_size + 1) in
        (t.ssf *. (1.0 +. (1.0 /. t.ssf)) ** pow) -. 1.0

let estimate_error t =
    let est_card = estimate_cardinality t in
    sqrt(est_card /. (t.ssf *. _E) ** (1.0 /. t.ssf -. 1.0))

