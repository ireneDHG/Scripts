#!/usr/bin/perl -w

# Convert ID script (FASTA format)
# Usage: perl change_id_gff.pl < input.gff > output.gff
# Requires conversion file

use strict;

# Open conversion file and store each line in an array
open my $in, '<', "conversion_fasta_transcripts.txt";
my @filas = <$in>;

my $new_id="";

while (my $line =<>)
{
	# If the line is the gene line, grab the old id and replace it with the new id in a new file
	chomp $line;
	if($line=~ /^NODE\_\d+\_length\_\d+\_cov\_\d+\.?\d+\tmaker\tgene\t/)
	{
		if($line =~ /Name\=(CBGP\_AIM.*\-RA)\-gene/g)
		{
			my $gene_id = $1;
			
			
			foreach my $fila (@filas)
			{
				if ($fila=~ /^\>($gene_id)\t\>(PcBMM\-\d+\|v1)$/)
				{
					$new_id = $2;
					
				
				}
			}
			
		}
		$line =~ s/Name\=(CBGP\_AIM.*\-RA)\-gene/$new_id\-gene/g;
		print "$line\n";
	}
	# Replace "maker" in every line for "new_id"
	elsif ($line =~ /ID\=maker/g)
	{
		$line =~ s/ID\=(maker)/$new_id/g;
		print "$line\n";
	}
	# Print any other line of the file
	else
	{
		print "$line\n";
	}
}

close $in;

exit;
