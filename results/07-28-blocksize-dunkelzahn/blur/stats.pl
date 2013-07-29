#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

use IO::Handle;
use PDL;
use PDL::Stats::Basic;
use Data::Dumper;

my %xs = ();
my %ys = ();
my %ks = ();

my %bts = ();
my %ets = ();

open my $log, "<", "times.log";
while (<$log>) {
    my ($xx, $yy, $kk, $oo, $tt) = split /\s+/;
    $xs{$xx} = 1;
    $ys{$yy} = 1;

    my $key = "$kk:$xx:$yy";

    if ($oo eq 'parallel_bc') {
        $bts{$key} ||= [];
        push @{$bts{$key}}, $tt;
    }
    elsif ($oo eq 'execute') {
        $ets{$key} ||= [];
        push @{$ets{$key}}, $tt;
    }
    else {
        die "Unknown timing $oo";
    }
}
close $log;

for my $kern (qw{blur_hor blur_ver}) {
    open my $out, ">", "rects-$kern.txt";
    for my $xx (1,2,4,8,16,32) {
        my @row = ();
        for my $yy (1,2,4,8,16,32) {
            my $key = "$kern:$xx:$yy";
            my $sas = $ets{$key} or die "No data";
            my $ts = pdl $sas;
            push @row, median $ts;
        }
        $out->say(join(" ", @row));
    }
    close $out;
}

