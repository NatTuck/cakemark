#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

my $input = $ARGV[0] 
    or die "Usage:\n  perl $0 input.csv\ndied";

use Cwd qw(abs_path);
use File::Basename;
use Cake::BarChart;

use IO::Handle;
use Text::CSV;
use Data::Dumper;
use PDL;
use PDL::Stats::Basic;

# Input: 
#     A CSV containing test run times.
#
# Output: 
#     A bar chart with error bars for each benchmark,
#     showing median total time per POCL config.

# First, read in raw data.

my %plat_labels = (
    cake0 => "default",
    cake1 => "opt",
    cake2 => "spec",
    cake3 => "opt+spec"
);

my $benchs = {};
my $plats  = {};

my $data = {};
my $runs = {};

open my $ff, "<", $input
    or die "Cannot open '$input': $!";
my $csv = Text::CSV->new();
while (my $row = $csv->getline($ff)) {
    my ($plat, $ii, $bench, $kk, $time, $spec, $opts) = @$row;
    $plats->{$plat} = 1;
    $benchs->{$bench} = 1;

    my $key = "$plat:$bench";
    $data->{"$key:$ii"} ||= 0.0;
    $data->{"$key:$ii"} += $time;

    $runs->{$key} ||= [];
    push @{$runs->{$key}}, $ii;
}
close $ff;

# Second, calcluate stats per test case.

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

# Finally, generate the plots.

my $chart_dir = dirname(abs_path($0)) . "/charts";

for my $bench (keys %$benchs) {
    my $chart = Cake::BarChart->new(
        "$bench - $input", "POCL Config", "Time");
   
    for my $plat (sort keys %$plats) {
        my $name = $plat_labels{$plat};
        my $key = "$plat:$bench";
        my $med = $meds->{$key};
        say "med = $med";

        $chart->add($name, $meds->{$key}, $mins->{$key}, $maxs->{$key});
    }

    $chart->write("$chart_dir/$bench.pdf");
}
