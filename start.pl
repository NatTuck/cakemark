#!/usr/bin/perl
use 5.10.0;
use warnings FATAL => 'all';

#our @BENCHMARKS = qw(mmul nas-cg nas-ft);
our @BENCHMARKS = qw(mmul blur);
our @OPT_SETS  = (
    "",
    "-reassociate -loop-simplify -indvars -licm -loop-unswitch ".
    "-loop-unroll -gvn -sccp -loop-deletion -instcombine -adce ".
    "-simplifycfg"
);
our $REPEAT     = 10;
our $SETUP      = "setup_times.csv";
our $EXECUTION  = "exec_times.csv";

use Cake::Benchmark;

use Cwd qw(abs_path);
use File::Basename;
use Text::CSV;
use IO::Handle;

chdir(dirname(abs_path($0)));

my @cases = ();

for my $bench (@BENCHMARKS) {
    push @cases, [$bench, "pocl", ""];
}

for my $bench (@BENCHMARKS) {
    for my $opts (@OPT_SETS) {
        push @cases, [$bench, "cake", $opts];
    }
}

open my $s_out, ">", $SETUP;
open my $e_out, ">", $EXECUTION;

my $csv = Text::CSV->new();

sub benchmark_once {
    my ($bench, $plat, $opts) = @_;
    my $times = run_benchmark($bench, $plat, $opts);
    
    for my $kk (keys %{$times->{setup}}) {
        my $time = $times->{setup}{$kk};
        $csv->print($s_out, [$plat, $bench, $kk, $time]);
        $s_out->print("\n");
    }
    
    for my $kk (keys %{$times->{execution}}) {
        my $time = $times->{execution}{$kk};
        $csv->print($e_out, [$plat, $bench, $kk, $time]);
        $e_out->print("\n");
    }
}

for my $case (@cases) {
    my ($bench, $plat, $opts) = @$case;
    say "$bench, $plat, [$opts]";
    
    for (my $ii = 0; $ii < $REPEAT; ++$ii) {
        benchmark_once($bench, $plat, $opts);
    }
}

close $s_out;
close $e_out;
