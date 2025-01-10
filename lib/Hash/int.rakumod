# Need to be using NQP ops here to get the desired efficiency, and
# hopefully this will be integrated into Rakudo before soon.
use nqp;

class Hash::int {
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
    method push(::?CLASS:D: +values) {
        my $iterator := values.iterator;
        my $previous := nqp::null;
        nqp::until(
          nqp::eqaddr((my $pulled := $iterator.pull-one),IterationEnd),
          nqp::if(
            nqp::isnull($previous),
            nqp::if(
              nqp::istype($pulled,Pair),
              self!push(.key, .value),
              $previous := $pulled
            ),
            nqp::stmts(
              self!push($previous, $pulled),
              $previous := nqp::null
            )
          )
        );

        warn "Trailing item in {self.^name}.push"
          unless nqp::isnull($previous);
        self
    }
    method !push(int $key, $value --> Nil) {
        nqp::if(
          nqp::isnull(my $old := nqp::atkey($!hash,$key)),
          nqp::bindkey($!hash,$key,$value),
          nqp::if(
            nqp::istype($old,List),
            nqp::push(nqp::getattr($old,List,'$!reified'),$value),
            nqp::bindkey($!hash,$key,nqp::stmts(
              (my $buffer := nqp::create(IterationBuffer)),
              nqp::push($buffer,$old),
              nqp::push($buffer,$value),
              $buffer.List
            ))
          )
        )
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
take some shortcuts, making it up to B<7x> as fast as a normal hash.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Hash-int . Comments and
Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2021, 2024, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
