#!/usr/bin/perl
use 5.10.0;
use warnings FATAL => 'all';

#our @BENCHMARKS = qw(mmul nas-cg nas-ft);
our @BENCHMARKS = qw(blur);
our @OPT_SETS  = ("");
#    "",
#    "-reassociate -loop-simplify -indvars -licm -loop-unswitch ".
#    "-loop-unroll -gvn -sccp -loop-deletion -instcombine -adce ".
#    "-simplifycfg"
#);
our $REPEAT     = 1;
our $SETUP      = "setup_times.csv";
our $EXECUTION  = "exec_times.csv";

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

for my $bench (@BENCHMARKS) {
    push @cases, [$bench, "cake", 0, ""];
}

for my $bench (@BENCHMARKS) {
    for my $opts (@OPT_SETS) {
        push @cases, [$bench, "cake", 1, $opts];
    }
}

open my $s_out, ">", $SETUP;
open my $e_out, ">", $EXECUTION;

my $csv = Text::CSV->new();

sub benchmark_once {
    my ($bench, $plat, $spec, $opts) = @_;
    my $times = run_benchmark($bench, $plat, $spec, $opts);

    $plat = $plat . ($spec ? "_s" : "");
    
    for my $kk (keys %{$times->{parallel_bc}}) {
        my $time = $times->{parallel_bc}{$kk};
        $csv->print($s_out, [$plat, $bench, $kk, $time, $opts]);
        $s_out->print("\n");
    }
    
    for my $kk (keys %{$times->{execute}}) {
        my $time = $times->{execute}{$kk};
        $csv->print($e_out, [$plat, $bench, $kk, $time, $opts]);
        $e_out->print("\n");
    }
}

for my $case (@cases) {
    my ($bench, $plat, $spec, $opts) = @$case;
    say "$bench, $plat, $spec, [$opts]";
    
    for (my $ii = 0; $ii < $REPEAT; ++$ii) {
        benchmark_once($bench, $plat, $spec, $opts);
    }
}

close $s_out;
close $e_out;

my $end_time = time();
my $elapsed  = $end_time - $start_time;
my $count = scalar @cases;

say "";
say Dumper(\@cases);
say "  == Run Completed ==";
say "Executed $count cases in";
say pretty_time($elapsed);
