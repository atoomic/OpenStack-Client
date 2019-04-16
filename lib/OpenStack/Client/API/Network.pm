package OpenStack::Client::API::Network;

use strict;
use warnings;

use Test::More;
use Moo;

# FIXME import LoadData / DataAsYaml
#use OpenStack::Client::Lite::Helpers::DataAsYaml;

# use Client::API role
#with 'OpenStack::Client::API'; ...

extends 'OpenStack::Client::API::Service';
# roles
with    'OpenStack::Client::Lite::Roles::Listable';

has '+name' => ( default => 'network' );
has '+version_prefix' => ( default => 'v2.0' );

# with 'OpenStack::Client::Lite::Roles::Dispatchable';
# sub dispatch { # move to a role OpenStack::Client::Lite::Roles::Dispatchable
# 	my ( $self, @args ) = @_;
# 	note "dispatch... ", explain \@args;
# }



sub networks {
	my ( $self, @args ) = @_;

	note "networks....";
	note $self->version;


	return $self->_list( ['/networks', 'networks'], \@args );
}

1;
