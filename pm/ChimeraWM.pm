package ChimeraWM;

use strict;
use warnings;

sub new
{
    my $class = shift;

    my $self = bless {}, $class;

    return $self;
}

sub imain
{
    print "Hello, chimerical world!!!\n";
}

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
            $rc = "ChimeraWM->new()";
        }
    }

    my $wm = eval $rc;
    if($@)
    {
        die "Evaluating RC failed: $@";
    }

    if(!UNIVERSAL::isa($wm, 'ChimeraWM'))
    {
        die "Evaluating RC did not produce ChimeraWM instance";
    }

    $wm->imain();

    return 0;
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
