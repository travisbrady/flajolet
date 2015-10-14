open Core.Std

type t = {
    nbins:  int;
    min:    float;
    max:    float;
    bins:   float Float.Map.t;
    total:  float
}

let create nbins =
    {
        nbins;
        min = Float.max_finite_value;
        max = Float.max_finite_value *. -1.0;
        bins = Float.Map.empty;
        total = 0.0
    }

let count t = t.total
let min t = t.min
let max t = t.max

let new_bin t n count =
    let nm = Float.Map.add t.bins ~key:n ~data:count in
    {t with bins = nm; total = t.total +. count}

let offer t n =
    let _min = Float.min t.min n in
    let _max = Float.max t.max n in
    let t = {t with min = _min; max = _max} in
    if Float.Map.length t.bins = 0 then
        new_bin t n 1.0
    else
        match Float.Map.find t.bins n with
        | Some bin ->
            let nm = Float.Map.add t.bins ~key:n ~data:(bin +. 1.0) in
            {t with bins = nm; total = t.total +. 1.0}
        | None ->
            new_bin t n 1.0

let diff lst =
    let rec aux lst acc =
        match lst with
        | [] -> List.rev acc
        | [x] -> List.rev acc
        | x::y::tail -> aux (y::tail) ((y - x)::acc)
    in
    aux lst []

(**
 * TODO skip list-ifying this and add randomization for case when
 * all bins are of equal distance from one another
 *)
let nearest_bins lst =
    let diff = ref Float.max_finite_value in
    let a = ref (Float.max_finite_value *. -1.0) in
    let b = ref (Float.max_finite_value *. -1.0) in
    let rec aux = function
        | [] | [_] -> !diff, !a, !b
        | x::y::tail ->
                let diff' = y -. x in
                if diff' < !diff then begin
                    diff := diff';
                    a := x;
                    b := y
                end;
                aux (y::tail)
    in
    aux lst

let trim t =
    let keys = Float.Map.keys t.bins in
    let (diff, bin_a, bin_b) = nearest_bins keys in
    let count_a = Float.Map.find_exn t.bins bin_a in
    let count_b = Float.Map.find_exn t.bins bin_b in
    let total = count_a +. count_b in
    let v = (bin_a *. count_a +. bin_b *. count_b) /. total in
    let rem_res = Float.Map.remove t.bins bin_a in
    let rem_res' = Float.Map.remove rem_res bin_b in
    let x = {t with bins = rem_res'} in
    new_bin x v total

exception Done_iteration of float

let quantile t q =
    let len = Float.Map.length t.bins in
    if len < 1 then None
    else
        let ct = ref (q *. t.total) in
        try
            Float.Map.iter t.bins ~f:(fun ~key ~data ->
                ct := (!ct -. data);
                if !ct <= 0.0 then raise (Done_iteration key)
            );
            None
        with Done_iteration(v) -> Some(v)

let median t =
    quantile t 0.5

let cdf t x =
    let count = Float.Map.fold_range_inclusive t.bins ~min:(-100.0) ~max:x ~init:0.0 ~f:(fun ~key ~data acc ->
        acc +. data
    ) in
    count /. t.total

let mean t =
    let sum = Float.Map.fold t.bins ~init:0.0 ~f:(fun ~key ~data acc ->
        acc +. (key *. data)
    ) in
    sum /. t.total

type descriptive_stats = {
    mean:       float;
    variance:   float;
    std:        float
}

let describe t =
    let sum,sq_sum = Float.Map.fold t.bins ~init:(0.0, 0.) ~f:(fun ~key ~data (sum,sq_sum) ->
        (sum +. key *. data, sq_sum +. (key *. data) ** 2.0)
    ) in
    let mean = sum /. t.total in
    let variance = sq_sum /. t.total -. mean *. mean in
    (mean, variance, (sqrt variance))
