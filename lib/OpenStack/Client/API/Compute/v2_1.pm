package OpenStack::Client::API::Compute::v2_1;

use strict;
use warnings;

use Test::More;
use Moo;

extends 'OpenStack::Client::API::Compute';

1;

__DATA__
__
keypairs:
  uri: /os-keypairs
  key: keypairs
flavors:
  uri: /flavors
  key: flavors
