(*
 * A simple utility to compute some basic descriptive from a column
 * of numbers read from stdin
 * The output is similar in spirit to pandas .describe method
 * and R's summary 
 * *)
open Core.Std
let printf = Printf.printf

let show_result hist _count =
    let _min = Histogram.min hist in
    let mean = Histogram.mean hist in
    let std = Histogram.std hist in
    let first_quartile = Histogram.quantile hist 0.25 in
    let median = Histogram.quantile hist 0.5 in
    let third_quartile = Histogram.quantile hist 0.75 in 
    let _max = Histogram.max hist in

    match (first_quartile, median, third_quartile) with
    | (Some fq, Some med, Some tq) ->
            printf "count: %10.2f\n" _count;
            printf "mean : %10.2f\n" mean;
            printf "std  : %10.2f\n" std;
            printf "min  : %10.2f\n" _min;
            printf "25%%  : %10.2f\n" fq;
            printf "50%%  : %10.2f\n" med;
            printf "75%%  : %10.2f\n" tq;
            printf "max  : %10.2f\n" _max
    | _ -> printf "destats error\n"

let () =
    let hist = In_channel.fold_lines stdin ~init:(Histogram.create 1000) ~f:(fun h line ->
        let float_row = Float.of_string line in
        Histogram.offer h float_row
    ) in

    let _count = Histogram.count hist in
    if _count > 0.0 then show_result hist _count
