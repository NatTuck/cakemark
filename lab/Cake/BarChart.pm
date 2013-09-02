package Cake::BarChart;
use 5.12.0;
use warnings FATAL => 'all';

use File::Temp;
use IO::Handle;
use List::Util qw(max);

=head1

Usage:

  my $chart = Cake::BarChart->new(
      "Bar Chart",
      "Which Bar",
      "How High"
  );

  $chart->add("what", 5, 4.5, 5.5);

  $chart->write("output.pdf");

=cut

sub new {
    my ($class, $title, $xlabel, $ylabel) = @_;
    my $self = {
        title  => $title,
        xlabel => $xlabel,
        ylabel => $ylabel,
        bars   => [],
    };
    return bless $self, $class;
}

sub add {
    my ($self, $name, $med, $min, $max) = @_;
    push @{$self->{bars}}, [$name, $med, $min, $max];
}

sub write {
    my ($self, $filename) = @_;
    my $df = File::Temp->new();
    
    my @tics = ();
    my @tops = ();

    for (my $ii = 0; $ii < scalar @{$self->{bars}}; ++$ii) {
        my ($name, $med, $min, $max) = @{$self->{bars}[$ii]};
        push @tics, qq{"$name" $ii};
        push @tops, $max;

        $df->printf("$ii %.03f $min $max 0.5\n", $med);
    }

    my $gp = File::Temp->new();

    my $xtop = scalar @{$self->{bars}} - 0.5;
    my $ytop = 1.2 * max(@tops);

    my $xtics = join(", ", @tics); 
    
    $gp->say(<<"ENDGP");
set encoding utf8
set terminal pdfcairo mono dashed linewidth 2
set output "$filename"
set title  "${\$self->{title}}"
set xlabel "${\$self->{xlabel}}"
set ylabel "${\$self->{ylabel}}"
set xrange [-0.5:$xtop]
set yrange [0:$ytop]
set xtics  ($xtics) rotate by 90 offset 0.0,1.5
unset key

plot "$df" with boxerrorbars title "${\$self->{title}}", \\
    '' u 0:($ytop*0.9):(\$2) with labels
ENDGP
   
    say "  == gnuplot script:";
    system("cat $gp");
    say "  == chart data:";
    system("cat $df");

    system("gnuplot '$gp'");

}

1;
