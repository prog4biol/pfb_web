#!/usr/bin/env perl
# The above tells the unix environment to find Perl in the $PATH
# environment variable rather than using /usr/bin/perl directly.
# The above is more portable, because Perl may not always be
# installed in the same place. 
use strict;  # enforce predeclaring variables
use warnings;  # show us when we are committing an error
use Getopt::Std;  # Parse "standard" options off of the command line


sub usage {
    # This sub takes an optional message to write along with the
    # the usage documentation
    my $message = shift;

    # if $message was not given by the user, it will be undef.
    # avoid "Uninitialized use of..." errors when printing usage
    if (not defined($message)) {
	$message = '';
    }

    # Construct the usage string with the qq// quoting operator
    # to make it more readable here; sprintf() works the same as
    # printf(), but writes the output to a new string (not to 
    # screen). The %s insert strings, %d inserts integers, etc.
    # $0 is Perl's special variable holding the name of this script
    # In programmer parlance, <var> is a required arugment and
    # [var] denotes an optional argument.
    my $usage = sprintf(qq/
Usage:   $0 [options] <in.fastq> 

Options: -O <file>   Write output to file
         -o <int>    Quality offset (default: 33)
         -q <int>    Min. quality value (default: 0)
         -h          This help message

%s

/,$message);

    die $usage;
}

# When using getopts(), it is convenient to define a hash
# to hold default values, which may get replaced when the
# user defines options on the command line. If the user
# does not define options on the command line, then getopts()
# does not touch them. The first argument to getopts() is
# a "spec" string that defines which arguments are simply
# switches and which take values (determined by the `:'
# character). Values are stored in the %options hash via
# a hash reference. More information about getopts() can be
# found at cpan.org
my %options = ('o' => 33, 'q' => 0);
getopts('hO:o:q:',\%options);

# We need to check that the user has given us an input file
# if he/she has not given us an input file, let them know
# we need one: 
if (@ARGV != 1) {
    usage("Error: Not enough arguments");
}

# Assign more descriptive variables to use in our script
# One letter options are very confusing when used directly
# from the hash.
my $quality_offset = $options{'o'};
my $min_quality    = $options{'q'};
my $output_file    = $options{'O'};

# Ok, new trick: We can create a reference to a filehandle
# using the $fh = \*FILEHANDLE idiom. Don't over think it
# this is the only context in which you will see this. The
# following sets the default output to write to STDOUT if
# a file name is not given. If one is given, then open that
# file to the same variable, over-writing (re-directing) 
# the output to the new file.
my $output_filehandle = \*STDOUT;
if (defined($output_file)) {
    open($output_filehandle, '>', $output_file) or
	die "Cannot open $output_file for writing: $!\n";
}
# It is always a good idea to check that the user has given
# us the data types that we require. 
if ($quality_offset !~ /^\d+$/) {  # quality offset should be an integer
    usage("Error: positive integer quality_offset expected");
}
if ($min_quality !~ /^\d+$/) {  # minimum quality should be an integer
    usage("Error: positive integer min_quality expected");
}
if ($min_quality < 0) {  # minimum quality should be positive
    usage("Error: positive integer min_quality expected");
}

my $filename = shift;  # take in the input file name from @ARGV
open(FASTQ, '<', $filename) or
    die "Cannot open $filename for reading: $!\n";

# Ok, time to read in data. A FASTQ file, by definition, is always
# four lines long. We can read in four lines per iteration simply
# by calling <FILEHANDLE> in scalar context multiple times:
while (my $seq_header = <FASTQ>) {  # read in the header line
    my $seq_string  = <FASTQ>;  # read in the sequence string line
    my $qual_header = <FASTQ>;  # read in the `+' line
    my $qual_string = <FASTQ>;  # read in the quality string line

    # In the event that our file has been truncated (as can often
    # happen when a gzip file is corrupted durring file transfer
    # or an upstream process has terminated prematurely without us
    # noticing), $seq_string, $qual_header, or $qual_string will
    # be undef; when $seq_header is undef, the loop is terminated
    # and no error can be raised. Do the best check that we can
    # to determine if our file is complete:
    if (not defined($seq_string))  { die "Truncated file: $filename\n" }
    if (not defined($qual_header)) { die "Truncated file: $filename\n" }
    if (not defined($qual_string)) { die "Truncated file: $filename\n" }

    # Below, we must iterate over every character in the quality
    # string to determine where to cut the sequence, however we
    # still have "\n" on the ends of our sequence and quality
    # strings. In this state, this would cause us to iterate over
    # the sequence one more time than is appropriate (a "\n" is
    # considered a single character by the computer);
    chomp $seq_string;  # remove "\n" from the end of the sequence
    chomp $qual_string; # remove "\n" from the end of the quality

    # We need to identify the place in the read where the quality
    # drops below our designated minimum quality score threshold
    # and cut at that position, so this suggests that we need to
    # define a variable with a scope wider than just within the
    # loop:
    my $i = 0;
    # Use a `while' loop to iterated over the range of the read
    # (i.e., from 0 to the length of the read), otherwise we will
    # get index out of bounds errors. 
    while ($i < length($seq_string)) {
	# use the ord() function to convert ASCII characters
	# into their "ordinal" (numeric) values. Subtract the
	# quality offset in order to shift the numeric range
	# down to lower bound of zero.
	my $quality_value = ord(substr($qual_string,$i,1)) - $quality_offset;

	# Test if the decoded quality value is below our quality
	# threshold;
	if ($quality_value < $min_quality) {
	    last;  # jump directly out of the `while' loop
	}
	$i++;  # if `last' is executed above, $i is never incremented
    }
    # YAY! we have successfully iterated over the read.
    # if we observed a quality score less than $min_quality, then $i 
    # will be a value less than the length of the read. If we did not
    # observe any quality score less than $min_quality, then $i is
    # equivalent in value to the length of the read. Keep the sequence
    # (and qualities) starting at the beginning of the read (index = 0)
    # to $i:
    $seq_string = substr($seq_string,0, $i);
    $qual_string = substr($qual_string, 0, $i);

    # Writing sequences with no length to a file is crazy, issue a
    # warning to the user that these reads were discarded:
    if (length($seq_string) < 1) {
	warn "Sequence discarded, too short: $seq_header";
	next;  # next sequence
    }

    # We are done, write the data (but remember we chomped
    # $seq_string and $qual_string, so they need "\n"s!):
    print($output_filehandle $seq_header, $seq_string, "\n", 
	  $qual_header, $qual_string,"\n");
}
