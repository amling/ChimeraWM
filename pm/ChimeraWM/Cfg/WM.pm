package ChimeraWM::Cfg::WM;

use strict;
use warnings;

use ChimeraWM::Cfg::BaseStructure;

use base ('ChimeraWM::Cfg::BaseStructure');

sub structure_keys
{
    return
    [
        ['init', 'init', 'ChimeraWM::Cfg::Sub', 1, sub { }],
    ];
}

sub imain
{
    my $self = shift;

    $self->{'init'}->call();

    # TODO: some sort of eventish loopish thing

    return $self->{'exit'} || 0;
}

ChimeraWM::Cfg::export_class_alias('wm', __PACKAGE__);

1;
