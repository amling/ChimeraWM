package ChimeraWM::Cfg;

use strict;
use warnings;

use File::Find;

# This module is how magic shit like this is going to work
#
# ChimeraWM->new(
#     init => sub { ... },
#     at_e1_foo => ChimeraWM::Cfg::SimpleFoo->newx("foo"),
#     at_e2_foo => ChimeraWM::Cfg::ComplexFoo->new(
#         bar1 => ChimeraWM::Cfg::Bar->new(arg => "baz"),
#         bar2 =>
#         {
#             "arg" => "baz"
#         },
#         bar2 =>
#         [
#             "arg" => "baz"
#         ],
#         subfoo => "other really simple foo",
#     )
#     at_e3_foo => "really simple foo",
# );

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

        return $class->newx(@arg);
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
