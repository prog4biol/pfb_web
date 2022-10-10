package FastaModule;
# Module: FastaModule
# Description: Contains subroutines for Fasta data
# Perl VIII Problem 5
# CSHL PFB
##################
# All subroutines require the fasta sequence
# reformatSeq requires an additional width
##################################################
use strict;
use base 'Exporter';

our @EXPORT = qw(getName getDesc getSeq reformatSeq);
	
## getName returns the sequence name
sub getName {
  my $fasta = shift @_;
  my $ret = "";
  my ($header,$seq) = split(/\n/,$fasta);
  if($header =~ m/^>(.+?)\s+.*/)
  {
     $ret = $1;
  }
  return $ret;
}

## getDesc returns the sequence description
sub getDesc {
  my $fasta = shift @_;
  my $ret = "";
  my ($header,$seq) = split(/\n/,$fasta);
  if($header =~ m/^>.+?\s+(.*)/)
  {
    $ret = $1;
  }
  return $ret;
}

## getSeq returns the actual sequence
sub getSeq {
  my $fasta = shift @_;
  my $ret = "";
  my ($header,$seq) = split(/\n/,$fasta);
  $ret = $seq;
  return $ret;
}

## reformatSeq changes the spacing to be a user specified width
sub reformatSeq {
  my $fasta = shift @_;
  my $size = shift @_;
  my $ret = "";
  my ($header,$seq) = split(/\n/,$fasta);
  if($seq =~ s/(.{$size})/$1\n/g)
  {
    $ret = $seq;
  }
  return $ret;
}

1;
