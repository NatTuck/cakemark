#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

our $RESULTS    = "results.csv";
our $SUMMARY    = "summary.csv";

our $MIN_TIME   = 0.5;

use Text::CSV;
use IO::Handle;

use PDL;
use PDL::Ufunc qw(avg);
use PDL::Stats::Basic qw(stdv t_test_nev);
use PDL::GSL::CDF qw(gsl_cdf_tdist_P);

sub read_results {
    open my $res, "<", $RESULTS;
    my $csv = Text::CSV->new();

    my $results = {};

    while (my $row = $csv->getline($res)) {
        my ($plat, $bench, $tag, $kern, $time) = @$row;
        next if $time < $MIN_TIME;

        $results->{$tag}{$plat}{$bench}{$kern} ||= [];
        push @{$results->{$tag}{$plat}{$bench}{$kern}}, $time;
    }

    close $res;

    return $results;
}

sub write_summary {
    open my $sum, ">", $SUMMARY;
    my $csv = Text::CSV->new();
    close $sum;
}

sub find_speedup {
    my ($rs) = @_;
    my $ke = $rs->{"kernel execution"};

    my $tbk = {};

    for my $plat (keys %$ke) {
        for my $bench (keys %{$ke->{$plat}}) {
            for my $kern (keys %{$ke->{$plat}{$bench}}) {
                $tbk->{"$bench:$kern"}{$plat} = 
                    pdl(@{$ke->{$plat}{$bench}{$kern}});
            }
        }
    }

    for my $kern (keys %$tbk) {
        my $cake = $tbk->{$kern}{cake};
        my $pocl = $tbk->{$kern}{pocl};

        my $cake_avg = avg($cake);
        my $cake_std = stdv($cake);
        my $pocl_avg = avg($pocl);
        my $pocl_std = stdv($pocl);

        my ($t, $df) = t_test_nev($cake, $pocl);
        my $p = gsl_cdf_tdist_P($t, $df);

        say "== $kern";
        say " cake: avg = $cake_avg; std = $cake_std";
        say " pocl: avg = $pocl_avg; std = $pocl_std";
        say " --> t = $t; df = $df; p = $p";
    }

    return $tbk;
}

my $rs = read_results();
my $sp = find_speedup($rs);

#use Data::Dumper;
#say Dumper($sp);
