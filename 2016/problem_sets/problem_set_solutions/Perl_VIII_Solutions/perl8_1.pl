#!/usr/bin/perl
# Perl VIII Problem 1
# CSHL PFB
####################
use warnings;
use strict;
use Math::Round;

my $usage = "$0 - rounds numbers entered on command line

$0 <num 1> ... <num n>
";
die $usage unless @ARGV;

# take numbers from command line
my @numbers = @ARGV;

# round them
my @rounded = round(@numbers);

# print them
print join(' ', @rounded), "\n";
