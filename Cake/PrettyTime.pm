package Cake::PrettyTime;
use 5.12.0;
use warnings FATAL => 'all';

our @ISA = qw(Exporter);
our @EXPORT = qw(pretty_time);

use POSIX qw(floor);

sub pretty_time {
    my ($secs) = @_;
    my $pretty = "";

    my $one_min   = 60;
    my $one_hour  = $one_min * 60;
    my $one_day   = $one_hour * 24;
    my $one_month = $one_day * 30;
    my $one_year  = $one_day * 365;

    if ($secs > $one_year) {
        my $years = floor($secs / $one_year);
        $secs    -= $years * $one_year;
        $pretty  .= "$years years, ";
    }
    
    if ($secs > $one_month) {
        my $mons = floor($secs / $one_month);
        $secs   -= $mons * $one_month;
        $pretty .= "$mons months, ";
    }
    
    if ($secs > $one_day) {
        my $days = floor($secs / $one_day);
        $secs   -= $days * $one_day;
        $pretty .= "$days days, ";
    }
    
    if ($secs > $one_hour) {
        my $hours = floor($secs / $one_hour);
        $secs    -= $hours * $one_hour;
        $pretty  .= "$hours hours, ";
    }
    
    if ($secs > $one_min) {
        my $mins = floor($secs / $one_min);
        $secs   -= $mins * $one_min;
        $pretty .= "$mins mins, ";
    }

    $pretty .= "$secs seconds";
    return $pretty;
}


1;
