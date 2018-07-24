#!/usr/bin/perl -w

# Convert ID script (FASTA format)
# Usage: perl change_id_fasta.pl < input.fasta > output.fasta
# Creates conversion file

use strict;

open(OUT, ">>conversion_fasta_transcripts.txt") or die "Unable to create/open the file\n";

# Inizialization of variables and counter
my $count = 0;
my $new_id ="";
my $new_line="";

# Read lines of the input file
while (my $line = <>) 
{
	# If line has old identifier, chomp it and create new identifier
	if($line=~/^(\>CBGP\_AIM.*\-RA)/g)
	{
		chomp $line;
		my $old_id = $1;
		$count++;
		my $string = sprintf("%05d",$count);
		$new_id = "\>PcBMM\-" . $string;
		my $line2 = $line;
		$line2 =~s/\>CBGP\_AIM.*\-RA/$new_id/g;
		print "$line2\n";
	
		print OUT "$old_id\t$new_id\n";
		
		
	}
	# If it hasn't print the line anyway
	else {
	print $line;
	}
}

# Close output file
close(OUT);


exit;
		
		
