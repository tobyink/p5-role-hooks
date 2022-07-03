use strict;
use warnings;
use Test::More;
use Role::Tiny;

BEGIN {
	package Foo;
	sub new { bless [], shift }
};

ok ! Role::Tiny->is_role( 'Foo' );
done_testing;
