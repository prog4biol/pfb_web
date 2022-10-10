#!/usr/bin/perl
# File: arrayEvenuthor: Steven Ahrendt
# Author: Steven Ahrendt

use strict;
use warnings;

my @array = (101,2,15,22,95,33,2,27,72,15,52);

## Here, a for loop is more appropriate because
#   We are interested in doing something to the index
for(my $i=0; $i<scalar(@array); $i++)
{   
  ## One line 'if' statement
  print "$i\t$array[$i]\n" if ($i%2 != 0);
} 
