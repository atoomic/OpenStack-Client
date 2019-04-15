package OpenStack::Client::API::Service;

use strict;
use warnings;

use Test::More;
use Moo;

has 'auth' => ( is => 'ro', required => 1 );
has 'name' => ( is => 'ro', required => 1 );
has 'region' => ( is => 'ro', required => 1 );

has 'interface' => ( is => 'ro', default => 'public' ); # admin internal or public

has 'client' => ( is => 'ro', lazy => 1, default => sub {
	my ( $self ) = @_;
	
	return $self->auth->service( 
		'compute', 
		region => $self->region, 
		interface => $self->interface 
	 );
});

has 'version' => ( 'is' => 'ro', lazy => 1, default => \&BUILD_version );

sub BUILD_version {
	my ( $self ) = @_;
	
	my $url = $self->client->endpoint;
	note $url;
	if ( $url =~ m{/v([0-9\.]+)} ) {
		return $1;
	}
	return 'Default';
}


1;
