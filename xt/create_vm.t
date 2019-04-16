#!perl

use strict;
use warnings;
use OpenStack::Client::Lite       ();

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use OpenStack::Client ();

OpenStack::Client::enable_debug();

my $VALID_ID = match qr{^[a-f0-9\-]+$};

SKIP: {
    skip "OS_AUTH_URL unset, please source one openrc.sh file before." unless $ENV{OS_AUTH_URL};

    my $endpoint = $ENV{OS_AUTH_URL} or die "Missing OS_AUTH_URL";
    
    my $api = OpenStack::Client::Lite->new( 
        $endpoint,
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

    is( $api, 
        object {
            prop blessed => 'OpenStack::Client::Lite';

            field auth => object {
                prop blessed => 'OpenStack::Client::Auth::v3';
            };
            field route => object {
                  prop blessed => 'OpenStack::Client::Lite::Routes';
            };
            field debug => 0;
            end;
        },
        "can create OpenStack::Client::Lite object"
    ) or die;

    is [ $api->services ], [ 
          'compute',
          'identity',
          'image',
          'network',
          'placement',
          'volume',
          'volumev2',
          'volumev3'
    ], "list os services from auth object";

    #note explain $api->auth->catalog;

 #   note explain $api->flavors();
    {   
        note "get a single flavor";
        my $small = $api->flavors( name => 'small' );
        note explain $small;
        is $small => hash {
            field name => 'small';
            field links => D();
            field id    => $VALID_ID;
            end;
        }, "get a flavor 'small'";
    } 

    {
        note "get all flavors";
        my @flavors = $api->flavors();
        ok scalar @flavors > 1, "got more than one flavor";
        foreach my $flavor ( @flavors ) {
            is $flavor => hash {
                field name => D();
                field links => D();
                field id    => $VALID_ID;
                end;
            }, "got flavor " . ( $flavor->{name} // 'undef' );
        }
    }


    {
        note "testing networks";

        my @networks = $api->networks();
        ok scalar @networks, "got some networks";

        my $valid_network = hash {
            field created_at => D();
            field updated_at => D();
            field id => $VALID_ID;
            field project_id => $VALID_ID;
            field name => D();
            field subnets => D();
            etc;
        };

        is $networks[0], $valid_network, "network has some expected information";

        my $id = $networks[0]->{id};
        my $network = $api->networks( id => $id );
        is $network, $valid_network, "network from id looks valid";
        is $network->{id}, $id, "network id match";

        my $network_by_name = $api->networks( name => 'Dev Infra initial gre network' );
        if ( $network_by_name ) {
            is $network_by_name, $valid_network, "got a network by name";

            my $network_by_name_regex = $api->networks( name => qr{^Dev Infra} );

            ## subnets are not sorted... and can come in a random order
            $network_by_name->{subnets} = [];
            $network_by_name_regex->{subnets} = [];

            like $network_by_name_regex, $network_by_name, "can get a network using a regex for the name";

        }    
    }

    
    {
        note "create a VM...";

        my $vm = $api->create_vm( 
            flavor   => 'small',
            key_name => 'openStack nico', 
            security_group => 'default',
            network  => 'Dev Infra initial gre network',
            # or network  => qr{Dev Infra}',
            # or network  => 'fb5c81fd-0a05-46bc-8a7e-cb94dc851bb4 ',

            #--network fb5c81fd-0a05-46bc-8a7e-cb94dc851bb4 
            wait => 1,
            name => 'testsuite xt/create_vm.t',
        );
    }


    #note explain $api;
#   {
#     'admin_state_up' => $VAR1->[0]{'admin_state_up'},
#     'availability_zone_hints' => [],
#     'availability_zones' => [
#       'nova'
#     ],
#     'created_at' => '2019-04-09T21:40:09Z',
#     'description' => '',
#     'id' => 'fb5c81fd-0a05-46bc-8a7e-cb94dc851bb4',
#     'ipv4_address_scope' => undef,
#     'ipv6_address_scope' => undef,
#     'mtu' => 1458,
#     'name' => 'Dev Infra initial gre network',
#     'project_id' => '76fb18aec577491bb676b482f5671352',
#     'revision_number' => 4,
#     'router:external' => $VAR1->[0]{'is_default'},
#     'shared' => $VAR1->[0]{'is_default'},
#     'status' => 'ACTIVE',
#     'subnets' => [
#       'a3267fc9-0f73-45e1-9296-cb39805aa2f5',
#       '5b1e5c0e-62cc-4d64-ae79-43ce763506c4'
#     ],
#     'tags' => [],
#     'tenant_id' => '76fb18aec577491bb676b482f5671352',
#     'updated_at' => '2019-04-09T21:45:51Z'
#   }

}


done_testing;

__END__

http://service01a-c2.cpanel.net:8774/v2.1/os-keypairs

> openstack server create --image 170fafa5-1329-44a3-9c27-9bb77b77206d 
    --flavor small 
    --key-name 'openStack nico' 
    --security-group default 
    --network fb5c81fd-0a05-46bc-8a7e-cb94dc851bb4 
    --wait testFromAPI2 
    --debug

REQ: curl -g -i -X GET http://service01a-c2.cpanel.net:8774/v2.1/flavors -H "Accept: application/json" -H "User-Agent: p
REQ: curl -g -i -X GET http://service01a-c2.cpanel.net:8774/v2.1/flavors/1ffe5704-06e5-4c2d-828c-496a06f477a4 -H "Accept
REQ: curl -g -i -X GET http://service01a-c2.cpanel.net:9696/v2.0/networks/fb5c81fd-0a05-46bc-8a7e-cb94dc851bb4 -H "User-
REQ: curl -g -i -X GET http://service01a-c2.cpanel.net:9696/v2.0/security-groups/default -H "User-Agent: openstacksdk/0.
REQ: curl -g -i -X GET http://service01a-c2.cpanel.net:9696/v2.0/security-groups -H "Accept: application/json" -H "User-
REQ: curl -g -i -X POST http://service01a-c2.cpanel.net:8774/v2.1/servers -H "Accept: application/json" -H "Content-Type
REQ: curl -g -i -X POST http://service01a-c2.cpanel.net:8774/v2.1/servers -H "Accept: application/json" 
    -H "Content-Type: application/json" -H "User-Agent: python-novaclient" 
    -H "X-Auth-Token: {SHA256}2a39527dd72e1c2bf48cf33883e87c18a81d12e46d1d55e5ece4f8f1437fb3a8" 
    -H "X-OpenStack-Nova-API-Version: 2.1" 
    -d '{"server": {"name": "testFromAPI2", "imageRef": "170fafa5-1329-44a3-9c27-9bb77b77206d", "flavorRef": "1ffe5704-06e5-4c2d-828c-496a06f477a4", "key_name": "openStack nico", "min_count": 1, "max_count": 1, "security_groups": [{"name": "6f86e4c2-a498-4f4d-afe9-a2def5ada8c8"}], "networks": [{"uuid": "fb5c81fd-0a05-46bc-8a7e-cb94dc851bb4"}]}}'

REQ: curl -g -i -X GET http://service01a-c2.cpanel.net:8774/v2.1/servers/6ac4b745-1501-46a8-9533-56e0a88ee3a1 -H "Accept
... [ multiple times ?? /// wait ]

