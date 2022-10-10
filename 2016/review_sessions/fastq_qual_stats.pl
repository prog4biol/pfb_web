#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;
use Statistics::Descriptive;

main: { # I like working in main()
    if (@ARGV != 1 && @ARGV != 2) {
	die sprintf("Usage: %s <input.fastq> [qual_offset(33)]\n",basename($0));
    }
    my $fh;
    # user defines an offset, or assume 33
    my $quality_offset = $ARGV[1] || 33; 
    
    my @quals;
    my @lengths;
    my $sequence_count = 0;
    open($fh, '<', $ARGV[0]) or die "Cannot open $ARGV[0] for reading: $!\n";
    while (my $seq_header = <$fh>) {
	my $seq_string  = <$fh>;
	my $qual_header = <$fh>;
	my $qual_string = <$fh>;

	# We pulled 4 lines, but a truncated file will leave the last 3
	# values `undef', the first value will terminate the loop
	if (! defined($seq_string))  { die "Truncated file: $ARGV[0]\n" }
	if (! defined($qual_header)) { die "Truncated file: $ARGV[0]\n" }       
	if (! defined($qual_string)) { die "Truncated file: $ARGV[0]\n" }

	# In olden days, they used to wrap the FASTQ sequence and quality
	# strings like they do with FASTA files. This is no longer supported
	if ($qual_header !~ /^\+$/) { 
	    die "Wrapped FASTQ format not supported\n";
	}
	
	chomp $seq_string;
	chomp $qual_string;

	# split our quality string into an array and iterate over each
	# quality ASCII character into a quality value (- quality offset)
	for my $quality_char (split(//,$qual_string)) {
	    my $quality_value = ord($quality_char) - $quality_offset;
	    if ($quality_value < 0) {
		# A quality value < 33 means the user gave the wrong
		# quality offset value, let them know:
		die "Invalid quality value ($quality_value < 0), offending character '$quality_char'\n";
	    }
	    push(@quals, $quality_value);
	}
	push(@lengths, length($seq_string));

	$sequence_count++;
    }

    # Statistics::Descriptive requires you to add_data(), pre-calculates
    # the statistics, and caches the results, so we need two objects:
    my $length_stats = Statistics::Descriptive::Full->new();
    my $qual_stats = Statistics::Descriptive::Full->new();

    $length_stats->add_data(@lengths);
    $qual_stats->add_data(@quals);
    
    printf(STDOUT "$ARGV[0] (N=%d) read length: %0.3f (sd=%0.3f);  quality scores: %0.3f (sd=%0.3f)\n",
	   $sequence_count,
	   $length_stats->mean(),
	   $length_stats->standard_deviation(),
	   $qual_stats->mean(),
	   $qual_stats->standard_deviation()
	);
}
