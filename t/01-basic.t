#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

use CatalystX::InjectComponent;
BEGIN {
package SuperFunComponent;

use parent qw/Catalyst::Controller/;

__PACKAGE__->config->{namespace} = '';

sub default :Path {
}

package TestCatalyst; $INC{'TestCatalyst.pm'} = 1;

use Catalyst::Runtime '5.70';

use Moose;
BEGIN { extends qw/Catalyst/ }

use Catalyst qw/-Debug ConfigLoader Static::Simple/;

after 'setup_components' => sub {
    my $self = shift;
    CatalystX::InjectComponent->_inject_component(
        __PACKAGE__,
        'SuperFunComponent',
        'Controller::SuperFun',
#        into => __PACKAGE__,
#        base => 'SuperFunComponent',
#        moniker => 'Controller::SuperFun',
    );
};

TestCatalyst->config( 'home' => '.' );

TestCatalyst->setup;

}

package main;

#use Catalyst::Test qw/t::Test::Catalyst/;
use Catalyst::Test qw/TestCatalyst/;

ok( 1 );
