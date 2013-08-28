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

<<<<<<< HEAD:Cake/OptGraph.pm
our @OPTS = qw(-bb-vectorize);
our @EARLY = qw();
our @LOOPS = qw();
our @LATE  = qw(-dse);
=======
>>>>>>> 3525cbe71c563409366c8a2e5630595bfbd048e5:lab/Cake/OptGraph.pm
our @EXPENSIVE = qw(-gvn -indvars -instcombine -loops -loop-unroll -loop-rotate 
                    -simplifycfg -earlycse -jump-threading -correlated-propagation
                    -loop-simplify -licm -lcssa);

<<<<<<< HEAD:Cake/OptGraph.pm

=======
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
>>>>>>> 3525cbe71c563409366c8a2e5630595bfbd048e5:lab/Cake/OptGraph.pm
