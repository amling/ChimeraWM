package ChimeraWM::Cfg::Base;

use strict;
use warnings;

use Data::Dumper;

sub newx
{
    my $class = shift;
    my $arg = shift;

    if(UNIVERSAL::isa($arg, $class))
    {
        return $arg;
    }

    my $self;
    if($arg =~ /^-?\d+$/ && $class->UNIVERSAL::can('new_from_int'))
    {
        $self = $class->new_from_int($arg);
    }
    elsif(!defined(ref($arg)) && $class->UNIVERSAL::can('new_from_str'))
    {
        $self = $class->new_from_str($arg);
    }
    elsif(ref($arg) eq "CODE" && $class->UNIVERSAL::can('new_from_sub'))
    {
        $self = $class->new_from_sub($arg);
    }
    elsif(ref($arg) eq "HASH" && $class->UNIVERSAL::can('new_from_hash'))
    {
        $self = $class->new_from_hash($arg);
    }
    elsif(ref($arg) eq "ARRAY" && $class->UNIVERSAL::can('new_from_array'))
    {
        $self = $class->new_from_array($arg);
    }
    else
    {
        die "Cannot construct " . $class . " instance from " . Dumper($arg);
    }

    return $self;
}

1;
