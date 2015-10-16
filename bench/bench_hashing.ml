open Core.Std
open Core_bench.Std

let t_murmurHash3_x86_32 = Bench.Test.create ~name:"murmurHash3_x86_32"
    (fun () -> let _ = Hashing.murmurHash3_x86_32 "dude" 42 in ())

let t_murmurHash3_x86_128 = Bench.Test.create ~name:"murmurHash3_x86_128"
    (fun () -> ignore (Hashing.murmurHash3_x86_128 "dude" 42))

let t_crap = Bench.Test.create ~name:"hash_crapwow64"
    (fun () -> let _ = Hashing.hash_crapwow64 "dude" 42L in ())

let t_murmur = Bench.Test.create ~name:"MurmurHash3_x64_128"
    (fun () -> let _ = Hashing.murmurHash3_x64_128 "dude" 42 in ())

let t_xxhash = Bench.Test.create ~name:"xxh_256"
    (fun () -> let _ = Hashing.xxh_256 "dude" in ())

let tests = [t_murmurHash3_x86_32; t_murmurHash3_x86_128; t_crap; t_murmur; t_xxhash]

let command = Bench.make_command tests

let () = Command.run command
