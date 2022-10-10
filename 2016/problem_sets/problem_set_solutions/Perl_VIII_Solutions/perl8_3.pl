#!/usr/bin/perl
# Perl VIII Problem 3
# CSHL PFB
####################
use warnings;
use strict;
use PerlVII;

my $seq = shift @ARGV;
print reverse_complement($seq),"\n";

