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
    $self->{'want_nop'} = 0;

    for my $key (keys(%args))
    {
        # sort of ghetto...
        if($key eq "_WANT_NOP")
        {
            $self->{'want_nop'} = 1;
        }

        my $value = $args{$key};

        $value = ChimeraWM::Cfg::new_magic('ChimeraWM::Cfg::KeyAction', $value);

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
            my ($keycode, $mod) = $xw->get_cache("KeyCodes")->interp_desc($key);
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
            my ($keycode, $mod) = $xw->get_cache("KeyCodes")->interp_desc($key);
            next unless(defined($keycode));
            next if($keycode != $event_keycode);
            next if($mod != $event_mod);

            return $action;
        }
    }

    # this is complicated
    if(!$self->{'want_nop'})
    {
        my $is_nop = $xw->get_cache("KeyCodes")->is_nop_key($event_keycode);
        if($is_nop)
        {
            my $reinstall = sub
            {
                my $wm = shift;
                my $is_root = shift;

                $wm->enter_keymap($self, $is_root);
            };
            return ChimeraWM::Cfg::new_magic('ChimeraWM::Cfg::Sub', $reinstall);
        }
    }

    if($is_root)
    {
        warn "Got keypress " . $xw->get_cache("KeyCodes")->interp_pair($event_keycode, $event_mod) . ", not present in root keymap?!  Ignoring...";
        return;
    }

    if(!defined($default))
    {
        # TODO: user-visible message (tunable)
        print "Got keypress " . $xw->get_cache("KeyCodes")->interp_pair($event_keycode, $event_mod) . ", not present in keymap?\n";
        return;
    }

    return $default;
}

ChimeraWM::Cfg::export_class_alias('keymap', __PACKAGE__);

1;
