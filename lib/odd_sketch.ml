open Core.Std
let printf = Printf.printf

type t = {
    num_bits : int64;
    sketch : Bitarray.t
}

let create num_bits =
    {
        num_bits;
        sketch = Bitarray.create num_bits
    }

let add t item =
    let h = Int64.abs (Int64.rem (Farmhash.hash64 item) t.num_bits) in
    printf "h = %Ld\n%!" h;
    Bitarray.toggle_bit t.sketch h

let count t =
    let pop_count = Float.of_int64 (Bitarray.num_bits_set t.sketch) in
    let nf = Float.of_int64 t.num_bits in
    let numer = log (1.0 -. 2.0 *. pop_count /. nf) in
    let denom = log (1.0 -. 2.0 /. nf) in
    numer /. denom
