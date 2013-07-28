#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';
    
use PDL;
use PDL::Stats::Basic;
use IO::Handle;

my $tmp = "/tmp/time.$$.log";

open my $log, ">", "times.log";

sub test_size {
    my ($xbs, $ybs) = @_;
    system("XBS=$xbs YBS=$ybs CAKE_TIMINGS=$tmp make bench");

    my %times = ();

    open my $ts, "<", $tmp;
    while (<$ts>) {
        if (/^timer_log\((\w+),(\w+)\):\s*([\d\.]+)/) {
            my ($kk, $mm, $tt) = ($1, $2, $3);
            $log->say("$xbs $ybs $kk $mm $tt");
        }
        else {
            die "Bad line: $_";
        }
    }
    close $ts;

    system ("cat $tmp");
    unlink($tmp);

    return \%times;
}

for my $xbs (1, 2, 4, 8, 16, 32) {
    for my $ybs (1, 2, 4, 8, 16, 32) {
        my @builds = ();
        my @execs  = ();
        for (1..10) {
            test_size($xbs, $ybs);
        }
    }
}

close $log;
