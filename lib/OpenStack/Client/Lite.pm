package OpenStack::Client::Lite;

use strict;
use warnings;

use OpenStack::Client::Auth ();
use OpenStack::Client::Lite::Routes ();
use Scalar::Util qw/weaken/;

use Moo;
use Test::More;

has 'debug' => ( is => 'rw', default  => 0 );
has 'auth'  => ( is => 'ro', required => 1, handles => [ qw/services/ ] );

has 'route' => (
    is => 'ro',
    default => sub {
        my ($self) = @_;

        # weaken our circular dependency
        my $auth = $self->auth;
        weaken($auth);

        return OpenStack::Client::Lite::Routes->new( auth => $auth );
    },
    handles => [ OpenStack::Client::Lite::Routes->list_all() ],
);

around BUILDARGS => sub {
    my ( $orig, $class, @args ) = @_;

    die "Missing arguments to create Auth object" unless scalar @args;

    # automagically build the OpenStack::Client::Auth from existing args
    return { auth => OpenStack::Client::Auth->new(@args) };
};


sub create_vm {
    my ( $self, %opts ) = @_;

    die "flavor name is required to create_vm" unless defined $opts{flavor};

    my ( $flavor ) = $self->flavors( name => $opts{flavor} );

}

sub add_floating_ip_to_server {

}

sub destroy_vm {

}


1;

__END__
