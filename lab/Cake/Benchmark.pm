package Cake::Benchmark;
use 5.12.0;
use warnings FATAL => 'all';

our @ISA = qw(Exporter);
our @EXPORT = qw(run_benchmark start_benchmark);

our %TAGS = (
    opt => 'opt',
    run => 'run',
);

our $VERBOSE = 0;
our $LOG = "data/bench.log";

use Cwd qw(getcwd);
use Data::Dumper;
use IO::Handle;

sub start_benchmark {
    my ($text) = @_;
    open my $ll, ">", $LOG;
    my $host = `hostname`; chomp $host;
    my $date = `date`; chomp $date;
    $ll->say("## Started test on $host at $date ##");
    for my $line (split "\n", $text) {
        $ll->say("# $line");
    }
    close $ll;

    system("rm -f data/*.*");
    system("rm -f charts/*.*");
}


# run_benchmark($bench, $plat, $opts)
#
#    Runs a benchmark on the supplied platform with
#    the supplied optimization flags.
#
#    Returns a nested hash structure like this:
#    {"type of timing" => {"kernel name" => [time1, time2]}}
#
sub run_benchmark ($$$) {
    my ($bench, $plat, $opts) = @_;
    my $cwd = getcwd();

    open my $ll, ">>", $LOG;
    $ll->say(Dumper([$bench, $plat, $opts]));
    close $ll;
    
    $plat  ||= "cake";

    my $env = '';

    if ($opts->{spec}) {
        $env .= qq{CAKE_SPEC="1" PANCAKE_SPEC="1" };

        if ($plat eq 'clover') {
            $env .= qq{SPEC_TEXT="nn=1024,spin=1" SPEC_KERN="fmma" };
        }
    }

    if ($opts->{nospec}) {
        $env .= qq{PANCAKE_SPEC="1" PANCAKE_NOSPEC="1" };
    }
    
    if ($opts->{unroll}) {
        $env .= qq{PANCAKE_UNROLL="1" };
    }

    if ($opts->{early}) {
        my $early = $opts->{early};
        $env .= qq{CAKE_OPT_EARLY="$early" };
    }

    if ($opts->{later}) {
        my $later = $opts->{later};
        $env .= qq{CAKE_OPT_LATER="$later" };
    }

    if ($opts->{extra}) {
        my $extra = $opts->{extra};
        $env .= qq{CAKE_OPT_EXTRA="$extra" };
    }

    if ($opts->{force}) {
        my $force = $opts->{force};
        $env .= qq{CAKE_SPEC_FORCE="$force" };
    }

    my $dir = "$cwd/../benchmarks/$bench";
    my $tim = "/tmp/cake-timings.$$.txt";
    my $log = "/tmp/cake-log.$$.txt";

    chdir $dir or die "No such directory '$dir'";
    my $test_cmd = qq{CAKE_TIMINGS="$tim" $env } .
                   qq{make bench OPENCL="$plat" > "$log" };
    say "test cmd = $test_cmd"; 
    system($test_cmd);

    if ($VERBOSE) {
        system(qq{cat "$log"});
    }
                   
    chdir $cwd;

    my $ok = 0 + `grep "[cake: OK]" "$log" | wc -l`;
    unless ($ok) {
        say Dumper($opts);
        die "Benchmark failed: $bench on $plat.\n";
    }

    my $times = {};

    open my $ct, "<", $tim or die "open($tim) failed: $!";
    while (<$ct>) {
        if (/^timer_log\((\w+),\s*(\w+)\):\s*([\d\.]+)/) {
            my ($kern, $tag, $tt) = ($1, $2, $3);

            #say "kern = $kern, tag = $tag, tt = $tt";
                
            $times->{$TAGS{$tag}}{$kern} ||= 0.0;
            $times->{$TAGS{$tag}}{$kern}  += $tt;
        }
    }
    close $ct;

    system(qq{grep opt "$log"});

    unlink $log;
    unlink $tim;

    return $times;
}

1;
