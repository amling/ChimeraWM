package ChimeraWM::XW;

use strict;
use warnings;

use ChimeraWM::XW::KeyCodes;

# Holder for X11::Protocol object, used for caching shiz

sub new
{
    my $class = shift;
    my $x = shift;

    my $self =
    {
        'x' => $x,
    };

    bless $self, $class;

#$self->get_cache("KeyCodes");

    return $self;
}

sub get_x
{
    my $self = shift;

    return $self->{'x'};
}

sub get_cache
{
    my $self = shift;
    my $class = "ChimeraWM::XW::" . shift;

    my $r = $self->{$class};
    if(!defined($r))
    {
        $r = $self->{$class} = $class->new($self->{'x'});
    }

    return $r;
}

1;
