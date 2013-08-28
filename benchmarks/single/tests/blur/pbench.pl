#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

our $KERNEL  = "blur";
our $REPEAT  = 5;
our $OUTF    = "$KERNEL.perms";
our $SPECLIB = "../../spec/libspec.so";

our $SPECTXT = "ww=1024,hh=768,sigma=3";

sub flags ($);
sub flag_sets ($);

our $BEFORE  = flags('setup');
our @PERMS   = flag_sets('basic');
our $AFTER   = '';

use IO::Handle;
use Time::HiRes qw(time);
use File::Temp;
use Algorithm::Combinatorics qw(variations);
use Data::Dumper;

#say Dumper(\@PERMS);
#exit 0;

open my $out, ">", $OUTF;

sub test_run {
    my ($spec, $opt_flags) = @_;

    my $spec_flags = "";
    if ($spec) {
        $spec_flags = qq{-load "$SPECLIB" -specialize -kernel="$KERNEL" } .
                      qq{-spec-text="$SPECTXT"};
    }

    system(qq{rm -f $KERNEL-opt.bc});

    my $optcmd = qq{opt $spec_flags $opt_flags -o $KERNEL-opt.bc $KERNEL.bc};
    say $optcmd;

    my $opt_start = time();
    system($optcmd);
    my $opt_end   = time();
    my $ot = $opt_end - $opt_start;

    system(qq{make});

    my $tmp = File::Temp->new();
    system("./$KERNEL > $tmp");

    my $ok = `grep "[cake: OK]" $tmp`;
    unless ($ok =~ /OK/) {
        system("cat $tmp");
        die "Giving up";
    }

    my $out = `grep ^time: $tmp`;
    $out =~ /^time: ([\d\.]+)/ or die "No time";
    my $rt = ($1);
    return (0.0 + $ot, 0.0 + $rt);
}

system("make clean");
system("make");

$out->say("opt-time run-time spec flags");

for my $optset (@PERMS) {
    my $fixup = flags('fixup');
    my $flags = "$fixup " . join(" $fixup ", @$optset) . " $fixup";

    for my $spec ((0, 1)) {
        my @ots = ();
        my @rts = ();

        for my $ii (1..$REPEAT) {
            my ($ot, $rt) = test_run($spec, $flags);
            $out->say("$ot\t$rt\t$spec\t$flags");
        }
    }
}

close $out;

say "--";
say "Results written to: $OUTF";

sub flag_sets ($) {
    my ($tag) = @_;
    my @flags = split /\s+/, flags($tag);

    my @sets = ();

    for (my $ii = 0; $ii <= scalar @flags; ++$ii) {
        push @sets, variations(\@flags, $ii);
    }

    return @sets;
}

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
setup: -mem2reg -inline -globaldce
fixup: -instcombine -reassociate -simplifycfg -reassociate -instcombine -dse -adce
basic: -gvn -sccp -sink -jump-threading -correlated-propagation 
loop0: -loop-simplify -lcssa -loop-rotate -licm -lcssa
loop1: -loop-unswitch -loop-unroll -loop-vectorize
loop2: -loop-deletion -loop-reduce
other: -bb-vectorize

unroll: -loop-rotate -loop-unroll -unroll-allow-partial -simplifycfg -loop-reduce
unroll2: -loop-rotate -loop-unroll -unroll-allow-partial -unroll-threshold=2 -simplifycfg
loopvec: -mem2reg -sccp -loop-simplify -loop-rotate -lcssa -loop-vectorize -reassociate
O3: -O3 -reassociate
