package OpenStack::Client::Lite::Helpers::DataAsYaml;

use strict;
use warnings;

use Test::More;

our $_CACHE;

### FIXME publish as its own package
###		and provide one import function which can old its own cache

sub LoadData {
	my ( $pkg ) = @_;

	$pkg //= ( caller(0) )[0];

	return _load_yaml_for_pkg( $pkg );
}

sub _load_yaml_for_pkg {
	my ( $pkg ) = @_;

	die "undefined package" unless defined $pkg;

	$_CACHE //= {};
	return $_CACHE->{$pkg} if $_CACHE->{$pkg};

	my $data;
	{
		local $/;
		my $fh = eval '\*'.$pkg.'::DATA';
		$data = <$fh>;
	}

	return unless defined $data;

	$_CACHE->{$pkg} = YAML::XS::Load( $data );

	return $_CACHE->{$pkg};
}

1;