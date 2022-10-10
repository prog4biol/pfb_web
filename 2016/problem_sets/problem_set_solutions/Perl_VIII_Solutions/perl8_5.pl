#!/usr/bin/perl
# Perl VIII Problem 5
# CSHL PFB
####################
# FastaModule contains:
#   getName
#   getDesc
#   getSeq
#   reformatSeq
################################
use warnings;
use strict;
use Getopt::Long; # To provide command line arguments
use FastaModule; # Extra credit module

my $input;
my $new_size = 60; # default
my $help;

GetOptions ('i|input=s' => \$input,
            'h|help'    => \$help,
            's|size=i'  => \$new_size);

my $usage = "Usage: perl8_5.pl -i fastafile [-s new_size]";
die $usage if $help;

my %fasta; # array for fasta sequences
my $gene;

open(IN,'<',$input) or die "Can't open $input: $!\n";
while(my $line = <IN>)
{
  chomp $line;
  if($line =~ m/^(>.+)/)
  {
    $gene = $1;
  }
  else
  {
    $fasta{$gene} .= $line;
  }
}
close(IN);

## Call subs from FastaModule
foreach my $key (sort keys %fasta)
{
  ## Join the key with the sequence by "\n"
  my $fas = join("\n",$key,$fasta{$key});
  my $name = getName($fas);
  my $desc = getDesc($fas);
  my $seq = getSeq($fas);
  my $rf_seq = reformatSeq($fas,$new_size);
  
  print "$key\n";#::$fasta{$key}\n";
  print "\n\n";
  print "Name: $name\n";
  print "Desc: $desc\n";
  print "Seq: $seq\n";
  print "Formatted: $rf_seq\n";
  print "\n\n";
}
