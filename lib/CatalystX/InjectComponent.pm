package CatalystX::InjectComponent;

use warnings;
use strict;

=head1 NAME

CatalystX::InjectComponent - Inject components into your Catalyst application

=head1 VERSION

Version 0.023

=cut

our $VERSION = '0.023';

=head1 SYNOPSIS

    package My::App;

    use Catalyst::Runtime '5.80';

    use Moose;
    BEGIN { extends qw/Catalyst/ }

    ...

    after 'setup_components' => sub {
        my $class = shift;
        CatalystX::InjectComponent->inject( into => $class, component => 'MyModel' );
        if ( $class->config->{ ... ) {
            CatalystX::InjectComponent->inject( into => $class, component => 'MyRootV2', as => 'Controller::Root' );
        }
        else {
            CatalystX::InjectComponent->inject( into => $class, component => 'MyRootV1', as => 'Root' ); # Controller:: will be automatically prefixed
        }
    };

=head1 DESCRIPTION

CatalystX::InjectComponent will inject Controller, Model, and View components into your Catalyst application at setup (run)time. It does this by creating
a new package on-the-fly, having that package extend the given component, and then having Catalyst setup the new component (via C<< ->setup_component >>)

=head1 So, how do I use this thing?

You should inject your components when appropiate, typically after C<setup_compenents> runs

If you're using the Moose version of Catalyst, then you can use the following technique:

    use Moose;
    BEGIN { extends qw/Catalyst/ }

    after 'setup_components' => sub {
        my $class = shift;

        CatalystX::InjectComponent->inject( catalyst => $class, ... )
    };

=head1 METHODS

=head2 CatalystX::InjectComponent->inject( ... )

    into        The Catalyst package to inject into (e.g. My::App)
    component   The component package to inject
    as          An optional moniker to use as the package name for the derived component 

For example:

    ->inject( into => My::App, component => Other::App::Controller::Apple )
        
        The above will create 'My::App::Controller::Other::App::Controller::Apple'

    ->inject( into => My::App, component => Other::App::Controller::Apple, as => Apple )

        The above will create 'My::App::Controller::Apple'

=head1 ACKNOWLEDGEMENTS

Inspired by L<Catalyst::Plugin::AutoCRUD>

=cut

use Devel::InnerPackage;
use Class::Inspector;
use Carp;

sub put_package_into_INC ($) {
    my $package = shift;
    (my $file = "$package.pm") =~ s{::}{/}g;
    $INC{$file} ||= 1;
}

sub loaded ($) {
    my $package = shift;
    if ( Class::Inspector->loaded( $package ) ) {
        put_package_into_INC $package; # As a courtesy
        return 1;
    }
    return 0;
}

sub inject {
    my $self = shift;
    my %given = @_;

    my ($into, $component, $as);
    if ( $given{catalyst} ) { # Legacy argument parsing
        ($into, $component, $as) = @given{ qw/catalyst component into/ };
    }
    else {
        ($into, $component, $as) = @given{ qw/into component as/ };
    }
    
    croak "No Catalyst (package) given" unless $into;
    croak "No component (package) given" unless $component;

    unless ( loaded $component ) {
        eval "require $component;" or croak "Couldn't require (component base) $component: $@";
    }

    $as ||= $component;
    unless ( $as =~ m/^(?:Controller|Model|View)::/ || $given{skip_mvc_renaming} ) {
        my $category;
        for (qw/ Controller Model View /) {
            if ( $component->isa( "Catalyst::$_" ) ) {
                $category = $_;
                last;
            }
        }
        croak "Don't know what kind of component \"$component\" is" unless $category;
        $as = "${category}::$as";
    }
    my $component_package = join '::', $into, $as;

    unless ( loaded $component_package ) {
        eval "package $component_package; use parent qw/$component/; 1;" or
            croak "Unable to build component package for \"$component_package\": $@";
        put_package_into_INC $component_package; # As a courtesy
    }

    $self->_setup_component( $into => $component_package );
    for my $inner_component_package ( Devel::InnerPackage::list_packages( $component_package ) ) {
        $self->_setup_component( $into => $inner_component_package );
    }
}

sub _setup_component {
    my $self = shift;
    my $into = shift;
    my $component_package = shift;
    $into->components->{$component_package} = $into->setup_component( $component_package );
}

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-catalystx-injectcomponent at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CatalystX-InjectComponent>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CatalystX::InjectComponent


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CatalystX-InjectComponent>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CatalystX-InjectComponent>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CatalystX-InjectComponent>

=item * Search CPAN

L<http://search.cpan.org/dist/CatalystX-InjectComponent/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of CatalystX::InjectComponent
