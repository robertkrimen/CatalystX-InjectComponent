package CatalystX::InjectComponent;

use warnings;
use strict;

=head1 NAME

CatalystX::InjectComponent - Inject components into your Catalyst application

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Devel::InnerPackage;
use Class::Inspector;
use Carp;

sub _inject_component {
    my $self = shift;
    my $into = shift;
    my $base = shift;
    my $moniker = shift;

    croak "No into (Catalyst package) given" unless $into;
    croak "No base (package) given" unless $base;
    croak "No moniker given" unless $moniker;

    if ( ! Class::Inspector->loaded( $base ) ) {
        eval "require $base;" or croak "Couldn't require $base (to inject into $moniker)";
    }

    {
        # Meh, hack
        (my $file = "$base.pm") =~ s{::}{/}g;
        $INC{$file} ||= 1;
    }

    my $component_package = join '::', $into, $moniker;

    if ( Class::Inspector->loaded( $component_package ) ) {
    }
    else {
       eval "package $component_package; use parent qw/$base/; 1;" or
        croak "Unable to build component package for \"$component_package\": $@";
    }

    if (1) {
        (my $file = "$component_package.pm") =~ s{::}{/}g;
        $INC{$file} ||= 1;
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
