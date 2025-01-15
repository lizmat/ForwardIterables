[![Actions Status](https://github.com/lizmat/ForwardIterables/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/ForwardIterables/actions) [![Actions Status](https://github.com/lizmat/ForwardIterables/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/ForwardIterables/actions) [![Actions Status](https://github.com/lizmat/ForwardIterables/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/ForwardIterables/actions)

NAME
====

ForwardIterables - turn two or more Iterables into a single iterator

SYNOPSIS
========

```raku
use ForwardIterables;

my @a = ^5;
my @b = <a b c d e>;
my @c = ForwardIterables.new(@a,@b).Seq;
say @c;  # [0 1 2 3 4 a b c d e]
```

DESCRIPTION
===========

The `ForwardIterables` distribution provides a `ForwardIterables` class that creates a single `Iterator` from any number `Iterables` that will **lazily** produce values in a "forward" order.

This functionality is similar to the [`flat`](https://docs.raku.org/routine/flat) method, but with the important distinction that it does **NOT** look at the containerization of the arguments. So any iterable such as a `Array` or `List` inside a `Hash` or an `Array`, **will** produce all of its values.

And it also does **not** recurse into any `Iterable` values that it encounters, so in that aspect it is **NOT** like `flat` at all.

It also provides a `Seq` method, to directly produce a `Seq` object from the iterator, so it can be used in expressions.

PROBABLY NOT USER FACING
========================

This module is probably more useful for module developers, than for people writing direct Raku production code.

PERFORMANCE
-----------

Depending on the situation, the use of this iterator can be anywhere from 1.5x to 3x as fast as the equivalent code using `.flat`.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/OneSeq . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

