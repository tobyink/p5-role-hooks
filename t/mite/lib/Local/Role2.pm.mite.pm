{
package Local::Role2;
our $USES_MITE = q[Mite::Role];
use strict;
use warnings;

BEGIN {
    require Local::Role1;
    our %DOES = ( q[Local::Role2] => 1, q[Local::Role1] => 1 );
}

sub DOES {
    my ( $self, $role ) = @_;
    our %DOES;
    return $DOES{$role} if exists $DOES{$role};
    return 1 if $role eq __PACKAGE__;
    return $self->SUPER::DOES( $role );
}

sub does {
    shift->DOES( @_ );
}

# Callback which classes consuming this role will call
sub __FINALIZE_APPLICATION__ {
    my ( $me, $target, $args ) = @_;
    our ( %CONSUMERS, @METHOD_MODIFIERS );

    # Ensure a given target only consumes this role once.
    if ( exists $CONSUMERS{$target} ) {
        return;
    }
    $CONSUMERS{$target} = 1;

    my $type = do { no strict 'refs'; ${"$target\::USES_MITE"} };
    if ( $type ne 'Mite::Class' ) {
        return;
    }

    my @roles = ( q[Local::Role1] );
    my %nextargs = %{ $args || {} };
    ( $nextargs{-indirect} ||= 0 )++;
    for my $role ( @roles ) {
        $role->__FINALIZE_APPLICATION__( $target, { %nextargs } );
    }

    my $shim = q[Local::Mite];
    for my $modifier_rule ( @METHOD_MODIFIERS ) {
        my ( $modification, $names, $coderef ) = @$modifier_rule;
        $shim->$modification( $target, $names, $coderef );
    }

    return;
}

1;
}