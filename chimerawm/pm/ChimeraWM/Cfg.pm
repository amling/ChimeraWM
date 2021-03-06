package ChimeraWM::Cfg;

use strict;
use warnings;

use Data::Dumper;
use File::Find;

sub new_magic
{
    my $class = shift;
    my $arg0 = shift;
    my $arg = $arg0;

    while(1)
    {
        if(UNIVERSAL::isa($arg, $class))
        {
            return $arg;
        }

        my $newArg;

        my $ref = ref($arg);
        if(!defined($ref))
        {
            if($arg =~ /^-?\d+$/ && $class->UNIVERSAL::can('new_from_int'))
            {
                $newArg = $class->new_from_int($arg);
            }
            if($class->UNIVERSAL::can('new_from_str'))
            {
                $newArg = $class->new_from_str($arg);
            }
        }
        else
        {
            if($ref eq "CODE")
            {
                if($class->UNIVERSAL::can('new_from_sub'))
                {
                    $newArg = $class->new_from_sub($arg);
                }
            }
            elsif($ref eq "HASH")
            {
                if($class->UNIVERSAL::can('new_from_hash'))
                {
                    $newArg = $class->new_from_hash($arg);
                }
            }
            elsif($ref eq "ARRAY")
            {
                if($class->UNIVERSAL::can('new_from_array'))
                {
                    $newArg = $class->new_from_array($arg);
                }
            }
            else
            {
                if($class->UNIVERSAL::can('new_from_obj'))
                {
                    $newArg = $class->new_from_obj($arg);
                }
            }
        }

        if(defined($newArg))
        {
            $arg = $newArg;
            next;
        }

        die "Cannot construct " . $class . " instance from " . Dumper($arg0, $arg);
    }
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
