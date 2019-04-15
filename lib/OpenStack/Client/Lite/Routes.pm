package OpenStack::Client::Lite::Routes;

use strict;
use warnings;

use Test::More;
use Moo;

use OpenStack::Client::API ();
use YAML::XS;

has 'auth' => (
	is      => 'ro',
	#required => 1,
);

our $ROUTES;
BEGIN { $ROUTES = {} }

# FIXME -> move to a role Role::Read::DATA::YAML
# provide one accessor data

sub init_once {
	my $data;
	{
		local $/;
		$data = <DATA>;
	}
	$ROUTES = Load( $data );

	{
		no warnings 'redefine';
		*init_once = sub {};
	}
	return 1;
}

# cannot read from data block at compile time
INIT { init_once() }

sub list_all {
	init_once();
	return sort keys %$ROUTES;
}

sub DESTROY {
}

our $AUTOLOAD;
sub AUTOLOAD {
	my ( @args ) = @_;
	my $call_for = $AUTOLOAD;

	$call_for =~ s/.*:://;

	#init_once();

	if ( my $route = $ROUTES->{$call_for} ) {
		note "calling from AUTOLOAD.... ", $call_for;
		die "$call_for is a method call" unless ref $args[0] eq __PACKAGE__;
		my $self = shift @args;

		my $service = $self->service( 
			$route->{service}			
		);

		my $controller = $service->can($call_for) or die "Invalid route '$call_for' for service '".ref($service)."'";

		return $controller->( $service, @args );

		#return $service->dispatch( $call_for, @args );
	}

	die "Unknown function $call_for from AUTOLOAD";
}

sub service {
	my ( $self, $name ) = @_;

	# cache the service once
	my $k = '_service_' . $name;
	if ( ! $self->{$k} ) {
		$self->{$k} = OpenStack::Client::API::get_service( 
			name => $name, auth => $self->auth, region => $ENV{'OS_REGION_NAME'}
		);
	}	

	return $self->{$k};
}

1;

## this data block describes the routes
#	this could be moved to a file...
__DATA__
---
keypairs:
  listable: 1
  service: compute
flavors:
  listable: 1
  service: compute


