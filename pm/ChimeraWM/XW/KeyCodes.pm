package ChimeraWM::XW::KeyCodes;

use strict;
use warnings;

use ChimeraWM::XW::KeyCodes;

sub new
{
    my $class = shift;
    my $x = shift;

    my $self =
    {
    };

    # TODO: pull keycode BS from $x

    bless $self, $class;

    return $self;
}

1;
