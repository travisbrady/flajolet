#include <stdio.h>
#include <stdint.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

#include "murmur3.h"
#include "xxhash.h"

CAMLprim value
caml_MurmurHash3_x86_32(value key, value seed) {
    char *k = String_val(key);
    int len = caml_string_length(key);
    uint32_t _seed = (uint32_t)Int_val(seed);
    uint32_t out = _seed;
    MurmurHash3_x86_32(k, len, _seed, &out);
    return Val_int(out);
}

CAMLprim value
caml_MurmurHash3_x86_128(value key, value seed) {
    CAMLparam2(key, seed);
    uint64_t out[2];
    MurmurHash3_x86_128(String_val(key), caml_string_length(key), (uint32_t)Int_val(seed), out);
    value pair = caml_alloc_tuple(2);
    Store_field(pair, 0, caml_copy_int64(out[0]));
    Store_field(pair, 1, caml_copy_int64(out[1]));
    CAMLreturn(pair);
}

CAMLprim value
caml_MurmurHash3_x64_128(value key, value seed) {
    CAMLparam2(key, seed);
    uint64_t out[2];
    MurmurHash3_x64_128(String_val(key), caml_string_length(key), (uint32_t)Int_val(seed), out);
    value pair = caml_alloc_tuple(2);
    Store_field(pair, 0, caml_copy_int64(out[0]));
    Store_field(pair, 1, caml_copy_int64(out[1]));
    CAMLreturn(pair);
}

uint64_t hash_crapwow64(const unsigned char *buf, uint64_t len, uint64_t seed)
{
	const uint64_t m = 0x95b47aa3355ba1a1, n = 0x8a970be7488fda55;
	uint64_t hash;
	/*
	  3 = m, 4 = n
	  r12 = h, r13 = k, ecx = seed, r12 = key
	*/
	__asm__ (
		"leaq (%%rcx,%4), %%r13\n"
		"movq %%rdx, %%r14\n"
		"movq %%rcx, %%r15\n"
		"movq %%rcx, %%r12\n"
		"addq %%rax, %%r13\n"
		"andq $0xfffffffffffffff0, %%rcx\n"
		"jz QW%=\n"
		"addq %%rcx, %%r14\n\n"
		"negq %%rcx\n"
		"XW%=:\n"
		"movq %4, %%rax\n"
		"mulq (%%r14,%%rcx)\n"
		"xorq %%rax, %%r12\n"
		"xorq %%rdx, %%r13\n"
		"movq %3, %%rax\n"
		"mulq 8(%%r14,%%rcx)\n"
		"xorq %%rdx, %%r12\n"
		"xorq %%rax, %%r13\n"
		"addq $16, %%rcx\n"
		"jnz XW%=\n"
		"QW%=:\n"
		"movq %%r15, %%rcx\n"
		"andq $8, %%r15\n"
		"jz B%=\n"
		"movq %4, %%rax\n"
		"mulq (%%r14)\n"
		"addq $8, %%r14\n"
		"xorq %%rax, %%r12\n"
		"xorq %%rdx, %%r13\n"
		"B%=:\n"
		"andq $7, %%rcx\n"
		"jz F%=\n"
		"movq $1, %%rdx\n"
		"shlq $3, %%rcx\n"
		"movq %3, %%rax\n"
		"shlq %%cl, %%rdx\n"
		"addq $-1, %%rdx\n"
		"andq (%%r14), %%rdx\n"
		"mulq %%rdx\n"
		"xorq %%rdx, %%r12\n"
		"xorq %%rax, %%r13\n"
		"F%=:\n"
		"leaq (%%r13,%4), %%rax\n"
		"xorq %%r12, %%rax\n"
		"mulq %4\n"
		"xorq %%rdx, %%rax\n"
		"xorq %%r12, %%rax\n"
		"xorq %%r13, %%rax\n"
		: "=a"(hash), "=c"(buf), "=d"(buf)
		: "r"(m), "r"(n), "a"(seed), "c"(len), "d"(buf)
		: "%r12", "%r13", "%r14", "%r15", "cc" 
		);
	return hash;
}

//uint64_t hash_crapwow64(const unsigned char *buf, uint64_t len, uint64_t seed)
CAMLprim value
caml_hash_crapwow64(value buf, value seed) {
    const unsigned char *_buf = (
            const unsigned char *)String_val(buf);
            uint64_t res = hash_crapwow64(_buf,
            caml_string_length(buf),
            (uint64_t)Int64_val(seed));
    return caml_copy_int64(res);
}

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

CAMLprim value
caml_xxh_256(value input) {
    const void *dude = (const void *)String_val(input);
    size_t len = (size_t)caml_string_length(input);
    uint64_t out[4];
    XXH_256(dude, len, out);
    return caml_copy_int64(out[0]);
}

uint64_t hash_murmur64(const unsigned char *buf, size_t len, uint64_t seed)
{
	const uint64_t m = 0xc6a4a7935bd1e995ULL;
	const int r = 47;
	const uint64_t *data = (const uint64_t *)buf;
	const uint64_t *end = data + (len / 8);
	const unsigned char *data2;
	uint64_t h = seed ^ (len * m);
	uint64_t v;

	while (data != end) {
		v = *data++;
		v *= m;
		v ^= v >> r;
		v *= m;
		h ^= v;
		h *= m;
	}

	data2 = (const unsigned char*)data;

	switch (len & 7) {
	case 7: h ^= (uint64_t)data2[6] << 48;
	case 6: h ^= (uint64_t)data2[5] << 40;
	case 5: h ^= (uint64_t)data2[4] << 32;
	case 4: h ^= (uint64_t)data2[3] << 24;
	case 3: h ^= (uint64_t)data2[2] << 16;
	case 2: h ^= (uint64_t)data2[1] << 8;
	case 1: h ^= (uint64_t)data2[0];
		h *= m;
	}
 
	h ^= h >> r;
	h *= m;
	h ^= h >> r;

	return h;
}

CAMLprim value
caml_hash_murmur64(value buf, value vseed) {
    const unsigned char *_buf = (const unsigned char *)String_val(buf);
    size_t len = (size_t)caml_string_length(buf);
    uint64_t seed = (uint64_t)Int64_val(vseed);
    uint64_t res = hash_murmur64(_buf, len, seed);
    return caml_copy_int64(res);
}
