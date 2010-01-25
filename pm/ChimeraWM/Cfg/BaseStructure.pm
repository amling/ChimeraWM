package ChimeraWM::Cfg::BaseStructure;

use strict;
use warnings;

use ChimeraWM::Cfg::BaseHash;

use base ('ChimeraWM::Cfg::BaseHash');

sub new
{
    my $class = shift;
    my %args = @_;

    my $self = bless {}, $class;

    my $cfgs = $class->structure_keys();
    for my $cfg (@$cfgs)
    {
        my ($this_key, $args_key, $class, $has_default, $default) = @$cfg;

        if(defined($args{$args_key}))
        {
            $self->{$this_key} = ChimeraWM::Cfg::new_magic($class, delete($args{$args_key}));
        }
        elsif($has_default == 1)
        {
            $self->{$this_key} = ChimeraWM::Cfg::new_magic($class, $default);
        }
        elsif($has_default == -1)
        {
            die "Missing key $args_key in construction of $class";
        }
    }

    if(%args)
    {
        die "Bad keys in args to construction of $class: " . join(", ", sort(keys(%args)));
    }

    return $self;
}

1;
