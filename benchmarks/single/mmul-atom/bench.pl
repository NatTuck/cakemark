#!/usr/bin/perl
use warnings FATAL => 'all';
use 5.12.0;
use IO::Handle;

# Test cases:
#   For
#     no-spec
#     spec
#   Each of
#     no-opt
#     -O3
#     -mem2reg -sccp -loop-rotate -loop-unroll -unroll-allow-partial -simplifycfg
#     -mem2reg -sccp -loop-rotate -loop-unroll -unroll-allow-partial -simplifycfg -reassociate

my $REPEAT = 10;

my @specs = (
    'no-spec',
    'spec',
);

my @opts = (
    'no-opt',
    'O3',
    'unroll',
    'unroll-re',
);

my %sets = (
    'no-opt'    => '',
    'O3'        => '-O3',
    'unroll'    => '-mem2reg -sccp -loop-rotate -loop-unroll -unroll-allow-partial -simplifycfg',
    'unroll-re' => '-mem2reg -sccp -loop-rotate -loop-unroll -unroll-allow-partial -simplifycfg -reassociate',
);

open my $bars, ">", "mmul-atom.bars";
$bars->say("Opt_Flags\topt-time\trun-time");

sub run_test {
    my ($spec, $opt) = @_;

    my $flags = $sets{$opt};
    
    system("make clean");
    system(qq{OPTS="$flags" make $spec});
    system("./$spec > /tmp/run.txt");

    my $time = 0.0;

    open my $run, "<", "/tmp/run.txt";
    while (<$run>) {
        if (/^result bad/) {
            system("cat /tmp/run.txt");
            die "Got result bad";
        }

        if (/^time: (.*)$/) {
            $time = 0.0 + $1;
        }
    }
    close $run;

    $bars->say("$spec-$opt\t0.0\t$time");
}

for (my $ii = 0; $ii < $REPEAT; ++$ii) {
    for my $spec (@specs) {
        for my $opt (@opts) {
            run_test($spec, $opt);
        }
    }
}

close $bars;
