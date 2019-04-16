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
    die "'name' field is required by create_vm" unless defined $opts{name};

    $opts{security_group} //= 'default'; # optional argument fallback to 'default'

    # get the flavor by id or name
    my $flavor = $self->look_by_id_or_name( flavors => $opts{flavor} );

    # get the network by id or name
    my $network = $self->look_by_id_or_name( networks => $opts{network} );

    my $image;
    if ( _looks_valid_id( $opts{image} ) ) {
        $image = $self->image_from_uid( $opts{image} );
    }
    $image //= $self->image_from_name( $opts{image} );

    my $security_group = $self->look_by_id_or_name( security_groups => $opts{security_group} );

    note "---"x10;
    # note flavor => explain $flavor;
    # note network => explain $network;
    # note security_group => explain $security_group;
    note ".... got flavor, and a network, image, group...";

    my @extra;
    if ( defined $opts{key_name} ) {
        push @extra, ( key_name => $opts{key_name} );
    }

    my $server = $self->create_server( 
        name => $opts{name}, 
        imageRef => $image->{id},
        flavorRef => $flavor->{id},
        min_count => 1,
        max_count => 1,
        security_groups => [ { name => $security_group->{id} } ],
        networks => [ { uuid => $network->{id} } ],
        @extra,
    );

    note explain $server;

    my $server_uid = $server->{server}->{id};
    die "Failed to create server" unless _looks_valid_id( $server_uid );

    # we are going to wait for 5 minutes fpr the server
    my $wait_time_limit = $opts{wait_time_limit} // 60 * 5;

    my $now      = time();
    my $max_time = $now + $wait_time_limit;
    my $server_is_ready;

    # TODO: maybe add one alarm...
    while ( time() < $max_time ) {

        my $server = $self->server_from_uid( $server_uid );
        if ( ref $server  
            && $server->{status} && $server->{status} && lc($server->{status}) eq 'active' ) 
        {
            $server_is_ready = 1;
            last;
        }
        sleep 5;
    }

    # now add one IP to the server
    if ( $server_is_ready ) {
        
    }
    note "need to add one IP to the server...";



    return $server;
}

sub look_by_id_or_name {
    my ( $self, $helper, $id_or_name ) = @_;

    my $entry;
    if ( _looks_valid_id( $id_or_name ) ) {
        $entry = $self->can($helper)->( $self, id => $id_or_name );
    }
    $entry //= $self->can($helper)->( $self, name => $id_or_name );

    if ( ref $entry ne 'HASH' || !_looks_valid_id( $entry->{id} ) ) {
        die "Cannot find '$helper' for id/name '$id_or_name'";
    }

    return $entry;
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