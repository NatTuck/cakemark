#!/usr/bin/perl
use 5.10.0;
use warnings FATAL => 'all';

#our @BENCHMARKS = qw(mmul nas-cg nas-ft);
our @BENCHMARKS = qw(mmul blur);
our @PLATFORMS  = qw(cake pocl);
our @TIMINGS    = ("clEnqueueNDRangeKernel", "kernel execution");
our $REPEAT     = 10;
our $RESULTS    = "results.csv";
our $SUMMARY    = "summary.csv";

use Cwd qw(abs_path);
use File::Basename;
use Text::CSV;
use IO::Handle;

my $base = dirname(abs_path($0));

open my $out, ">", $RESULTS;
my $csv = Text::CSV->new();

sub get_times {
    my ($file, $tag) = @_;

    my @times = ();

    open my $ff, "<", $file;
    while (<$ff>) {
        if (/$tag.*:\s*([\d\.]+)/) {
            my $time = $1;
            my $kern = "none";

            if (/\((\w+)\)/) {
                $kern = $1;
            }

            push @times, [$kern, $time];
        }
    }
    close $ff;

    return @times;
}

sub run_benchmark {
    my ($benchmark, $platform) = @_;
    my $dir = "$base/benchmarks/$benchmark";
    my $tim = "/tmp/cake-timings.$$.txt";
    my $log = "/tmp/cake-log.$$.txt";

    chdir $dir;
    system(qq{CAKE_TIMINGS="$tim" make bench OPENCL="$platform" > "$log" });

    my $ok = 0 + `grep "[cake: OK]" "$log" | wc -l`;

    unless ($ok) {
        die "Benchmark failed: $benchmark on $platform.\n";
    }
   
    for my $timing (@TIMINGS) {
        my @times = get_times($tim, $timing);

        for my $tt (@times) {
            my ($kern, $time) = @$tt; 

            say "Saw timing: $timing ($kern) = $time"; 
            $csv->print($out, [$platform, $benchmark, $timing, $kern, $time]);
            $out->print("\n");
        }
    }
    
    unlink($log);
    unlink($tim);
}

# Execute the benchmarks.
for my $platform (@PLATFORMS) { 
    for my $benchmark (@BENCHMARKS) {
        for (my $ii = 0; $ii < $REPEAT; ++$ii) {
            run_benchmark($benchmark, $platform);
        }
    }
}

close $out;
