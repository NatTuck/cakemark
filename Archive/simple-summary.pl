#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

our $RESULTS    = "results.csv";
our $SUMMARY    = "summary.csv";

our $MIN_TIME   = 0.5;

use Text::CSV;
use IO::Handle;

open my $res, "<", $RESULTS;
my $csv = Text::CSV->new();

open my $sum, ">", $SUMMARY;

my %PLATS  = ();
my %BENCHS = ();
my %TAGS   = ();
my %KERNS  = ();

my %SUMS = ();

while (my $items = $csv->getline($res)) {
    my ($plat, $bench, $tag, $kern, $time) = @$items;
    my $key = "$plat|$bench|$tag|$kern";

    say "$plat | $bench | $tag | $kern | $time";

    $PLATS{$plat}   = 1;
    $BENCHS{$bench} = 1;
    $TAGS{$tag}     = 1;

    $KERNS{$bench} ||= {};
    $KERNS{$bench}{$kern} = 1;

    $SUMS{$key} ||= 0;
    $SUMS{$key}  += $time;
}

#                plat plat
# bench tag kern time time

$csv->print($sum, ["", "", "", sort keys %PLATS]);
$sum->print("\n");

for my $bench (sort keys %BENCHS) {
    for my $kern (sort keys %{$KERNS{$bench}}) {
        for my $tag (sort keys %TAGS) {
            my @row = ($bench, $kern, $tag);

            for my $plat (sort keys %PLATS) {
                my $key  = "$plat|$bench|$tag|$kern";
                my $time = $SUMS{$key} / $REPEAT;

                push @row, $time;
            }
                
            $csv->print($sum, \@row);
            $sum->print("\n");
        }
    }
}
