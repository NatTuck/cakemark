#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

our $KERNEL  = "ipow2";
our $REPEAT  = 10;
our $OUTF    = "$KERNEL.bars";
our $SPECLIB = "../../spec/libspec.so";

sub flags ($);

my %OPTS = (
    A_notopt    => "",
    B_O3        => flags('O3'),
    C_O3_re     => flags('O3') . ' ' . flags('reassoc'),
    D_unroll    => flags('unroll'),
    E_unroll_re => flags('unroll') . ' ' . flags('reassoc'),
);

use IO::Handle;
use Time::HiRes qw(time);

open my $out, ">", $OUTF;

sub test_run {
    my ($spec, $opt_flags) = @_;

    my $spec_flags = "";
    if ($spec) {
        my @sfs = (qq{-load "$SPECLIB"}, flags('spec'), qq{-kernel="$KERNEL"});
        $spec_flags = join(' ', @sfs);
    }

    system(qq{rm -f $KERNEL-opt.bc});

    my $optcmd = qq{opt $spec_flags $opt_flags -o $KERNEL-opt.bc $KERNEL.bc};
    say $optcmd;

    my $opt_start = time();
    system($optcmd);
    my $opt_end   = time();
    my $ot = $opt_end - $opt_start;

    system(qq{make});

    my $out = `./$KERNEL | grep ^time:`;
    $out =~ /^time: ([\d\.]+)/;
    my $rt = $1;
    return (0.0 + $ot, 0.0 + $rt);
}

system("make clean");
system("make");

$out->say("Opt_Flags opt-time run-time");

for my $opt (sort keys %OPTS) {
    my $flags = $OPTS{$opt};
    $opt =~ s/^\w_//;
    $opt =~ y/_/-/;

    for my $spec ((0, 1)) {
        my $label = ($spec ? "spec-" : "") . $opt;

        my @ots = ();
        my @rts = ();

        for my $ii (1..$REPEAT) {
            my ($ot, $rt) = test_run($spec, $flags);
            $out->say("$label\t$ot\t$rt");
        }
    }
}

close $out;

say "--";
say "Results written to: $OUTF";


sub flags ($) {
    my ($tag) = @_;
    seek DATA, 0, 0;
    while(<DATA>) {
        next if /^\s*#/;
        /^(\w+):\s*(.*)$/ or next;
        my ($tt, $flags) = ($1, $2);
        return $flags if $tag eq $tt;
    }
    return "";
}

__DATA__
spec: -specialize -spec-text="kk=7"
unroll: -mem2reg -sccp -loop-rotate -loop-unroll -unroll-allow-partial -simplifycfg
reassoc: -reassociate
O3: -O3
