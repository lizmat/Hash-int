# Need to be using NQP ops here to get the desired efficiency, and
# hopefully this will be integrated into Rakudo before soon.
use nqp;

class Hash::int:ver<0.0.3>:auth<zef:lizmat> {
    has $!hash handles <gist raku Str values pairs iterator>;

    method new() {
        nqp::p6bindattrinvres(nqp::create(self),self,'$!hash',nqp::hash)
    }

    method STORE(::?CLASS:D: \to-store, :$INITIALIZE) {
        my $iterator := to-store.iterator;
        my $hash     := $INITIALIZE ?? $!hash !! ($!hash := nqp::hash);
        my Mu $x;
        my Mu $y;

        nqp::until(
          nqp::eqaddr(($x := $iterator.pull-one),IterationEnd),
          nqp::if(
            nqp::istype($x,Pair),
            nqp::bindkey(
              $hash,
              (my int $ = nqp::getattr(nqp::decont($x),Pair,'$!key').Int),
              (nqp::getattr(nqp::decont($x),Pair,'$!value'))
            ),
            nqp::if(
              (nqp::istype($x,Map) && nqp::not_i(nqp::iscont($x))),
              self.STORE($x),
              nqp::if(
                nqp::eqaddr(($y := $iterator.pull-one),IterationEnd),
                nqp::if(
                  nqp::istype($x,Failure),
                  $x.throw,
                  X::Hash::Store::OddNumber.new(
                    found => nqp::add_i(nqp::mul_i(nqp::elems($hash),2),1),
                    last  => $x
                  ).throw
                ),
                nqp::bindkey($hash,(my int $ = $x.Int),$y)
              )
            )
          )
        );
        self
    }

    method AT-KEY(::?CLASS:D: int $key) is raw {
        nqp::atkey($!hash,$key)
    }
    method ASSIGN-KEY(::?CLASS:D: int $key, \value) is raw {
        nqp::bindkey($!hash,$key,value)
    }
    method BIND-KEY(::?CLASS:D: int $key, \value) is raw {
        nqp::bindkey($!hash,$key,value)
    }
    method DELETE-KEY(::?CLASS:D: int $key) is raw {
        my $value := nqp::atkey($!hash,$key);
        nqp::deletekey($!hash,$key);
        $value
    }
    method EXISTS-KEY(::?CLASS:D: int $key) is raw {
        nqp::hllbool(nqp::existskey($!hash,$key))
    }
    method keys(::?CLASS:D:) {
        nqp::hllize($!hash).keys.map: *.Int
    }
    method kv(::?CLASS:D:) {
        nqp::hllize($!hash).map: { (.key.Int, .value).Slip }
    }
}

=begin pod

=head1 NAME

Hash::int - provide a hash with native integer keys

=head1 SYNOPSIS

=begin code :lang<raku>

use Hash::int;

my %hash is Hash::int = 42 => "foo", 666 => "bar";

=end code

=head1 DESCRIPTION

Hash::int is module that provides the C<Hash::int> class to be applied
to the initialization of an Associative, making it limit the keys to
native integers that fit the C<int> type.  This allows this module to
take some shortcuts, making it up to 7x as fast as a normal hash.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Hash-int . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
