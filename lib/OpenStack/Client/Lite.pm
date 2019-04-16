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

    die "'flavor' name or id is required by create_vm" unless defined $opts{flavor};
    die "'network' name or id is required by create_vm" unless defined $opts{network};

    # get the flavor by id or name...
    my $flavor;
    if ( _looks_valid_id( $opts{flavor} ) ) {
        $flavor = $self->flavors( id => $opts{flavor} );
    }
    $flavor //= $self->flavors( name => $opts{flavor} );

    die "Cannot find flavor for id/name '$opts{flavor}'" unless ref $flavor eq 'HASH' && _looks_valid_id( $flavor->{id} );

    # get the network by id or name

    my $network;
    if ( _looks_valid_id( $opts{network} ) ) {
        $network = $self->networks( id => $opts{network} );
    }
    $network //= $self->networks( name => $opts{network} );
    die "Cannot find network for id/name '$opts{network}'" unless ref $network eq 'HASH' && _looks_valid_id( $network->{id} );

note ".... got flavor, and a network";

    return;
}

sub _looks_valid_id {
    my ( $id ) = @_;

    return unless defined $id;
    return if ref $id;

    my $VALID_ID = qr{^[a-f0-9\-]+$}i;

    return $id =~ $VALID_ID;
}

sub add_floating_ip_to_server {

}

sub destroy_vm {

}


1;

__END__
