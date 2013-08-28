#!/usr/bin/perl
use 5.12.0;
use warnings FATAL => 'all';

use IO::Handle;
use PDL;
use PDL::Stats::Basic;

my %ots  = ();
my %rts  = ();

open my $perms, "<", "blur.perms";
my $hdrs = <$perms>;

while (<$perms>) {
    my ($ot, $rt, $spec, $flags) = split(/\t+/);
    my $key = "$spec $flags";

    $ots{$key} ||= [];
    push @{$ots{$key}}, $ot;

    $rts{$key} ||= [];
    push @{$rts{$key}}, $rt;
}

close $perms;

open my $meds, ">", "blur.meds";

$meds->say("opt-time, run-time, spec, flags");

for my $key (keys %ots) {
    my $opdl = pdl $ots{$key};
    my $omed = median($opdl);
    my $rpdl = pdl $rts{$key};
    my $rmed = median($rpdl);

    $key =~ /^(\d+)\s*(.*)$/;
    my ($spec, $flags) = ($1, $2);

    $flags =~ s/-(instcombine|reassociate|simplifycfg|reassociate|instcombine|dse|adce)\s*//g;

    $meds->say("$omed, $rmed, $spec, $flags");
}

close $meds;
