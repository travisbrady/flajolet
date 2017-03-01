external uclzl: Uint64.uint64 -> int = "caml_clzl"

let printf = Printf.printf

type t = {
    registers: (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t;
    m: int;
    mf: float;
    precision: int;
    alpha: float
}

let alpha m =
    match m with
    | 16 -> 0.673
    | 32 -> 0.697
    | 64 -> 0.709
    | _ -> 0.7213 /. (1.0 +. 1.079 /. (float_of_int m))

let create precision =
    let m = 1 lsl precision in
    let registers = Bigarray.Array1.create Bigarray.Int8_unsigned Bigarray.c_layout m in
    Bigarray.Array1.fill registers 0;
    {
        m = m;
        mf = float_of_int m;
        precision = precision;
        registers = registers;
        alpha = (alpha m)
    }

let add llb value =
    let x = Uint64.of_int64 (Farmhash.hash64_with_seed value ~seed:1337) in
    let _max = 64 - llb.precision in
    let yo = Uint64.shift_left x llb.precision in
    let _val = (uclzl yo) + 1 in
    printf  "_val = %d\n" _val;
    let k = Uint64.to_int (Uint64.shift_right x _max) in
    printf "k = %d regk = %d\n" k llb.registers.{k};
    if llb.registers.{k} < _val then begin
        printf "ADD _val %d\n" _val;
        llb.registers.{k} <- _val
    end

let beta ez =
    let zl = log (ez +. 1.0) in
    let ret = -0.370393911 *. ez +.
        0.070471823 *. zl +.
        0.17393686 *. (zl ** 2.0) +.
        0.16339839 *. (zl ** 3.0) +.
        -0.09237745 *. (zl ** 4.0) +.
        0.03738027 *. (zl ** 5.0) +.
        -0.005384159 *. (zl ** 6.0) +.
        0.00042419 *. (zl ** 7.0) in
    ret

let card llb =
    let sum = ref 0.0 in
    let num_zeros = ref 0 in
    for i = 0 to llb.m-1 do
        if llb.registers.{i} = 0 then incr num_zeros;
        let _val = float_of_int llb.registers.{i} in
        sum := !sum +. (1.0 /. (2.0 ** _val));
    done;
    let ez = float_of_int !num_zeros in
    let _beta = beta ez in
    let ret = (llb.alpha *. llb.mf *. (llb.mf -. ez) /. (_beta +. !sum)) in
    printf "ez = %f beta = %f sum = %f ret = %f\n" ez _beta !sum ret;
    ret

let merge_mut llb other =
    for i=0 to llb.m-1 do
        if llb.registers.{i} < other.registers.{i} then
            llb.registers.{i} <- other.registers.{i}
    done;
