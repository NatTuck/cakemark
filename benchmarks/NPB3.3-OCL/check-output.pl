#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

while (<>) {
    say "[cake: OK]" if /Verification\s+=\s+SUCCESSFUL/;
}
