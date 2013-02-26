#!/usr/bin/perl
use 5.10.0;
use warnings FATAL => 'all';

use Cwd qw(abs_path);
$ENV{'BENCH_ROOT'} = abs_path($0);

