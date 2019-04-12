package OpenStack::Client::Lite::Routes;

use strict;
use warnings;

use Test::More;
use Moo;

our $ROUTES = {
	keypairs => {
	    service  => 'compute',
	    listable => 1,
	},

};

sub list_all {
	return sort keys %$ROUTES;
}

sub keypairs {
	note "keypairs... todo";
}

1;
