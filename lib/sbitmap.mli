type t
val create: int -> float -> int -> t
val add: t -> string -> unit
val estimate: t -> float
val merge: t -> t -> t option

