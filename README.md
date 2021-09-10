[![Actions Status](https://github.com/lizmat/Hash-int/workflows/test/badge.svg)](https://github.com/lizmat/Hash-int/actions)

NAME
====

Hash::int - provide a hash with native integer keys

SYNOPSIS
========

```raku
use Hash::int;

my %hash is Hash::int = 42 => "foo", 666 => "bar";
```

DESCRIPTION
===========

Hash::int is module that provides the `Hash::int` class to be applied to the initialization of an Associative, making it limit the keys to native integers that fit the `int` type. This allows this module to take some shortcuts, making it up to 7x as fast as a normal hash.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Hash-int . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

