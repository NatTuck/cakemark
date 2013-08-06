#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

my $host = `hostname`; chomp $host;
my $date = `date '+%m-%d-%k'`; chomp $date;
my $sdir = "results/$date-$host";

mkdir $sdir;
system(qq{cp -r data charts "$sdir"});

say "Copied data and charts to\n\t$sdir";
