package Cake::Benchmark;
use 5.12.0;
use warnings FATAL => 'all';

our @ISA = qw(Exporter);
our @EXPORT = qw(run_benchmark);

our %TAGS = (
    "clEnqueueNDRangeKernel" => "setup",
    "kernel execution"       => "execution"
);


use Cwd qw(getcwd);

# run_benchmark($bench, $plat, $opts)
#
#    Runs a benchmark on the supplied platform with
#    the supplied optimization flags.
#
#    Returns a nested hash structure like this:
#    {"type of timing" => {"kernel name" => [time1, time2]}}
#
sub run_benchmark {
    my ($bench, $plat, $opts) = @_;
    my $cwd = getcwd();

    $plat ||= "cake";
    $opts ||= "";

    my $dir = "$cwd/benchmarks/$bench";
    my $tim = "/tmp/cake-timings.$$.txt";
    my $log = "/tmp/cake-log.$$.txt";

    chdir $dir;
    system(qq{CAKE_OPT_HARDER="$opts" CAKE_TIMINGS="$tim" } .
           qq{make bench OPENCL="$plat" > "$log" });
    chdir $cwd;

    my $ok = 0 + `grep "[cake: OK]" "$log" | wc -l`;
    unless ($ok) {
        say "Opts: $opts\n";
        die "Benchmark failed: $bench on $plat.\n";
    }

    my $times = {};

    open my $ct, "<", $tim;
    while (<$ct>) {
        for my $tag (keys %TAGS) {
            if (/$tag.*?\((\w+)\):\s*([\d\.]+)/) {
                my ($kk, $tt) = ($1, $2);
                $times->{$TAGS{$tag}}{$kk} ||= 0.0;
                $times->{$TAGS{$tag}}{$kk}  += $tt;
            }
        }
    }
    close $ct;

    unlink $log;
    unlink $tim;

    return $times;
}

1;
