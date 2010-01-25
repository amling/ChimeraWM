package ChimeraWM::Cfg::KeyMap;

use strict;
use warnings;

use ChimeraWM::Cfg::BaseHash;
use ChimeraWM::Cfg::KeyAction;

use base ('ChimeraWM::Cfg::BaseHash');

sub new
{
    my $class = shift;
    my %args = @_;

    my $self = bless {}, $class;

    $self->{'actions'} = {};

    for my $key (keys(%args))
    {
        my $value = $args{$key};

        $value = ChimeraWM::Cfg::new_magic('ChimeraWM::Cfg::KeyAction', $value);

        $self->{'actions'}->{$key} = $value;
    }
}

1;
