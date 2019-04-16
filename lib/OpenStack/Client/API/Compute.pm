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

has '+name' => ( is => 'ro', default => 'compute' );

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

sub compute {

}

sub flavors {
	my ( $self, @args ) = @_;

	return $self->_list( ['/flavors', 'flavors'], \@args );
}

### helpers

sub _list {
	my ( $self, $all_args, $caller_args ) = @_;

	my @all = $self->client->all( @$all_args );

	my @args = @$caller_args;

	# apply our filters
	my $nargs = scalar @args;
	if ( $nargs && $nargs  % 2 == 0 ) {
		my %opts = @args;
		foreach my $filter ( sort keys %opts ) {
			@all = grep { ref $_ && defined $_->{$filter} && $_->{$filter} eq $opts{$filter} } @all;
		}
	}

	# avoid to return a list when possible	
	return $all[0] if scalar @all <= 1;
	# return a list
	return @all;	

}


1;

__DATA__
---
keypairs:
  listable: 1
flavors:
  listable: 1



