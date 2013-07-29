#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

use File::Temp;
my $cc = File::Temp->new();

system("gunzip -c image_correct.ppm.gz > '$cc'");
system("cmp image.ppm '$cc' && echo [cake: OK]");
