#!/usr/bin/perl
# Calculate the number of each type of nucleotide substitution.
# ejr - 20161012
use strict;
use warnings;

my %subs;

open(IN, "ALL.chr22.txt") or die "cannot open file:$!\n";

while( my $line = <IN>) {
    chomp $line;
    my ($chr, $pos, $ref, $var) = split / +/, $line;
    # we only count substitutions, not insertions or deletions
    if (length($var) == 1 and length($ref) == 1) {
        my $type = $ref . " to " . $var;
        $subs{$type}++;
    }
}

# output counts of each substitution type
foreach my $type (sort keys %subs) {
    $subs{$type} = add_commas($subs{$type});
    printf("%s\t%8s\n", $type, $subs{$type});
}

# Subroutine to add commas as thousands separators
sub add_commas {
    my $number = shift;

    # Find the integer part of the number. By default we assume
    # that the number is an integer, but if we observe a '.' in
    # the number, then its a decimal and we must start from there
    my $integer = length($number);
    my $decimal = index($number, '.');
    if ($decimal >= 0) {
        $integer = $decimal;
    }

    # Don't want comma at decimal or end of integer, subtract 3
    # from initialing value.
    for(my $i = $integer - 3; $i > 0; $i -= 3) {
        substr($number,$i,0,',');
    }
    return $number;
}
