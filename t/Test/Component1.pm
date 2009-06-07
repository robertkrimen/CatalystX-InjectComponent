package t::Test::Component1;

use strict;
use warnings;

use parent qw/Catalyst::Controller/;

sub default :Path {
    my ( $self, $ctx ) = @_;
}

sub durp :Local {
}

1;
