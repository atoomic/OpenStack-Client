package OpenStack::Client::API::Compute;

use strict;
use warnings;

use Test::More;
use Moo;

# use Client::API role
#with 'OpenStack::Client::API'; ...

extends 'OpenStack::Client::API::Service';

has '+name' => ( is => 'ro', default => 'compute' );

# with 'OpenStack::Client::Lite::Roles::Dispatchable';
# sub dispatch { # move to a role OpenStack::Client::Lite::Roles::Dispatchable
# 	my ( $self, @args ) = @_;
# 	note "dispatch... ", explain \@args;
# }

sub keypairs {
	my ( $self, @args ) = @_;

	note explain $self;

	note "XXX ";
	note "XXX ";
	note "XXX ";

	my $client = $self->client;
	note explain $client;
	note "Endpoint: ", $client->endpoint();
	my $subname = (caller(0))[3];
	note "subname: ", $subname;
	my @ns = split( /::/, $subname );
	$subname = $ns[-1];
	note "subname shorter: ", $subname;
	
	note $self->version;

	return $client->all('/os-keypairs', 'keypairs');
}

sub compute {

}

sub flavors {

}




1;

__DATA__
---
keypairs:
  listable: 1
flavors:
  listable: 1



