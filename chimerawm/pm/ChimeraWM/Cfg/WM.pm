package ChimeraWM::Cfg::WM;

use strict;
use warnings;

use ChimeraWM::Cfg::BaseStructure;
use ChimeraWM::XW;
use Data::Dumper;
use X11::Protocol;

use base ('ChimeraWM::Cfg::BaseStructure');

sub structure_keys
{
    return
    [
        ['init', 'init', 'ChimeraWM::Cfg::Sub', 1, sub { }],
        ['root_keymap', 'keymap', 'ChimeraWM::Cfg::KeyMap', 1, {}],
    ];
}

sub imain
{
    my $self = shift;

    my $x = X11::Protocol->new();
    my $xw = ChimeraWM::XW->new($x);
    $x->event_handler('queue');
    my $ssr = $x->pack_event_mask('SubstructureRedirect', 'SubstructureNotify');
    $x->ChangeWindowAttributes($x->{'root'}, 'event_mask' => $x->event_window_mask($ssr));

    $self->{'x'} = $x;
    $self->{'xw'} = $xw;

    my ($dummy1, $dummy2, @clients) = $x->QueryTree($x->{'root'});
    for my $client (@clients)
    {
        my (%attr) = $x->GetWindowAttributes($client);
        if($attr{'map_state'} ne 'Viewable')
        {
            # maybe we need to watch this?  it could jump straight to configure
            # and maybe confuse us a bit.
            next;
        }

        # TODO: take note of/move $client as a number of a mapped window
    }

    $self->{'init'}->call();

    $self->enter_keymap($self->{'root_keymap'}, 1, 1);

    while(1)
    {
        my %event = $x->next_event();
        next unless(%event);
        if($event{'name'} eq 'MapRequest')
        {
            # TODO: maybe dishonour, maybe move, note taken down in MapNotify
            $x->MapWindow($event{'window'});
        }
        elsif($event{'name'} eq 'ConfigureRequest')
        {
            # TODO: maybe dishonour, maybe [re]move, note taken down in ConfigureNotify
            my %cfg;
            for my $key ('x', 'y', 'width', 'height', 'sibling', 'border_width', 'stack_mode')
            {
                if(defined($event{$key}))
                {
                    $cfg{$key} = $event{$key};
                }
            }
            $x->ConfigureWindow($event{'window'}, %cfg);
        }
        elsif($event{'name'} eq 'CreateNotify')
        {
            # TODO: note
        }
        elsif($event{'name'} eq 'MapNotify')
        {
            # TODO: note, make sure to handle even if we've never seen it before
        }
        elsif($event{'name'} eq 'ConfigureNotify')
        {
            # TODO: note, make sure to handle even if we've never seen it before
        }
        elsif($event{'name'} eq 'UnmapNotify')
        {
            # TODO: note, make sure to handle even if we've never seen it before
        }
        elsif($event{'name'} eq 'DestroyNotify')
        {
            # TODO: note, make sure to handle even if we've never seen it before
        }
        elsif($event{'name'} eq 'KeyPress')
        {
            my ($km, $is_root) = $self->exit_keymap();
            my $desc = $xw->get_cache("KeyCodes")->interp_pair($event{'detail'}, $event{'state'});
            if(!defined($km))
            {
                warn "Got KeyPress of $desc with no current keymap?!";
            }
            else
            {
                my $action = $km->interp($xw, $is_root, \%event);
                if(defined($action))
                {
                    # TODO: action should probably get to know the keypress which it will probably need in some intelligible form
                    # TODO: very hard to decide exactly what action should know about, maybe some sort of infernal KeyActionEvent object?
                    $action->call($self, $is_root);
                }
            }

            $self->enter_keymap($self->{'root_keymap'}, 1, 1);
        }
        elsif($event{'name'} eq 'KeyRelease')
        {
        }
        else
        {
            print "Unknown event: " . Dumper(\%event);
        }
    }

    return $self->{'exit'} || 0;
}

sub enter_keymap
{
    my $self = shift;
    my $km = shift;
    my $is_root = shift || 0;
    my $is_optional = shift || 0;

    return if($self->{'current_keymap'} && $is_optional);

    $self->{'current_keymap'} = $km;
    $self->{'current_keymap_is_root'} = $is_root;
    $km->grab($self->{'xw'}, $is_root)
}

sub exit_keymap
{
    my $self = shift;

    my $km = $self->{'current_keymap'};
    my $is_root = $self->{'current_keymap_is_root'};

    $self->{'current_keymap'} = undef;
    if(defined($km))
    {
        $self->{'x'}->UngrabKey('Any', 'Any', $self->{'x'}->{'root'}, 0, 'Asynchronous', 'Asynchronous');
    }

    return ($km, $is_root);
}

ChimeraWM::Cfg::export_class_alias('wm', __PACKAGE__);

1;
