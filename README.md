flajolet
========

Probabilistic data structures for OCaml intended for use in streaming data analysis

Flajolet is an OCaml library providing streaming data structures in the vein of the popular
[streamlib](https://github.com/addthis/stream-lib) library for Java.

Flajolet is named for INRIA professor [Philippe Flajolet](http://algo.inria.fr/flajolet/), inventor of the HyperLogLog data structure.

Modules:
=========

*ALPHA* 
Still very much in development.

####Hyperloglog:
Distinct values counting. This example: [card.ml](https://github.com/travisbrady/flajolet/blob/master/examples/card.ml)
provides a very simple demonstration of the idea here.

Toy example usage counting 4 unique strings:
```ocaml
# #require "flajolet";;
# let hll = Hyperloglog.create 0.03;;
val hll : Hyperloglog.t = <abstr>
# List.iter (fun x -> Hyperloglog.offer hll x) ["hi"; "hello"; "bonjour"; "salut"; "hi"; "hi"; "hi"];;
- : unit = ()
# Hyperloglog.card hll;;
- : float = 4.00391134373
```

####Bloom Filter
Supports approximate set membership queries with no false negatives.

Example:
```ocaml
(* Create a bloom filter with 10_000 expected items and a 1% desired false positive rate *)
# let b = Bloom.create_with_estimates 10_000 0.01;;
# Bloom.add b "hey";;
# Bloom.test b "hey";;
- : bool = true
Bloom.test b "nope";;
- : bool = false
```

####Count-Min Sketch
A well-known sketch used for frequency estimation. You can think of it as a hash table for storing
approximate frequencies where you don't maintain the keys. You can ask "how many times have you
seen the `blah_blah_blah`?" and the Cmsketch will answer with an estimated count. But it cannot
provide a list of keys ever seen. Also allows deletion.
The tests in [test_cmsketch.ml](lib_test/test_cmsketch.ml) are instructive.

####Minhash
Useful for computing the Jaccard coefficient in bounded space. Invented originall to detect
near-duplicate webpages and can be applied to all sorts of near-dupicate detection problems
provided you've got a way to featurize your data.
Used primarily for set similarity but also supports cardinality estimation.
See the tests in [test_minhash.ml](lib_test/test_minhash.ml)

####StreamSummary:
Top-k queries in bounded memory.  When you've scanning a stream user ids and want to ask
"who are the top 10 most frequently seen users?" but storing a map from every user id to every
appearance count is infeasible.

See [topk.ml](https://github.com/travisbrady/flajolet/blob/master/examples/topk.ml) for an example of using a stream summary to calculate the top-k most frequenty itemsin a shell pipeline.

####Histogram:
a streaming histogram, allowing for computation of descriptive stats (min, max, mean, variance) and
quantiles in bounded memory in a streaming fashion.

Have a look at [destats.ml](https://github.com/travisbrady/flajolet/blob/master/examples/destats.ml) for an example of using a Histogram to compute descriptive stats on a column of numbers read of stdin.

Example with some fake data:
```
$ cat floats
0.0
1.0
2.0
3.0
4.0
$ cat floats | ./destats.native
count:       5.00
mean :       2.00
std  :       1.41
min  :       0.00
25%  :       1.00
50%  :       2.00
75%  :       3.00
max  :       4.00
```

####Recordinality
Another distinct values estimation method, this time created by a former student (Jeremie Lumbroso) of Flajolet's.
The benefit here is that Recordinality allows you to count distinct values and to retrieve a sample
of previously seen values.

####Self-Learning Bitmaps (aka Sbitmap):
Another distinct values estimator with scale-invariant errors.  More space-efficient than a 
Hyperloglog often when cardinality is < 10^6 and the desired error rate is low.
For more see page 27 of Chen and Cao's paper: 
http://arxiv.org/pdf/1107.1697v1.pdf
