#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

our $REPEAT = 5;
our $SPEC   = "-spec-text='kk=7'";
our $UNROLL = "-O3 -unroll-allow-partial";
#our $UNROLL = "-mem2reg -sccp -loop-rotate -loop-unroll ".
#              "-unroll-allow-partial -simplifycfg -reassociate";
our $TEST   = "./ipow";

our $OUTF   = "/tmp/times.$$.txt";

use PDL;
use PDL::Stats::Basic;
use IO::Handle;

open my $out, ">", $OUTF;

sub test_run {
    my ($spec, $unroll) = @_;

    $spec = $spec ? $SPEC : "";
    $unroll = $unroll? $UNROLL : "";
   
    system("make clean");
    system(qq{make SPEC="$spec" FLAGS="$unroll"});
    my $out = `$TEST | grep ^time:`;
    $out =~ /^time: ([\d\.]+)/;
    return 0.0 + $1;
}

$out->say("spec\tunroll\ttime");

for my $spec ((0, 1)) {
    for my $unroll ((0, 1)) {
        my @ts = ();

        for my $ii (1..$REPEAT) {
            push @ts, test_run($spec, $unroll);
        }

        my $pdl = pdl \@ts;
        my $med = median $pdl;

        $out->say("$spec\t$unroll\t$med");
    }
}

close $out;

say "--";
say "Results written to: $OUTF";
