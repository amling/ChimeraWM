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
        ['keymap', 'keymap', 'ChimeraWM::Cfg::KeyMap', 1, {}],
    ];
}

sub imain
{
    my $self = shift;

    $self->{'init'}->call();

    my $x = X11::Protocol->new();
    my $xw = ChimeraWM::XW->new($x);
    $x->event_handler('queue');
    my $ssr = $x->pack_event_mask('SubstructureRedirect', 'SubstructureNotify');
    $x->ChangeWindowAttributes($x->{'root'}, 'event_mask' => $x->event_window_mask($ssr));

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

    my $current_keymap = $self->{'keymap'};
    $current_keymap->grab($xw, 1);

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
            my $km = $current_keymap;
            $current_keymap = undef;
            $x->UngrabKey('Any', 'Any', $x->{'root'}, 0, 'Asynchronous', 'Asynchronous');

            my $action = $km->interp($xw, 1, \%event);
            if(defined($action))
            {
                $action->call();
            }

            if(!defined($current_keymap))
            {
                $current_keymap = $self->{'keymap'};
                $current_keymap->grab($xw, 1);
            }
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

ChimeraWM::Cfg::export_class_alias('wm', __PACKAGE__);

1;
