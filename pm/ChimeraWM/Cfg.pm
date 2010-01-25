package ChimeraWM::Cfg;

use strict;
use warnings;

use Data::Dumper;
use File::Find;

sub new_magic
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

sub eval_cfg
{
    my $class = shift;
    my $code = shift;

    return eval $code;
}

sub export_class_alias
{
    my ($alias, $class) = @_;

    my $sub = sub
    {
        my (@arg) = @_;

        if(@arg > 1)
        {
            @arg = ([@arg]);
        }

        return new_magic($class, @arg);
    };

    {
        no strict ('refs');

        *{"ChimeraWM::Cfg::$alias"} = $sub;
    }
}

{
    for my $root (@INC)
    {
        my $options =
        {
            'follow' => 1,
            'no_chdir' => 1,
            'wanted' => sub
            {
                return unless(-f);
                return unless(/\.pm$/);
                #return if($INC->{$_});

                s/^\Q$root\E\///;

                eval
                {
                    require $_;
                };
                warn "Failed to load Cfg module $_: $@" if($@);
            },
        };

        find($options, "$root/ChimeraWM/Cfg");
    }
}

1;
