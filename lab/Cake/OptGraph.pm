package Cake::OptGraph;
use 5.12.0;
use warnings FATAL => 'all';

our %OG = (
    '-adce' => {},
    '-bb-vectorize' => {},
    '-correlated-propagation' => {},
    '-dse' => {},
    '-early-cse' => {},
    '-gvn' => {},
    '-indvars' => {},
    '-instcombine' => {},
    '-jump-threading' => {},
    '-lcssa' => {},
    '-licm' => {},
    '-loop-deletion' => {},
    '-loop-reduce' => {},
    '-loop-rotate' => {},
    '-loop-simplify' => {},
    '-loop-unroll' => { req => qw(-loop-rotate) },
    '-loop-unswitch' => { req => qw(-licm) },
    '-loop-vectorize'=> {},
    '-mem2reg' => {},
    '-reassociate' => {},
    '-sccp' => {},
    '-simplifycfg' => {},
    '-sink' => {},
    '-sroa' => {},
);

our @EXPENSIVE = qw(-gvn -indvars -instcombine -loops -loop-unroll -loop-rotate 
                    -simplifycfg -earlycse -jump-threading -correlated-propagation
                    -loop-simplify -licm -lcssa);

=head1

Setup Opts:
  -mem2reg -inline -globaldce -sroa

Aggressive renormalization:
  -instcombine -reassociate -simplifycfg -reassociate -instcombine -dse -adce

Early opts:
  -gvn -sccp -sink -jump-threading -correlated-propagation 

Loop setup:
  -loop-simplify -lcssa -loop-rotate -licm -lcssa

Loop goals:
  -loop-unswitch -loop-unroll -loop-vectorize

Loop cleanup:
  -loop-deletion -loop-reduce

Later opts:
  (Same as early opts)

=cut
