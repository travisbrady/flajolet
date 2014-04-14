open Core.Std

module type Key = Core.Std.Hash_heap.Key

module Ss : functor (K : Key) -> sig
  type t
  type bucket = { count : int; error : int; }
  val empty : int -> t
  val offer : t -> K.t -> int -> unit
  val top_k : t -> int -> (K.t * bucket) list
end

