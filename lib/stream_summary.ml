open Core.Std


module type Key = Hash_heap.Key

module Ss(K: Key) = struct

    module Hh = Hash_heap.Make(K)

    type bucket = {
        count: int;
        error: int
    }

    let flip f x y = f y x
    let snd_cmp x y = compare (snd x).count (snd y).count
    let rev_snd_cmp = flip snd_cmp

    type t = {
        capacity:   int;
        hh:         bucket Hh.t;
    }

    let empty capacity =
        {
            capacity;
            hh = Hh.create (fun a b -> Int.compare a.count b.count)
    }

    let length t = Hh.length t

    let add_or_incr t v w e =
        match Hh.find t.hh v with
        | Some curr_bucket ->
                let upd = {curr_bucket with count = curr_bucket.count + w} in
                Hh.replace t.hh ~key:v ~data:upd;
                ()
        | None ->
                let bucket = {count = w; error = e} in
                let _ = Hh.push t.hh ~key:v ~data:bucket in
                ()

    let offer t v w =
        if (Hh.length t.hh >= t.capacity) && (Hh.mem t.hh v = false) then
            match (Hh.top_with_key t.hh) with
            | Some (prev_min_key, prev_min) ->
                (*printf "prev_min.count: %d\n" prev_min.count;*)
                add_or_incr t v (prev_min.count + w) prev_min.count;
                (*printf "Add: %s Remove %s\n" v prev_min_key;*)
                Hh.remove t.hh prev_min_key
            | None -> ()
        else
            add_or_incr t v w 0

    let top_k t k =
        let lst = ref [] in
        Hh.iter t.hh ~f:(fun ~key ~data ->
            lst := (key, data)::(!lst);
            );
        let sorted = List.sort ~cmp:rev_snd_cmp !lst in
        List.take sorted k

    let peek t = Hh.top t.hh

end

module StringSummary = Ss(String)
module IntSummary = Ss(Int)
