#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

use Cwd qw(abs_path);
use File::Basename;

use IO::Handle;
use Text::CSV;
use Data::Dumper;
use PDL;
use PDL::Stats::Basic;

# Input: 
#     A CSV containing test run times.
#
# Output: 
#     Speedup of median in each test.

# First, read in raw data.
our %plat_labels = (
    cake0 => "default",
    cake1 => "opt",
    cake2 => "spec",
    cake3 => "opt+spec"
);
    
open my $su, ">", "data/speedups.txt";

sub gen_charts {
    my ($input, $tag) = @_;
    
    my $benchs = {};
    my $plats  = {};

    my $data = {};
    my $runs = {};

    open my $ff, "<", $input
        or die "Cannot open '$input': $!";
    my $csv = Text::CSV->new();
    while (my $row = $csv->getline($ff)) {
        my ($plat, $ii, $bench, $kk, $time) = @$row;
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

    # Finally, write the speedups summary.
    
    $su->say("\n\t=== $tag ===");
    $su->printf("speedups\t%10s %10s %10s %10s %10s\n",
        "b/o", "b/s", "b/os", "o/os", "s/os");

    for my $bench (keys %$benchs) {
        my $cake0 = $meds->{"cake0:$bench"};
        my $cake1 = $meds->{"cake1:$bench"};
        my $cake2 = $meds->{"cake2:$bench"};
        my $cake3 = $meds->{"cake3:$bench"};

        my $sopt  = $cake0 * 100.0 / $cake1 - 100.0;
        my $sspec = $cake0 * 100.0 / $cake2 - 100.0;
        my $sboth = $cake0 * 100.0 / $cake3 - 100.0;
        my $svopt = $cake1 * 100.0 / $cake3 - 100.0;
        my $svsp  = $cake2 * 100.0 / $cake3 - 100.0;


        $su->printf("%-12s\t%10.02f %10.02f %10.02f %10.02f %10.02f\n", 
            $bench, $sopt, $sspec, $sboth, $svopt, $svsp);
    }
}

gen_charts("data/setup_times.csv", "setup");
gen_charts("data/exec_times.csv", "exec");
    
close $su;

system("cat data/speedups.txt");
