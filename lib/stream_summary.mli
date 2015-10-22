open Core.Std

module type Key = Core.Std.Hash_heap.Key

module Ss : functor (K : Key) -> sig
  type t
  type bucket = { count : int; error : int; }
  (** An empty stream summary *)
  val empty : int -> t

  (** Add an item to a stream summary *)
  val offer : t -> K.t -> int -> unit

  (** Retrieve an ordered list of the most frequently seen items
   * ever added to this stream summary
   *)
  val top_k : t -> int -> (K.t * bucket) list
end
