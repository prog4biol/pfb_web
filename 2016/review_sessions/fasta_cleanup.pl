#!/usr/bin/env perl
# Author: Jessen V. Bredeson
# Contact: jessenbredeson@berkeley.edu

use strict;
use warnings;
use Getopt::Std;
use File::Basename;



sub printCleanSequence {
    my $header = shift;
    my $sequence = shift;
    my $width = shift;

    # Extract the header info or die()
    $header =~ /^>(\S+)\s*(.*)/ or
	die "Error: Invalid FASTA header format: $header\n";

    # We need to store the contents of $1 and $2 into new
    # variables because their contents are deleted when we
    # use another regular expression
    my $identifier = $1;
    my $description = $2;

    # Remove any extraneous characters (including whitespace)
    $sequence =~ s/[^a-zA-Z]//g;

    # Break the sequence into lines $width chars wide. if we use
    # the pattern s/(.{$width})/$1\n/, then only sequences an exact 
    # multiple of $width will get a "\n" at the end. This creates
    # inconsistency, so use the pattern below instead ($sequence
    # is edited in-place, so we don't need to define a new variable):
    $sequence =~ s/(.{1,$width})/$1\n/g;

    print(">$identifier $description\n$sequence");    
}

    
sub usage {
    my $message = shift;
    if (not defined($message)) {
	$message = '';
    }
    die sprintf(qq/
Usage: %s [-h] [--help] <file.fasta> [line_width]

Notes: 
  Parses an input FASTA file, cleans and wraps the 
  sequence into multi-line format and writes the
  output to stdout. Default width is 50 characters.

%s/,basename($0),$message);
    
	
}


main: {  # create a nice main block to work in to organize our code
    if (grep {/^-h$|^--help$/} @ARGV) {  # if the user calls for help
	usage();  # don't need an error message, usage is enough
    }
    # C'mon user, the input fasta file is required...
    if (not defined($ARGV[0])) {
	usage("Error: No input FASTA file given.\n\n");
    }

    my $fasta_file = shift;  
    my $fasta_fh;
    open($fasta_fh, '<', $fasta_file) or
	usage("Error: Cannot open $fasta_file for reading: $!\n\n");
    
    my $width = 50;
    if (defined($ARGV[0])) {
	if ($ARGV[0] !~ /^\d+$/) {
	    die "Error: Line width must be a positive integer\n";
	}
	$width = $ARGV[0];
    }

    # General strategy: We are not comparing any sequences and are only 
    #  performing an operation (i.e. sequence wrapping) on one sequence
    #  at a time; so read in a sequence, wrap it, and print it before 
    #  reading in the next, keeping our program lean-and-mean. This is
    #  more important when dealing with very large FASTA files.

    # The FASTA format is not a single-line oriented format (it is spread
    #  across multiple lines), so we need to be able to store the FASTA 
    #  record header line in memory to be able to use it; put it in a global 
    #  variable. And because FASTA record sequences can be wrapped across
    #  multiple lines, we must be able to remember all of the previous
    #  sequence we saw in previous lines, so we need another global variable.
    my $header ='';
    my $sequence = '';
    # Detailed strategy:
    #  Follow the steps below in sequence by step number with a FASTA file
    #  open in another window and/or run this script in debugger. Much can
    #  be learned about the line-by-line nature of parsing with a FASTA file
    #  For every line of FASTA file input, evaluate each line of code below
    #  (in your head or debugger), following the control structures as 
    #  appropriate.
    while (my $line = <$fasta_fh>) {  # (1 & 6 & 9) Pull one line from the file
	chomp($line);  # (2 & 7 & 10) remove "\n" from end

	if ($line =~ /^>/) {  # (3 & 11) Is the line a FASTA header line? 
	    # We do not yet want to print the FASTA record when we 
	    # observe the first FASTA record header line, because 
	    # we haven't yet read in its sequence, so this suggests
	    # that we can use $sequence as a "switch" to tell Perl
	    # whether to print the record yet or wait until later.
	    # $sequence will evaluate to false when we observe the
	    # first FASTA record header because $sequence is an empty
	    # string

	    if ($sequence) {  # (8 & 12) false at first header, true afterward
		# (13) Pass the data along to subroutines to clean up
		#      the sequence and print.  
		printCleanSequence($header, $sequence, $width);
	    }
	    $header = $line;  # (4 & 14) Store the FASTA header line for later
	    $sequence = '';   # (5 & 15) Re-initialize $sequence for appending
	    # (15) This clears out the previous sequence when we we are 
	    #      done with it (i.e. we have printed it to file) so that
	    #      we can start storing/appending the current sequence. 
	    
	} else {  # (7) The line is a sequence line
	    # (8) Append the (potentially) partial sequence to our global
	    #     variable
	    $sequence .= $line;  
	}
    }
    # At the end of the FASTA file, drop out of the `while' loop, but we havent
    # yet printed the last FASTA record, so we need to do this. Why the `if'
    # condition below? Because if we tried to read in an empty file (as can 
    # happen), $header and $sequence are still emptyy and would print an empty
    # record to the file, which we typically don't want
    if ($header) {  # (16) Do we have a record?
	# (17) Pass the data along to subroutines to clean up
	#      the sequence and print.
	printCleanSequence($header, $sequence, $width);
    }
}
