#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

my $text = '';

while (<>) {
    $text .= $_;
    if (/^PASSED/) {
        say "[cake: OK]";
        exit(0);
    }
}

say $text;
say "\n\nVerification failed.";
