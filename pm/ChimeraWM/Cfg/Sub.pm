package ChimeraWM::Cfg::Sub;

use strict;
use warnings;

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

    $self->{'sub'}->(@_);
}

1;
