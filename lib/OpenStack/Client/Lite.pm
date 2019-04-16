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
    die "'image' name or id is required by create_vm" unless defined $opts{image};

    $opts{security_group} //= 'default'; # optional argument fallback to 'default'

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

    my $image;
    if ( _looks_valid_id( $opts{image} ) ) {
        $image = $self->image_from_uid( $opts{image} );
    }
    $image //= $self->image_from_name( $opts{image} );

    my $security_group;
    if ( _looks_valid_id( $opts{security_group} ) ) {
        $security_group = $self->security_groups( id => $opts{security_group} );
    }
    $security_group //= $self->security_groups( name => $opts{security_group} );
    die "Cannot find security_group for id/name '$opts{security_group}'" unless ref $security_group eq 'HASH' && _looks_valid_id( $security_group->{id} );


note ".... got flavor, and a network, image, group...";

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
