package ChimeraWM::Cfg::Sub;

use strict;
use warnings;

use ChimeraWM::Cfg::Base;

use base ('ChimeraWM::Cfg::Base');

sub new_from_sub
{
    my $class = shift;
    my $sub = shift;

    my $self = bless {}, $class;

    $self->{'sub'} = $sub;

    return $self;
}

sub call
{
    my $self = shift;

    $self->{'sub'}->();
}

1;
