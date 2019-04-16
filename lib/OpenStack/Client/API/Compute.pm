package OpenStack::Client::API::Compute;

use strict;
use warnings;

use Test::More;
use Moo;

# FIXME import LoadData / DataAsYaml
use OpenStack::Client::Lite::Helpers::DataAsYaml;

# use Client::API role
#with 'OpenStack::Client::API'; ...

extends 'OpenStack::Client::API::Service';
# roles
#with    'OpenStack::Client::Lite::Roles::DataAsYaml';
with    'OpenStack::Client::Lite::Roles::Listable';

has '+name' => ( default => 'compute' );

# with 'OpenStack::Client::Lite::Roles::Dispatchable';
# sub dispatch { # move to a role OpenStack::Client::Lite::Roles::Dispatchable
# 	my ( $self, @args ) = @_;
# 	note "dispatch... ", explain \@args;
# }

sub keypairs {
	my ( $self, @args ) = @_;

	return $self->_list( ['/os-keypairs', 'keypairs'], \@args );
#note "DATA: ", explain $self->DataAsYaml;
}

sub servers {
	my ( $self, @args ) = @_;

	return $self->_list( ['/servers', 'servers'], \@args );
}

sub flavors {
	my ( $self, @args ) = @_;

	return $self->_list( ['/flavors', 'flavors'], \@args );
}

### helpers


1;

__DATA__
---
keypairs:
  listable: 1
flavors:
  listable: 1



