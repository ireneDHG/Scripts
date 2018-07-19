#!/usr/bin/perl -w

#Convert ID script (FASTA format)
#Usage: perl change_id_gff.pl < input.gff > output.gff
#Requires conversion file

use strict;

open my $in, '<', "conversion_fasta_transcripts.txt";
my @filas = <$in>;

my $new_id="";

while (my $line =<>)
{
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
	elsif ($line =~ /ID\=maker/g)
	{
		$line =~ s/ID\=(maker)/$new_id/g;
		print "$line\n";
	}
	else
	{
		print "$line\n";
	}
}

close $in;

exit;
