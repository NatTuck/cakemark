#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

use IO::Handle;
use Text::CSV;
use PDL;
use PDL::Stats::Basic;

my $times = {};

# Read in some data.

open my $tms, "<", "data/exec_times.csv";
my $csv = Text::CSV->new();
while(my $row = $csv->getline($tms)) {
    my (undef, $ii, undef, $kk, $tm, $spec) = @$row;
    $spec =~ /^(\w+)\((.*)\)$/ or die "bad input";
    my ($sk, $sargs) = ($1, $2);

    # Nobody cares how the other kernels did when
    # we're varying the args for $kk.
    next unless $kk eq $sk;

    $times->{$spec} ||= [];
    push @{$times->{$spec}}, $tm; 
}
close $tms;

my $meds = {};
my $base = {};

# Calculate the medians.
for my $spec (sort keys %$times) {
    $spec =~ /^(\w+)\((.*)\)$/ or die "bad input";
    my ($sk, $sargs) = ($1, $2);


    my $pdl = pdl $times->{$spec};
    my $med = median $pdl;

    $meds->{$spec} = $med;
    $base->{$sk}   = $med if ($sargs eq "");
}

# Print the results.

open my $ba, ">", "data/basumm.txt";

for my $spec (sort keys %$meds) {
    $spec =~ /^(\w+)\((.*)\)$/ or die "bad input";
    my ($sk, $sargs) = ($1, $2);
    
    my $med = $meds->{$spec};
    my $bas = $base->{$sk};

    my $speedup = $bas / $med;

    $ba->printf(qq{$sk, "$sargs", %.04f, %.04f\n}, $med, $speedup);
}

close $ba;
system("cat data/basumm.txt");
