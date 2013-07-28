#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

my %rows = ();
my %cols = ();
my %data = ();

open my $sm, "<", "summary.txt";
while (<$sm>) {
    /^(\d+),(\d+)\s+([\d\.]+)/ or next;
    my ($lx, $ly, $tt) = ($1, $2, $3);
    $rows{$lx} = 1;
    $cols{$ly} = 1;
    $data{"$lx,$ly"} = $tt;
}
close $sm;

say join(",", ("", sort { $a <=> $b } keys %cols));

for my $row (sort { $a <=> $b } keys %rows) {
    my @row = ($row);
    for my $col (sort { $a <=> $b } keys %cols) {
        push @row, $data{"$row,$col"};
    }
    say join(",", @row);
}
