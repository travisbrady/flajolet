open Core.Std

type t

val create : int -> t
val count : t -> float
val min : t -> float
val max : t -> float
val offer : t -> float -> t
val quantile : t -> float -> float option
val median : t -> float option
val cdf : t -> float -> float
val mean : t -> float
val weighted_incremental_variance : t -> float
val std : t -> float
