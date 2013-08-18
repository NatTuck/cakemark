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

our @OPTS = qw(-bb-vectorize);

our @EARLY = qw();
our @LATE  = qw(-dse);

our @EXPENSIVE = qw(-gvn -indvars -instcombine -loops -loop-unroll -loop-rotate 
                    -simplifycfg -earlycse -jump-threading -correlated-propagation
                    -loop-simplify -licm -lcssa);
