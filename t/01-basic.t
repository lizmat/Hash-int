use Test;
use Hash::int;

plan 10;

my %h is Hash::int = 42 => "foo", 666 => "bar";
is %h{42}, "foo",  'can we access existing key (1)';
is %h{666}, "bar", 'can we access existing key (2)';

is-deeply %h{42}:exists, True,  'can we check existence of existing';
is-deeply %h{41}:exists, False, 'can we check existence of non-existing';

is (%h{42} = "zippo"), "zippo", 'can we assign existing';
is (%h{41} = "zappo"), "zappo", 'can we assign non-existing';

is (%h{666} := "dinko"), "dinko", 'can we bind existing';
is (%h{665} := "danko"), "danko", 'can we bind non-existing';

is        %h{666}:delete, "dinko", 'can we delete existing (1)';
is-deeply %h{666}:exists,   False, 'can we delete existing (2)';

# vim: expandtab shiftwidth=4
