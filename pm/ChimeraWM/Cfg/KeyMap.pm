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

sub grab
{
    my $self = shift;
    my $xw = shift;

    # TODO: grab self all over the X server
}

sub interp
{
    my $self = shift;
    my $xw = shift;
    my $event = shift;

    # TODO: interpret event in the keymap and return the associated action (or
    # undef on a miss)

    # TODO: oh shift, what does X even let us do on a miss?
    # TODO: maybe disallow misses?  root shouldn't have them and others should handle them via default
}

1;
