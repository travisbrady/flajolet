type t
(** Create a new hyperloglog structure with the specified error rate *)
val create: float -> t

(** Add an item to an existing hyperloglog *)
val offer: t -> string -> unit

(** Estimate the count of items ever added to this hyperloglog *)
val card: t -> float

(** Return a new hyperloglog representing the union of the two inputs *)
val merge: t -> t -> t option
