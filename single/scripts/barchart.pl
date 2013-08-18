#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

my $filename = shift @ARGV
    or die "Usage: ./$0 file.bars";

my $title = shift @ARGV;

our $dirname;
BEGIN { $dirname = `dirname $0`; chomp $dirname; }
use lib $dirname;
use Cake::BarChart;
use PDL;
use PDL::Stats::Basic;

my $data = {};
my @tags = ();

open my $file, "<", $filename;
my ($xlabel, @names) = split /\s+/, <$file>;

my %seen = ();

while (<$file>) {
    my ($tag, @samps) = split /\s+/;

    push @tags, $tag unless defined $seen{$tag};
    $seen{$tag} = 1;
    
    for (my $ii = 0; $ii < scalar @names; ++$ii) {
        my $name = $names[$ii];
        my $samp = $samps[$ii];

        $data->{$name}{$tag} ||= [];
        push @{$data->{$name}{$tag}}, $samp;
    }

}

close $file;

for my $name (sort keys %$data) {
    my $outn = $title || $filename;
    $outn =~ s/\..*$//;

    my $chart = Cake::BarChart->new("$outn $name", $xlabel, "Time (s)");
    
    for my $tag (@tags) {
        my $pdl = pdl $data->{$name}{$tag};
        $tag =~ s/^\d+\-//;
        $chart->add($tag, median($pdl), min($pdl), max($pdl));
    }

    $chart->write("$outn-$name.pdf");
}

