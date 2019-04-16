package OpenStack::Client::API::Network;

use strict;
use warnings;

use Test::More;
use Moo;

extends 'OpenStack::Client::API::Service';
# roles
with    'OpenStack::Client::Lite::Roles::Listable';

has '+name' => ( default => 'network' );
has '+version_prefix' => ( default => 'v2.0' );

sub networks {
	my ( $self, @args ) = @_;

	return $self->_list( ['/networks', 'networks'], \@args );
}

sub security_groups {
	my ( $self, @args ) = @_;

	return $self->_list( ['/security-groups', 'security_groups'], \@args );	
}

1;
