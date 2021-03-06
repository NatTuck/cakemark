#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

our @BENCHMARKS = qw(mmul blur gaussian mandelbrot nas-ft particlefilter);
#our @BENCHMARKS = qw(blur gaussian mandelbrot mmul nas-cg nas-ep nas-ft nas-is
#                     nas-lu nas-sp particlefilter);

our $OPT_EARLY = ""; 
#our $OPT_LATER = ""; # Flags sets go here.
our $OPT_EXTRA = "-globaldce"; # Needs this for some reason.

our $REPEAT     = 5;
our $SETUP      = "data/setup_times.csv";
our $EXECUTION  = "data/exec_times.csv";

use Cake::OptFlags;

my @FLAG_SETS = Cake::OptFlags::knockout_seq();

use Cake::Benchmark;
use Cake::PrettyTime;

use Cwd qw(abs_path);
use File::Basename;
use Text::CSV;
use IO::Handle;
use Data::Dumper;
use URI::Encode qw(uri_encode uri_decode);

my $start_time = time();

chdir(dirname(abs_path($0)));

my @cases = ();
my $pn = 0;

for my $spec ((0, 1)) {
    for my $flagset (@FLAG_SETS) {
        my ($flags, $label) = @$flagset;

        for my $bench (@BENCHMARKS) {
            my $opts = {};
            $opts->{spec}  = 1 if ($spec);
            
            $opts->{early} = $OPT_EARLY;
            $opts->{later} = $flags;
            $opts->{extra} = $OPT_EXTRA;

            push @cases, [$pn, $bench, "cake", $opts, $label];
        }
        $pn += 1;
    }
}

my $count = scalar @cases;

open my $s_out, ">", $SETUP or die "Fail $!";
open my $e_out, ">", $EXECUTION or die "Fail $!";

my $csv = Text::CSV->new();

sub benchmark_once ($$$$$$) {
    my ($pn, $ii, $bench, $plat, $opts, $label) = @_;

    my $times = run_benchmark($bench, $plat, $opts);
    die "No execute times" unless defined $times->{execute};
    die "No setup times" unless defined $times->{parallel_bc};

    my $spec = $opts->{spec} ? 1 : 0;

    $plat = "$plat$pn";
    
    for my $kk (keys %{$times->{parallel_bc}}) {
        my $time = $times->{parallel_bc}{$kk};
        $csv->print($s_out, [$plat, $ii, $bench, $kk, $time, $spec, $label]);
        $s_out->print("\n");
    }
    
    for my $kk (keys %{$times->{execute}}) {
        my $time = $times->{execute}{$kk};
        $csv->print($e_out, [$plat, $ii, $bench, $kk, $time, $spec, $label]);
        $e_out->print("\n");
    }
}

my $total_runs = $count * $REPEAT;

for (my $case_ii = 0; $case_ii < scalar @cases; ++$case_ii) {
    my $case = $cases[$case_ii];
    my ($pn, $bench, $plat, $opts, $label) = @$case;
    say "$bench, $plat";
    say Dumper($opts);

    for (my $ii = 0; $ii < $REPEAT; ++$ii) {
        my $rnum = $case_ii * $REPEAT + $ii;
        say "Run #$rnum / $total_runs";
        benchmark_once($pn, $ii, $bench, $plat, $opts, $label);
    }
}

close $s_out;
close $e_out;

my $end_time = time();
my $elapsed  = $end_time - $start_time;

my $total = $count * $REPEAT;

my $pretty_elapsed = pretty_time($elapsed);

say "  == Run Completed ==";
say "Executed $count cases ($total tests) in";
say $pretty_elapsed;

my $ping_subj = uri_encode("cakemark done");
my $ping_host = `hostname`; chomp $ping_host;
my $ping_body = uri_encode("Test run done on $ping_host: " .
    "$total tests in $pretty_elapsed");

system(qq{curl "http://www.ferrus.net/ping.php?} .
    qq{subject=$ping_subj&message=$ping_body"});
