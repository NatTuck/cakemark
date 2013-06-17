#!/usr/bin/perl
use 5.10.0;
use warnings FATAL => 'all';

our @BENCHMARKS = qw(mmul);
our @PLATFORMS  = qw(cake);
our @TIMINGS    = ("clEnqueueNDRangeKernel", "kernel execution");
our $OUTPUT     = "results.csv";

use Cwd qw(abs_path);
use File::Basename;
use Text::CSV;

my $base = dirname(abs_path($0));

open my $out, ">", $OUTPUT;

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
        my $line   = `grep "$timing.*:" "$tim" | head -n 1`;
        my ($time) = ($line =~ /:\s*([\d\.]+)\s*$/);

        say "Saw timing: $timing = $time";
    }
    
    unlink($log);
    unlink($tim);
}

# Execute the benchmarks.
for my $platform (@PLATFORMS) {
    for my $benchmark (@BENCHMARKS) {
        run_benchmark($benchmark, $platform);
    }
}

close $out;
