#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

# Foreach [bench, kern, plat] build sets of setup and exec times.
# Output [bench, kern, plat0 exec median, plat1 exec median, ..., plat0 setup median...]

use Text::CSV;
use IO::Handle;
use Data::Dumper;

use PDL;
use PDL::Ufunc qw(median);

my $data  = {};
my %plats = ();

open my $ets, "<", "exec_times.csv";
open my $sts, "<", "setup_times.csv";

my $csv = Text::CSV->new();

while (my $row = $csv->getline($ets)) {
    my ($plat, $bench, $kern, $time, $spec, $opts) = @$row;
    my $key = "$bench:$kern";
    $data->{$key}{$plat} ||= {e => [], s => []};
    push @{$data->{$key}{$plat}{e}}, $time;

    $plats{$plat} = 1;
}

while (my $row = $csv->getline($sts)) {
    my ($plat, $bench, $kern, $time, $spec, $opts) = @$row;
    my $key = "$bench:$kern";
    $data->{$key}{$plat} ||= {e => [], s => []};
    push @{$data->{$key}{$plat}{s}}, $time;
}

close $sts;
close $ets;

open my $summ, ">", "summary.csv";

my @ehds = map { "$_ exec" }  sort keys %plats;
my @shds = map { "$_ setup" } sort keys %plats;

$csv->print($summ, ["bench", "kern", @ehds, @shds]);
$summ->print("\n");

for my $key (sort keys %$data) {
    my ($bench, $kern) = split ':', $key;
    my @ems = ();
    my @sms = ();

    for my $plat (sort keys %{$data->{$key}}) {
        my $pdl = pdl $data->{$key}{$plat}{e};
        push @ems, median $pdl;
        $pdl = pdl $data->{$key}{$plat}{s};
        push @sms, median $pdl;
    }

    $csv->print($summ, [$bench, $kern, @ems, @sms]);
    $summ->print("\n");
}

close $summ;
