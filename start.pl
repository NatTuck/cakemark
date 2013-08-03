#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

#our @BENCHMARKS = qw(mmul nas-cg nas-ft);
our @BENCHMARKS = qw(particlefilter);
#our @OPT_SETS  = ("");
#our @OPT_SETS = (
#    "",
#    "-reassociate -loop-simplify -indvars -licm -loop-unswitch ".
#    "-loop-unroll -gvn -sccp -loop-deletion -instcombine -adce ".
#    "-simplifycfg -loop-simplify"
#);
our $REPEAT     = 3;
our $SETUP      = "data/setup_times.csv";
our $EXECUTION  = "data/exec_times.csv";

use Cake::Benchmark;
use Cake::PrettyTime;

use Cwd qw(abs_path);
use File::Basename;
use Text::CSV;
use IO::Handle;
use Data::Dumper;

my $start_time = time();

chdir(dirname(abs_path($0)));

my @cases = ();
my $pn = 0;

for my $spec ((0, 1)) {
    for my $opt ((0, 1)) {
        my $opts = "";
        for my $bench (@BENCHMARKS) {
            push @cases, [$pn, $bench, "cake", $spec, $opt, $opts];
        }
        $pn += 1;
    }
}

my $count = scalar @cases;

open my $s_out, ">", $SETUP;
open my $e_out, ">", $EXECUTION;

my $csv = Text::CSV->new();

sub benchmark_once {
    my ($pn, $ii, $bench, $plat, $spec, $opt, $opts) = @_;
    my $times = run_benchmark($bench, $plat, $spec, $opt, $opts);

    $plat = "$plat$pn";
    
    for my $kk (keys %{$times->{parallel_bc}}) {
        my $time = $times->{parallel_bc}{$kk};
        $csv->print($s_out, [$plat, $ii, $bench, $kk, $time, $spec, $opt]);
        $s_out->print("\n");
    }
    
    for my $kk (keys %{$times->{execute}}) {
        my $time = $times->{execute}{$kk};
        $csv->print($e_out, [$plat, $ii, $bench, $kk, $time, $spec, $opt]);
        $e_out->print("\n");
    }
}

my $total_runs = $count * $REPEAT;

for (my $case_ii = 0; $case_ii < scalar @cases; ++$case_ii) {
    my $case = $cases[$case_ii];
    my ($pn, $bench, $plat, $spec, $opt, $opts) = @$case;
    say "$bench, $plat, $spec, [$opts]";

    for (my $ii = 0; $ii < $REPEAT; ++$ii) {
        my $rnum = $case_ii * $REPEAT + $ii;
        say "Run #$rnum / $total_runs";
        benchmark_once($pn, $ii, $bench, $plat, $spec, $opt, $opts);
    }
}

close $s_out;
close $e_out;

my $end_time = time();
my $elapsed  = $end_time - $start_time;

my $total = $count * $REPEAT;

say "  == Run Completed ==";
say "Executed $count cases ($total tests) in";
say pretty_time($elapsed);
