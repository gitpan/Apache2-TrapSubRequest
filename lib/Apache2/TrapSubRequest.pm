package Apache2::TrapSubRequest;

use warnings FATAL => 'all';
use strict;

use mod_perl2 1.999023;

use Apache2::RequestRec  ();
use Apache2::RequestUtil ();
use Apache2::SubRequest  ();
use Apache2::Filter      ();
use Apache2::Connection  ();
use Apache2::Log         ();

use APR::Bucket         ();
use APR::Brigade        ();

use Carp                ();

use Apache2::Const      -compile => qw(OK DECLINED HTTP_OK);
use APR::Const          -compile => qw(:common);

=head1 NAME

Apache2::TrapSubRequest - Trap a lookup_file/lookup_uri into a scalar

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

    # ...
    use Apache2::TrapSubRequest  ();

    sub handler {
        my $r = shift;
        my $subr = $r->lookup_uri('/foo');
        my $data;
        $subr->run_trapped(\$data);
        # ...
        Apache2::OK;
    }

=head1 WARNING

This software requires that the Apache API function C<ap_save_brigade> be 
exposed as C<Apache2::Filter::save_brigade> with the parameters 
($f, $newbb, $bb, $pool). As of this writing (2005-02-11), this
functionality is not present in the core mod_perl 2.x distribution.

=head1 FUNCTIONS

=head2 run_trapped (\$data);

Run the output of a subrequest into a scalar reference.

=cut

sub Apache2::SubRequest::run_trapped {
    my ($r, $dataref) = @_;
    Carp::croak('Usage: $subr->run_trapped(\$data)') 
        unless ref $dataref eq 'SCALAR';
    $$dataref = '' unless defined $$dataref;
    $r->pnotes(__PACKAGE__, $dataref);
    $r->add_output_filter(\&_filter);
    my $rv = $r->run;
    $rv;
}

sub _filter {
    my ($f, $bb) = @_;
    my $r = $f->r;
    my $dataref = $r->pnotes(__PACKAGE__);
    $bb->flatten(my $string);
    $$dataref .= $string;
    Apache2::Const::OK;
}

=head1 AUTHOR

dorian taylor, C<< <dorian@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-apache-trapsubrequest@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 dorian taylor, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Apache2::TrapSubRequest
