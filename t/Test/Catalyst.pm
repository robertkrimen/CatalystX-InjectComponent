package t::Test::Catalyst;

use strict;
use warnings;

use Catalyst::Runtime '5.70';
use CatalystX::InjectComponent;

use Moose;
BEGIN { extends qw/Catalyst/ }

use Catalyst qw/-Debug
                ConfigLoader
                Static::Simple/;
our $VERSION = '0.01';

__PACKAGE__->config( name => 't::Test::Catalyst' );

after 'setup_components' => sub {
    my $self = shift;
    CatalystX::InjectComponent->_inject_component(
        __PACKAGE__,
        't::Test::Component1',
        'Controller::Component1',
#        into => __PACKAGE__,
#        base => 'SuperFunComponent',
#        moniker => 'Controller::SuperFun',
    );
};

__PACKAGE__->setup();

1;
