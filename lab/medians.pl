#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

use IO::Handle;
use Text::CSV;
use Data::Dumper;
use PDL;
use PDL::Stats::Basic;

open my $exec, "<", "data/exec_times.csv"
    or die "Cannot open input: $!\n";

my $benchs = {};
my $plats  = {};
my $data   = {};
my $runs   = {};

my $csv  = Text::CSV->new();
while (my $row = $csv->getline($exec)) {
    my ($plat, $ii, $bench, $kk, $time) = @$row;
   
    $plats->{$plat} = 1;
    $benchs->{$bench} = 1;
    
    my $key = "$plat:$bench";
    $data->{"$key:$ii"} ||= 0.0;
    $data->{"$key:$ii"} += $time;
        
    $runs->{$key} ||= [];
    push @{$runs->{$key}}, $ii;
}

my $meds = {};
my $mins = {};
my $maxs = {};

for my $plat (keys %$plats) {
    for my $bench (keys %$benchs) {
        my $key = "$plat:$bench";
        
        my @ts = ();
        
        for my $ii (@{$runs->{$key}}) {
            push @ts, $data->{"$key:$ii"};
        }
        
        my $xs = pdl \@ts;
        $meds->{$key} = median $xs;
        $mins->{$key} = min $xs;
        $maxs->{$key} = max $xs;
    }
}

close $exec;

open my $outs, ">", "data/medians.txt";
for my $key (sort keys %$meds) {
    my ($plat, $bench) = split /:/, $key;
    my $med = $meds->{$key};

    $outs->say("$plat\t$bench\t$med");
}
close $outs;

