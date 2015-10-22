type t

(** Create a new bloom filter with given size and number of hash functions *)
val create : int -> int -> t

(** Create a new bloom filter with estimates of number of expected items and
 * desired false positive rate *)
val create_with_estimates : int -> float -> t

(** Retrieve bloom filter capacity *)
val capacity : t -> int

(** Retrieve number of hash functions used by this bloom filter *)
val num_hash_functions : t -> int

(** Add an item to this bloom filter *)
val add : t -> string -> unit

(** Check to see if bloom filter may contain some item *)
val test : t -> string -> bool

(** Add an item to this bloom filter and return whether it was already present *)
val test_and_add : t -> string -> bool

(** Return new bloom filter containing all items from both inputs *)
val union : t -> t -> t

(** Return new bloom filter containing items present in both input bloom filters *)
val intersection : t -> t -> t
