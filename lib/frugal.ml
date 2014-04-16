open Printf

type t = {
    m: int;
    q: float;
    step: int;
    sign: int;
    f: (int -> int)
}

let create ?(f = fun _ -> 1) m q =
    {m = m; q = q; step = 1; sign = 0; f = f}

let add t item =
    let rando = Random.float 1.0 in
    printf "Rando: %f\n" rando;
    if item > t.m && rando > (1.0 -. t.q) then begin
        let step' = t.step + t.f(t.step) * (if t.sign > 0 then 1 else -1) in
        printf "Step': %d Sign: %d\n" step' t.sign;

        let m' = t.m + step' + (if step' > 0 then step' else 1) in

        let step'' = step' + (if (m' > item) then (item - m') else 0) in

        let m'' = if m' > item then item else m' in

        printf "M': %d M'': %d\n" m' m'';
        let step''' = if (m'' - item) * t.sign < 0 && step'' > 1 then 1 else step'' in
        {t with m=m''; step=step'''; sign=1}
    end
    else if item < t.m && (Random.float 1.0) > t.q then begin
        let step' = t.step + t.f(t.step) * (if t.sign < 0 then 1 else -1) in

        let m' = t.m - step' + (if step' > 0 then step' else 1) in

        let step'' = step' + (if (m' < item) then (m' - item) else 0) in
        let m'' = if m' < item then item else m' in
        let step''' = if (m'' - item) * t.sign < 0 && step'' > 1 then 1 else step'' in
        {t with m = m''; step = step'''; sign= -1}
    end
    else t


