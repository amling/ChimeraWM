package ChimeraWM::XW::KeyCodes;

use strict;
use warnings;

use ChimeraWM::XW::KeyCodes;

my %special_name =
(
    65505 => ["ShiftL",              1],
    65506 => ["ShiftR",              1],
    65507 => ["ControlL",            1],
    65508 => ["ControlR",            1],
    65509 => ["CapsLock",            1],
    65510 => ["ShiftLock",           1],
    65511 => ["MetaL",               1],
    65512 => ["MetaR",               1],
    65513 => ["AltL",                1],
    65514 => ["AltR",                1],
    65515 => ["SuperL",              1],
    65516 => ["SuperR",              1],
    65517 => ["HyperL",              1],
    65518 => ["HyperR",              1],
);

sub new
{
    my $class = shift;
    my $x = shift;

    my %name_to_kc;
    my %kc_to_cname;
    my %kc_to_is_nop;
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
            my $nop = 0;
            if(32 <= $ks && $ks <= 126)
            {
                $name = chr($ks);
            }
            elsif(exists($special_name{$ks}))
            {
                $name = $special_name{$ks}->[0];
                $nop = $special_name{$ks}->[1];
            }
            if($first)
            {
                $kc_to_cname{$keycode} = $name;
                $kc_to_is_nop{$keycode} = $nop;
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
        'kc_to_is_nop' => \%kc_to_is_nop,
        'name_to_warned' => {},
        'kc_to_warned' => {},
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

sub kc_to_cname
{
    my $self = shift;
    my $kc = shift;

    my $cname = $self->{'kc_to_cname'}->{$kc};
    if(defined($cname))
    {
        return $cname;
    }

    my $warned = $self->{'kc_to_warned'}->{$kc};
    if($warned)
    {
        return undef;
    }

    warn "Unknown key code: $kc";

    $self->{'kc_to_warned'}->{$kc} = 1;

    return undef;
}

my %mod_name_to_code;
my %mod_digit_to_name;

sub _add_mod
{
    my $name = shift;
    my $digit = shift;

    if(!defined($mod_digit_to_name{$digit}))
    {
        $mod_digit_to_name{$digit} = $name;
    }

    $mod_name_to_code{lc($name)} = 1 << $digit;
}
_add_mod("Shift", 0);
_add_mod("S", 0);
_add_mod("Lock", 1);
_add_mod("L", 1);
_add_mod("Control", 2);
_add_mod("Ctrl", 2);
_add_mod("C", 2);
_add_mod("Alt", 3);
_add_mod("A", 3);
for my $i (1..9)
{
    _add_mod("Mod$i", 2 + $i);
    _add_mod("M$i", 2 + $i);
}

sub interp_desc
{
    my $self = shift;
    my $key = shift;

    my $mod = 0;
    while(1)
    {
        my $key0 = $key;
        if($key =~ /^(.*?)-(.*)$/)
        {
            my $code = $mod_name_to_code{lc($1)};
            if(defined($code))
            {
                $key = $2;
                $mod |= $code;
            }
        }
        last if($key eq $key0);
    }

    my $kc = $self->name_to_kc($key);
    if(!defined($kc))
    {
        return ();
    }

    return ($kc, $mod);
}

sub interp_pair
{
    my $self = shift;
    my $kc = shift;
    my $mod = shift;

    my $mods = "";
    for(my $digit = 0; $mod; ++$digit)
    {
        if($mod % 2)
        {
            $mods .= ($mod_digit_to_name{$digit} || "mx$digit") . "-";
        }
        $mod >>= 1;
    }

    my $kcs = $self->kc_to_cname($kc) || "KS$kc";

    return $mods . $kcs;
}

sub is_nop_key
{
    my $self = shift;
    my $kc = shift;

    return $self->{'kc_to_is_nop'}->{$kc} || 0;
}

1;
