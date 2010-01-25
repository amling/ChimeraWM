package ChimeraWM::Cfg::BaseStructure;

use strict;
use warnings;

use ChimeraWM::Cfg::Base;

use base ('ChimeraWM::Cfg::Base');

sub new
{
    my $class = shift;
    my %args = @_;

    my $self = bless {}, $class;

    my $cfgs = $class->structure_keys();
    for my $cfg (@$cfgs)
    {
        my ($this_key, $args_key, $class, $has_default, $default) = @$cfg;

        # do our damnedest to load the file
        {
            my $classfile = $class;
            $classfile =~ s/::/\//g;
            $classfile .= "\.pm";
            eval { require $classfile; }
        }

        if(defined($args{$args_key}))
        {
            $self->{$this_key} = $class->newx($args{$args_key});
        }
        elsif($has_default == 1)
        {
            $self->{$this_key} = $class->newx($default);
        }
        elsif($has_default == -1)
        {
            die "Missing key $args_key in construction of $class";
        }
    }

    return $self;
}

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
