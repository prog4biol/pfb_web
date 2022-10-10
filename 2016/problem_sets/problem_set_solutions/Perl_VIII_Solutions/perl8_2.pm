package PerlVIII;
# Module: PerlVIII.pm
# Description: Contains reformat and reverse complement subroutines
# CSHL PFB
##################
use strict;

sub reformat_seq {
  my $seq = shift @_;
  my $size = shift @_;
  my @rf_seq;
  for(my $i=0;$i<length($seq);$i+=$size)
  {
    push (@rf_seq, substr($seq,$i,$size));
  }
  return @rf_seq
}

sub reverse_complement{
  # Get the parameter nucleotide string
  my $str = shift;

  # Reverse complement the string
  $str =~ tr/ATGC/TACG/;
  $str = reverse($str);

  # Return reverse complemented string
  return $str;
}

1;
