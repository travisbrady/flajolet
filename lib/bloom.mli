type t
val create : int -> int -> t
val capacity : t -> int
val num_hash_functions : t -> int
val create_with_estimates : int -> float -> t
val add : t -> string -> unit
val test : t -> string -> bool
val test_and_add : t -> string -> bool
val union : t -> t -> t
val intersection : t -> t -> t
