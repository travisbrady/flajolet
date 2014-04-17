flajolet
========

Streaming/sketching data structures for OCaml

Flajolet is an OCaml library providing streaming data structures in the vein of the popular
[streamlib](https://github.com/addthis/stream-lib) library for Java.

Flajolet is named for Philippe Flajolet inventor of the HyperLogLog.

Modules:
=========

Histogram: a streaming histogram, allowing for computation of description stats (mean, variance) and
quantiles in bounded memory in a streaming fashion.

Hyperloglog:
===========
Distinct values counting. This example: https://github.com/travisbrady/flajolet/blob/master/examples/card.ml
provides a very simple demonstration of the idea here.

StreamSummary:
==============
Top-k queries in bounded memory.  When you've scanning a stream user ids and want to ask
"who are the top 10 most frequently seen users?" but storing a map from every user id to every
appearance count is infeasible.

Recordinality
=============
Another distinct values estimation method, this time created by a former student (Jeremie Lumbroso) of Flajolet's.
The benefit here is that Recordinality allows you to count distinct values and to retrieve a sample
of previously seen values.

Sbitmap:
========
Sel-Learning Bitmaps
Another distinct values estimator with scale-invariant errors.  Also uses less memory than a 
Hyperloglog often when cardinality is < 10^6 and the desired error rate is low.
For more see page 27 of Chen and Cao's paper: 
http://arxiv.org/pdf/1107.1697v1.pdf


