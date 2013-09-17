#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';
    
use PDL;
use PDL::Stats::Basic;
use IO::Handle;

my $tmp = "/tmp/time.$$.log";
my $smr = "summary.txt";

sub test_size {
    my ($xbs, $ybs) = @_;
    system("XBS=$xbs YBS=$ybs CAKE_TIMINGS=$tmp make bench");

    my ($bb, $ee);

    open my $ts, "<", $tmp;
    while (<$ts>) {
        if (/^timer_log\((\w+),(\w+)\):\s*([\d\.]+)/) {
            my ($kk, $mm, $tt) = ($1, $2, $3);
            if ($mm eq "parallel_bc") {
                $bb = $tt;
            }
            elsif ($mm eq "execute") {
                $ee = $tt;
            }
            else {
                die "Dunno what a $mm is";
            }
        }
        else {
            die "Bad line: $_";
        }
    }
    close $ts;

    system ("cat $tmp");
    unlink($tmp);

    die "No bb" unless defined $bb;
    die "No ee" unless defined $ee;

    return ($bb, $ee);
}

open my $out, ">", $smr;
$out->say("size\trun_md\trun_sv\tbld_md\tbld_sv");

for my $xbs (1, 2, 4, 8, 16, 32) {
    for my $ybs (1, 2, 4, 8, 16, 32) {
        my @builds = ();
        my @execs  = ();
        for (1..10) {
            my ($bb, $ee) = test_size($xbs, $ybs);
            push @builds, $bb;
            push @execs, $ee;
        }

        my $bs = pdl \@builds;
        my $es = pdl \@execs;

        my $run_md = median $es;
        my $run_sv = stdv $es;
        my $bld_md = median $bs;
        my $bld_sv = stdv $bs;
    
        say ("$xbs,$ybs\t$run_md\t$run_sv\t$bld_md\t$bld_sv");
        $out->say("$xbs,$ybs\t$run_md\t$run_sv\t$bld_md\t$bld_sv");
    }
}
close $smr;
