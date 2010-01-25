package ChimeraWM;

use strict;
use warnings;

use ChimeraWM::Cfg;

sub main
{
    my $self = shift;

    my $rc;
    {
        my $rc_file;
        if(defined($rc_file = $ENV{'CHIMERARC'}))
        {
            $rc = $self->load_rc($rc_file);
        }
        elsif(defined(my $rc_str = $ENV{'CHIMERARCS'}))
        {
            $rc = $rc_str;
        }
        elsif(-f ($rc_file = $ENV{'HOME'} . "/.chimerarc"))
        {
            $rc = $self->load_rc($rc_file);
        }
        else
        {
            $rc = "{}";
        }
    }

    my $wm = ChimeraWM::Cfg->eval_cfg($rc);
    if($@)
    {
        die "Evaluating RC failed: $@";
    }

    $wm = ChimeraWM::Cfg::wm($wm);

    return $wm->imain();
}

sub load_rc
{
    my $self = shift;
    my $file = shift;

    open(my $h, "<", $file) || die "Could not open $file";
    my $rc = join("", <$h>);
    close($h) || die "Could not close $file";

    return $rc;
}

1;
