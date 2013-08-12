#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

our @BENCHMARKS = qw(mmul mandelbrot);
#our @BENCHMARKS = qw(blur gaussian mandelbrot mmul nas-cg nas-ep nas-ft nas-is
#                     nas-sp particlefilter);

use Cake::OptFlags; 

our $OPT_EXTRA = "-globaldce";
our $OPT_FLAGS = Cake::OptFlags::get_data('unroll');

our $REPEAT     = 5;
our $SETUP      = "data/setup_times.csv";
our $EXECUTION  = "data/exec_times.csv";

use Cake::Benchmark;
use Cake::PrettyTime;

start_benchmark(<<"EOF");
Comparison Test
Benchs = ${\ join(' ', @BENCHMARKS) }
Repeat = $REPEAT
EOF

use Cwd qw(abs_path);
use File::Basename;
use Text::CSV;
use IO::Handle;
use Data::Dumper;
use URI::Encode qw(uri_encode uri_decode);

my $start_time = time();

chdir(dirname(abs_path($0)));

my @cases = ();
my $pn = 0;

for my $spec ((0, 1)) {
    for my $opt ((0, 1, 2)) {
        for my $bench (@BENCHMARKS) {
            my $opts = {};
            $opts->{extra} = $OPT_EXTRA;
            $opts->{early} = "";
            $opts->{later} = "";

            my $label = "default";

            if ($opt == 1) {
                $label = "unroll-2";
                $opts->{early} = "-mem2reg -sccp -loop-rotate -loop-unroll ".
                                 "-unroll-allow-partial -simplifycfg -reassociate";
            }

            if ($opt == 2) {
                next;
                $label = "no height";
                $opts->{early} = "";
            }
            
            if ($spec) {
                $opts->{spec} = 1;
                $label = "$label-spec";
            }

            push @cases, [$pn, $bench, "cake", $opts, $label];
        }
        $pn += 1;
    }
}

my $count = scalar @cases;

open my $s_out, ">", $SETUP;
open my $e_out, ">", $EXECUTION;

my $csv = Text::CSV->new();

sub benchmark_once ($$$$$$) {
    my ($pn, $ii, $bench, $plat, $opts, $label) = @_;

    my $times = run_benchmark($bench, $plat, $opts);
    die "No execute times" unless defined $times->{execute};
    die "No setup times" unless defined $times->{parallel_bc};

    $plat = "$plat$pn";
    
    for my $kk (keys %{$times->{parallel_bc}}) {
        my $time = $times->{parallel_bc}{$kk};
        $csv->print($s_out, [$plat, $ii, $bench, $kk, $time, $label]);
        $s_out->print("\n");
    }
    
    for my $kk (keys %{$times->{execute}}) {
        my $time = $times->{execute}{$kk};
        $csv->print($e_out, [$plat, $ii, $bench, $kk, $time, $label]);
        $e_out->print("\n");
    }
}

my $total_runs = $count * $REPEAT;

for (my $case_ii = 0; $case_ii < scalar @cases; ++$case_ii) {
    my $case = $cases[$case_ii];
    my ($pn, $bench, $plat, $opts, $label) = @$case;
    say "$bench, $plat";
    say Dumper($opts);

    for (my $ii = 0; $ii < $REPEAT; ++$ii) {
        my $rnum = $case_ii * $REPEAT + $ii;
        say "Run #$rnum / $total_runs";
        benchmark_once($pn, $ii, $bench, $plat, $opts, $label);
    }
}

close $s_out;
close $e_out;

my $end_time = time();
my $elapsed  = $end_time - $start_time;

my $total = $count * $REPEAT;

my $pretty_elapsed = pretty_time($elapsed);

say "  == Run Completed ==";
say "Executed $count cases ($total tests) in";
say $pretty_elapsed;

my $ping_subj = uri_encode("cakemark done");
my $ping_host = `hostname`; chomp $ping_host;
my $ping_body = uri_encode("Test run done on $ping_host: " .
    "$total tests in $pretty_elapsed");

system(qq{curl "http://www.ferrus.net/ping.php?} .
    qq{subject=$ping_subj&message=$ping_body"});
