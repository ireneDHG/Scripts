#!/usr/bin/perl -w

use strict;

open my $in, '<', "conversion_fasta_transcripts.txt";
my @filas = <$in>;
my %ids=();
my $gene_id="";
my $new_id="";
my $last ="";
foreach my $fila (@filas)
{
	if ($fila =~ /^\>(CBGP\_AIM.*\-RA\|CBGP\_AIM.*\-RA)\t\>(Pc2127\-\d+\|v1)$/)
	{
		$gene_id =$1;
		$new_id = $2;
		$ids{$gene_id} = $new_id;
	}
}

#foreach my $key (keys %ids)
#{
#	my $value = $ids{$key};
#	print "  $key costs $value\n";
#}

while (my $line=<>)
{
	chomp $line;
	
	if($line=~ /\tgene\t/g)
	{
		#print "$line\n";
		if($line=~ /Name\=(CBGP\_AIM.*\-RA\|CBGP\_AIM.*\-RA)\-gene/g)
		{
			$gene_id=$1;
			#print "$gene_id\n";
			#print "$new_id\n";
			foreach my $key (keys %ids)
			{
				if($key eq $gene_id)
				{
					$last = $ids{$key};
					#print "$last\n";
				}
			}
		}
		$line =~ s/Name\=(CBGP\_AIM.*\-RA\|CBGP\_AIM.*\-RA)\-gene/$last\-gene/g;
		print "$line\n";
	}
	elsif ($line =~ /ID\=maker/g)
	{
		$line =~ s/ID\=(maker)/$last/g;
		print "$line\n";
	}
	else
	{
		print "$line\n";
	}
}


close $in;

exit;
