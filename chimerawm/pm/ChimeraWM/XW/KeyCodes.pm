package ChimeraWM::XW::KeyCodes;

use strict;
use warnings;

use ChimeraWM::XW::KeyCodes;

sub new
{
    my $class = shift;
    my $x = shift;

    my %name_to_kc;
    my %kc_to_cname;
    my $min = $x->min_keycode();
    my $max = $x->max_keycode();
    my (@keys) = $x->GetKeyboardMapping($min, ($max - $min) + 1);
    for(my $keycode = $min; $keycode <= $max; ++$keycode)
    {
        my $kss = $keys[$keycode - $min] || die;
        my $first = 1;
        for(my $i = 0; $i < @$kss; ++$i)
        {
            my $ks = $kss->[$i];
            next if($ks == 0);
            my $name = "K$ks";
            if(32 <= $ks && $ks <= 126)
            {
                $name = chr($ks);
            }
            if($first)
            {
                $kc_to_cname{$keycode} = $name;
#print "CNAME for $keycode is $name\n";
                $first = 0;
            }
            $name_to_kc{$name} = $keycode;
#print "KeyCode for $name is $keycode\n";
        }
    }

    my $self =
    {
        'name_to_kc' => \%name_to_kc,
        'kc_to_cname' => \%kc_to_cname,
        'name_to_warned' => {},
    };

    bless $self, $class;

    return $self;
}

sub name_to_kc
{
    my $self = shift;
    my $name = shift;

    my $kc = $self->{'name_to_kc'}->{$name};
    if(defined($kc))
    {
        return $kc;
    }

    my $warned = $self->{'name_to_warned'}->{$name};
    if($warned)
    {
        return undef;
    }

    warn "Unknown key name: $name";

    $self->{'name_to_warned'}->{$name} = 1;

    return undef;
}

1;
