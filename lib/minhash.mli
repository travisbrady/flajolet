type t

val create : int -> int -> int -> t
(** [create size seed1 seed2] creates a new minhash object *)

val add : t -> string -> unit
(** [add mh some_string] adds the string value to [mh] in place *)

val merge : t -> t -> unit
(** [merge mh1 mh2] merges mh2 into mh1 *)

val similarity : t -> t -> float
(** [similarity mh1 mh2] computes an estimate of the Jaccard coefficient *)

val cardinality : t -> float
(** [cardinality mh] computes an estimate of the cardinality of the set 
 * represented by the minhash [mh] *)

(*
val odd_sketch : t -> int64 -> Bitarray.t 
val odd_card : Bitarray.t -> float
*)
