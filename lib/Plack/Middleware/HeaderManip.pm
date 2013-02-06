package Plack::Middleware::HeaderManip;

use strict;
use parent qw(Plack::Middleware);

__PACKAGE__->mk_accessors(qw(copy rename));

use Plack::Util;

our $VERSION = '0.01';

sub call {
    my $self = shift;
    my $res  = $self->app->(@_);

    $self->response_cb(
        $res,
        sub {
            my $res = shift;
            my $headers = $res->[1];

		    if ( $self->copy ) {
				while ( my ($from, $to) = splice @{$self->copy}, 0, 2) {
					if (Plack::Util::header_exists($headers, $from)) {
						Plack::Util::header_push($headers, $to, Plack::Util::header_get($headers, $from));
					}
				}
		    }
		    if ( $self->rename ) {
				while ( my ($from, $to) = splice @{$self->rename}, 0, 2) {
					if (Plack::Util::header_exists($headers, $from)) {
						Plack::Util::header_push($headers, $to, Plack::Util::header_get($headers, $from));
						Plack::Util::header_remove($headers, $from);
					}
				}
		    }
        }
    );
}

1;

__END__

=head1 NAME

Plack::Middleware::HeaderManip - manipulate HTTP response headers (rename, copy)

=head1 SYNOPSIS

  use Plack::Builder;

  my $app = sub {['200', [], ['hello']]};
  builder {
      enable 'HeaderManip',
        rename => ['X-Content-Length' => 'Content-Length'],
        copy => ['X-Plack-One' => 'x-Plack-Two'],
      $app;
  };

=head1 DESCRIPTION

Plack::Middleware::HeaderManip

=head1 AUTHOR

Mike Tonks

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Plack::Middleware> L<Plack::Builder>

=cut

