package ChimeraWM::Cfg::BaseHash;

use strict;
use warnings;

use ChimeraWM::Cfg::Base;

use base ('ChimeraWM::Cfg::Base');

sub new_from_hash
{
    my ($class, $hashref) = @_;

    return $class->new(%$hashref);
}

sub new_from_array
{
    my ($class, $arrayref) = @_;

    return $class->new(@$arrayref);
}

1;
