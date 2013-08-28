package Cake::OptGraph;
use 5.12.0;
use warnings FATAL => 'all';

our %OG = (
    '-adce' => {},                       # DCE
    '-bb-vectorize' => {},               # Unroll
    '-correlated-propagation' => {},     # Prop
    '-dse' => {},                        # DCE
    '-early-cse' => {},                  # Prop
    '-gvn' => {},
    '-indvars' => {},                    # Loop
    '-instcombine' => {},
    '-jump-threading' => {},
    '-lcssa' => {},                      # Loop
    '-licm' => {},
    '-loop-deletion' => {},              # DCE
    '-loop-reduce' => {},                # Loop
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
our @LOOPS = qw();
our @LATE  = qw(-dse);
our @EXPENSIVE = qw(-gvn -indvars -instcombine -loops -loop-unroll -loop-rotate 
                    -simplifycfg -earlycse -jump-threading -correlated-propagation
                    -loop-simplify -licm -lcssa);


