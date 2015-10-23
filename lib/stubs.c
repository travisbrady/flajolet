#include <stdio.h>
#include <stdint.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

CAMLprim value
caml_clz(value v) {
    int res = __builtin_clz(Int_val(v));
    return Val_int(res);
}

CAMLprim value
caml_clzl(value v) {
    int res = __builtin_clzl(Int64_val(v));
    return Val_int(res);
}
