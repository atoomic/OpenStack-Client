package OpenStack::Client::Lite::Roles::Listable;

use strict;
use warnings;

use Test::More;
use Moo::Role;

sub _list {
	my ( $self, $all_args, $caller_args ) = @_;

	my @all;
	{
		my ( $uri, @extra ) = @$all_args;
		$uri = $self->root_uri( $uri );
		@all = $self->client->all( $uri, @extra );	
	}
	
	my @args = @$caller_args;

	# apply our filters
	my $nargs = scalar @args;
	if ( $nargs && $nargs  % 2 == 0 ) {
		my %opts = @args;
		foreach my $filter ( sort keys %opts ) {
			my @keep;
			my $filter_isa = ref $opts{$filter} // '';
			foreach my $candidate ( @all ) {
				next unless ref $candidate;			
				if ( $filter_isa eq 'Regexp' ) {
					# can use a regexp as a filter
					next unless $candidate->{$filter} && $candidate->{$filter} =~ $opts{$filter};
				} else {
					# otherwise do one 'eq' check
					next unless $candidate->{$filter} && $candidate->{$filter} eq $opts{$filter};
				}

				push @keep, $candidate;
			}

			@all = @keep;
			# grep { ref $_ && defined $_->{$filter} && $_->{$filter} eq $opts{$filter} } @all;
		}
	}

	# avoid to return a list when possible	
	return $all[0] if scalar @all <= 1;
	
	# return a list
	return @all;
}

1;