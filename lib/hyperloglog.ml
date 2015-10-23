open Core.Std

external clz: int -> int = "caml_clz"
external clzl: int64 -> int = "caml_clzl"

type t = {
    p:      int;
    alpha:  float;
    m:      int;
    mf:     float;
    m64:    int64;
    vec:    int array
}

let log2 x = (log x) /. (log 2.0)

let get_alpha p =
    match p with
    | 4 -> 0.673
    | 5 -> 0.697
    | 6 -> 0.709
    | x when ((x > 6) && (x <= 16)) ->
            let tmp = Float.of_int (1 lsl p) in
            0.7213 /. (1.0 +. 1.079 /. tmp)
    | _ -> 0.0

let get_rho w max_width =
    let lz = clz w in
    lz + 1

let create error_rate =
    let p = log2 ((1.04 /. error_rate) ** 2.0)
        |> Float.round_up
        |> Float.to_int
    in
    let alpha = get_alpha p in
    let m = 1 lsl p in
    let vec = Array.create ~len:m 0 in
    {
        p;
        alpha;
        m;
        mf = (Float.of_int m);
        m64 = (Int64.of_int m);
        vec
    }

let offer t item =
    let x = Farmhash.hash64_with_seed item ~seed:42 in
    let j64 = Int64.(bit_and x (t.m64 - 1L)) in
    let j = Int64.to_int j64 |> Option.value ~default:0 in
    let w = Int64.shift_right_logical x t.p |> Int64.to_int |> Option.value ~default:0 in
    let rho = get_rho w (64 - t.p) in
    let mx = max t.vec.(j) rho in
    t.vec.(j) <- mx

let get_nearest_neighbors big_e estimate_vector =
    let dist_map = Array.mapi (fun i x -> ((big_e -. x ** 2.0), i)) estimate_vector in
    Array.sort dist_map ~cmp:(fun x y -> compare (fst x) (fst y));
    Array.slice dist_map 0 6

let estimate_bias big_e p =
    let bias_vector = Const.bias_data.(p - 4) in
    let est_vector = Const.raw_estimate_data.(p - 4) in
    let neighbors = get_nearest_neighbors big_e est_vector in
    let num = Array.fold neighbors ~init:0.0 ~f:(fun acc (_, idx) ->
        acc +. bias_vector.(idx)
    ) in
    let denom = Array.length neighbors |> Float.of_int in
    num /. denom

let ep t =
    let s = Array.fold t.vec ~init:0.0 ~f:(fun a b -> a +. (2.0 ** (-1.0 *.  (Float.of_int b)))) in
    let big_e = t.alpha *. (t.mf ** 2.0) /. s in
    let bias_est = estimate_bias big_e t.p in
    let ret = if (big_e <= (5.0 *. t.mf)) then (big_e -. bias_est) else big_e in
    ret

let card t =
    let v = Array.count t.vec (fun x -> x = 0) in
    if v > 0 then begin
        let h = t.mf *. (log (t.mf /. (Float.of_int v))) in
        let threshold = Const.thresholdData.(t.p - 4) in
        let ret = if (h <= threshold) then h else (ep t) in
        ret
    end
    else ep t

let merge t1 t2 =
    if t1.m <> t2.m then None
    else
        let merged = Array.map2_exn t1.vec t2.vec ~f:max in
        Some ({t1 with vec = merged})

