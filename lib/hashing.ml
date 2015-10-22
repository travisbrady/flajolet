open Core.Std

external murmurHash3_x86_32: string -> int -> int = "caml_MurmurHash3_x86_32"
external murmurHash3_x86_128: string -> int -> int64 * int64 = "caml_MurmurHash3_x86_128"
external murmurHash3_x64_128: string -> int -> int64 * int64 = "caml_MurmurHash3_x64_128"
external hash_crapwow64: string -> int64 -> int64 = "caml_hash_crapwow64"
external hash_murmur64: string -> int64 -> int64 = "caml_hash_murmur64"
external xxh_256: string -> int64 = "caml_xxh_256"
external test_city: string -> int64 = "test_city"
external hash_fnv32 : string -> int = "caml_hash_fnv32"

open Int64

let hash_long data =
    let m = 0x5bd1e995L in
    let r = 24 in
    let h = 0L in

    let k = (data * m) in
    let k = (shift_right_logical k r |> bit_or k) in
    let h = (bit_or h (k * m)) in

    let k = (shift_right_logical data 32) * m in
    let k = bit_or k (shift_right_logical k r) in
    let h = h * m in
    let h = bit_or h (k * m) in
    let h = bit_or h (shift_right_logical h 13) in
    let h = h * m in
    let h = bit_or h (shift_right_logical h 15) in
    h
