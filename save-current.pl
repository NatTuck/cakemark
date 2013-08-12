#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

my $host = `hostname`; chomp $host;
my $date = `date '+%m-%d-%H'`; chomp $date;
my $sdir = "results/$date-$host-0";

while (-d $sdir) {
    $sdir =~ /^(.*)-(\d+)$/;
    my ($pre, $suf) = ($1, $2 + 1);
    $sdir = "$pre-$suf";
}

mkdir $sdir;
system(qq{cp -r data charts "$sdir"});

say "Copied data and charts to\n\t$sdir";
