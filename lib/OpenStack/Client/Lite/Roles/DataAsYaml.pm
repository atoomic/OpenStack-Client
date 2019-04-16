package OpenStack::Client::Lite::Roles::DataAsYaml;

use strict;
use warnings;

use Test::More;
use Moo::Role;

use YAML::XS ();

has 'DataAsYaml' => ( 'is' => 'ro', default => \&_build_yaml );

our $_CACHE;

sub _build_yaml {
	my ( $self ) = @_;

	my $pkg = ref($self) || $self;

	$_CACHE //= {};
	return $_CACHE->{$pkg} if $_CACHE->{$pkg};

	my $data;
	{
		local $/;
		my $fh = eval '\*'.$pkg.'::DATA';
		$data = <$fh>;
	}
	$_CACHE->{$pkg} = YAML::XS::Load( $data );

	return $_CACHE->{$pkg};
}

1;