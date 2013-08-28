package Cake::OptFlags;
use 5.12.0;
use warnings FATAL => 'all';

# This module generates lists of llvm opt flags to allow
# timing information to be tested.

sub get_data {
    my ($tag) = @_;
    seek DATA, 0, 0;
    while (<DATA>) {
        chomp;
        next unless /^$tag:/;
        s/^$tag:\s*//;
        return $_;
    }
    die "No such data tag: $tag";
}

# This sub provides a list of LLVM flag sets by taking std-compile-opts
# and knocking out one optimization flag at a time.
#
# Each item in the return list is a pair [ops, knocked-out-op]

sub knockout_seq {
    my $std = get_data('std');
    my $ops = get_data('ops');

    my @seq = ();
    push @seq, [$std, "0base"];

    for my $op (split /\s+/, $ops) {
        my $flags = $std;
        $flags =~ s/\b$op\b//g;
        push @seq, [$flags, $op];
    }

    return @seq;
}

1;

__DATA__
std: -targetlibinfo -no-aa -tbaa -basicaa -notti -preverify -domtree -verify -globalopt -ipsccp -deadargelim -instcombine -simplifycfg -basiccg -prune-eh -inline-cost -inline -functionattrs -argpromotion -sroa -domtree -early-cse -simplify-libcalls -lazy-value-info -jump-threading -correlated-propagation -simplifycfg -instcombine -tailcallelim -simplifycfg -reassociate -domtree -loops -loop-simplify -lcssa -loop-rotate -licm -lcssa -loop-unswitch -instcombine -scalar-evolution -loop-simplify -lcssa -indvars -loop-idiom -loop-deletion -loop-unroll -memdep -gvn -memdep -memcpyopt -sccp -instcombine -lazy-value-info -jump-threading -correlated-propagation -domtree -memdep -dse -adce -simplifycfg -instcombine -strip-dead-prototypes -globaldce -constmerge -domtree -loops -loop-simplify -lcssa -scalar-evolution -loop-simplify -lcssa -loop-vectorize -scalar-evolution -bb-vectorize -preverify -verify
unroll: -reassociate -loop-simplify -indvars -licm -loop-unswitch -loop-unroll -gvn -sccp -loop-deletion -instcombine -adce -simplifycfg -loop-simplify -unroll-allow-partial
ops: -globalopt -ipsccp -inline -sroa -simplify-libcalls -jump-threading -correlated-propagation -tailcallelim -reassociate -loop-simplify -loop-rotate -licm -loop-unswitch -loop-simplify -indvars -loop-idiom -loop-deletion -loop-unroll -gvn -sccp -adce -globaldce -scalar-evolution -loop-vectorize -bb-vectorize
