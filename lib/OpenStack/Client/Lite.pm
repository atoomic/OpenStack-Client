package OpenStack::Client::Lite;

use strict;
use warnings;

use OpenStack::Client::Lite::Routes   ();
use Scalar::Util qw/weaken/;

use Moo;
use Test::More;

has 'debug'           => ( is => 'rw', default => 0 );
has 'auth' => (
	is      => 'ro',
	required => 1,
#	handles => [qw/version/],
);

has 'route' => (
	is => 'ro',
#	lazy    => 1,
	default => sub { 
		my ( $self ) = @_;

		# weaken our circular dependency
		my $auth = $self->auth;
		weaken( $auth );

		return OpenStack::Client::Lite::Routes->new( auth => $auth );
	}, 
	handles => [ OpenStack::Client::Lite::Routes::list_all() ],
);

around BUILDARGS => sub {
  my ( $orig, $class, @args ) = @_;

  die "Missing arguments to create Auth object" unless scalar @args;
  return { auth =>  OpenStack::Client::Auth->new( @args ) };
};


1;

__END__


# right now I can login using this

my $auth = OpenStack::Client::Auth->new($endpoint,
        'username' => $ENV{'OS_USERNAME'},
        'password' => $ENV{'OS_PASSWORD'},
        version => 3,
        scope => {
            project => {
                name => $ENV{'OS_PROJECT_NAME'},
                domain => { id => 'default' },
            }
        }
    );
 
# then I would need to know where to go to do my request

my $api = $auth->service('compute',
    'region' => $ENV{'OS_REGION_NAME'}
);

my @keypairs = $api->all('/os-keypairs', 'keypairs');    

# my idea is to abstract this
my $api = OpenStack::Client::Lazy->new( auth => $auth ); # or ::Easy ?
my @keypairs = $api->keypairs();




OpenStack::API::

API.pm 

keypairs => {
    service  => 'compute',
    listable => 1,
}

API/Compute/v2_1.pm

keypairs => {
    uri => '/os-keypairs',
    key => 'keypairs',
}

compute => 