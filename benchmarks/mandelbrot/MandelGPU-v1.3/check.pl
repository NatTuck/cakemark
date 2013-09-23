#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

use File::Temp;
my $cc = File::Temp->new();

system("gunzip -c image_correct.ppm.gz > '$cc'");
my $cmd = qq{LD_LIBRARY_PATH="/usr/local/lib" ../fuzzy_check image.ppm "$cc"};
say $cmd;
system($cmd);
system("cp $cc /tmp/mandelbrot.ppm");
