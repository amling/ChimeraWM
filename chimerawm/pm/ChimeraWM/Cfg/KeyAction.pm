package ChimeraWM::Cfg::KeyAction;

use strict;
use warnings;

use ChimeraWM::Cfg::Sub;

use base ('ChimeraWM::Cfg::Sub');

sub new_from_obj
{
    my $class = shift;
    my $obj = shift;

    if($obj->UNIVERSAL::isa('ChimeraWM::Cfg::KeyMap'))
    {
        return sub
        {
            my $wm = shift;

            $wm->enter_keymap($obj);
        };
    }

    return undef;
}

1;
