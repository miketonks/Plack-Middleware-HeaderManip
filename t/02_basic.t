use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;
use Plack::Builder;
use Plack::Test;
use Cwd;

my $copy_handler = builder {
    enable "Plack::Middleware::HeaderManip",
        copy => ['Foo' => 'Bar']
    ;
    sub { ['200', ['Content-Type' => 'text/html', 'Foo' => 'test'], ['hello world']] };
};

my $rename_handler = builder {
    enable "Plack::Middleware::HeaderManip",
        rename => ['Foo' => 'Bar']
    ;
    sub { ['200', ['Content-Type' => 'text/html', 'Foo' => 'test'], ['hello world']] };
};

my $cl_handler = builder {
    enable "Plack::Middleware::HeaderManip",
        rename => ['X-Content-Length' => 'Content-Length']
    ;
    sub { ['200', ['Content-Type' => 'text/html', 'x-Content-Length' => '11'], ['hello world']] };
};


test_psgi app => $copy_handler, client => sub {
    my $cb = shift;

    {
        my $req = GET "http://localhost/";
        my $res = $cb->($req);
        is_deeply $res->headers, {
        	'content-type' => 'text/html',
        	'foo' => 'test',
        	'bar' => 'test',
        };
    }
};

test_psgi app => $rename_handler, client => sub {
    my $cb = shift;

    {
        my $req = GET "http://localhost/";
        my $res = $cb->($req);
        is_deeply $res->headers, {
        	'content-type' => 'text/html',
        	'bar' => 'test',
        };
    }
};

test_psgi app => $cl_handler, client => sub {
    my $cb = shift;

    {
        my $req = GET "http://localhost/";
        my $res = $cb->($req);
        is_deeply $res->headers, {
        	'content-type' => 'text/html',
        	'content-length' => 11,
        };
    }
};


done_testing;

