package ChimeraWM::Cfg::KeyMap;

use strict;
use warnings;

use ChimeraWM::Cfg::BaseHash;

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

        $value = ChimeraWM::Cfg::new_magic('ChimeraWM::Cfg::Sub', $value);

        $self->{'actions'}->{$key} = $value;
    }

    return $self;
}

sub grab
{
    my $self = shift;
    my $xw = shift;
    my $is_root = shift;

    my $x = $xw->get_x();

    if(!$is_root)
    {
        $x->GrabKey('Any', 'Any', $x->{'root'}, 0, 'Asynchronous', 'Asynchronous');
        return;
    }

    for my $key (keys(%{$self->{'actions'}}))
    {
        if($key eq "*")
        {
            warn "Found * action in default keymap?!  Ignoring...";
        }
        else
        {
            my ($keycode, $mod) = $self->interp_desc($xw, $key);
            $x->GrabKey($keycode, $mod, $x->{'root'}, 0, 'Asynchronous', 'Asynchronous');
        }
    }
}

sub interp
{
    my $self = shift;
    my $xw = shift;
    my $is_root = shift;
    my $event = shift;

    my $event_keycode = $event->{'detail'};
    my $event_mod = $event->{'state'};

    my $default;
    my $actions = $self->{'actions'};
    for my $key (keys(%$actions))
    {
        my $action = $actions->{$key};
        if($key eq "*")
        {
            $default = $action;
        }
        else
        {
            my ($keycode, $mod) = $self->interp_desc($xw, $key);
            next unless(defined($keycode));
            next if($keycode != $event_keycode);
            next if($mod != $event_mod);

            return $action;
        }
    }

    # TODO: interpret to be human readable (will need reverse mod table)
    if($is_root)
    {
        warn "Got keypress $event_keycode/$event_mod, not present in root keymap?!  Ignoring...";
        return;
    }

    if(!defined($default))
    {
        # TODO: user-visible message (tunable)
        print "Got keypress $event_keycode/$event_mod, not present in keymap?\n";
        return;
    }

    return $default;
}

sub interp_desc
{
    my $self = shift;
    my $xw = shift;
    my $key = shift;

    # TODO: less ghetto?
    my $mod = 0;
    while(1)
    {
        my $key0 = $key;
        $mod |= 0x01 if($key =~ s/^(shift|s)[-+]//i);
        $mod |= 0x04 if($key =~ s/^(ctrl|control|c)[-+]//i);
        # TODO: more mods (alt, modN)
        last if($key eq $key0);
    }

    my $kc = $xw->get_cache("KeyCodes")->name_to_kc($key);
    if(!defined($kc))
    {
        return ();
    }

    return ($kc, $mod);
}

1;
