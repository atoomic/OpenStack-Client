#!perl

use strict;
use warnings;
use OpenStack::Client::Lite       ();

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;



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

    #note explain $api;

 #   note explain $api->flavors();
    {   
        note "get a single flavor";
        my $small = $api->flavors( name => 'small' );
        note explain $small;
        is $small => hash {
            field name => 'small';
            field links => D();
            field id    => D();
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
                field id    => D();
                end;
            }, "got flavor " . ( $flavor->{name} // 'undef' );
        }
    }

    
    {
        note "create a VM...";

        my $vm = $api->create_vm( 
            flavor   => 'small',
            key_name => 'openStack nico', 
            security_group => 'default',
            network  => 'Dev Infra initial gre network',
            #--network fb5c81fd-0a05-46bc-8a7e-cb94dc851bb4 
            wait => 1,
            name => 'testsuite xt/create_vm.t',
        );
    }



}


done_testing;