#!/usr/bin/perl -w

use strict;

open(OUT, ">>conversion_maker2NewID.txt") or die "Unable to create the file\n";
my $maker_id="";
my $newID = "";
my $count=0;

while(my $line =<>)
{
	#NODE_66_length_160614_cov_1.03716	maker	gene	5845	6531	.	+	.	ID=maker-NODE_66_length_160614_cov_1.03716-exonerate_est2genome-gene-0.0;Pc0831-00001|v1-gene
	#scaffold10.1|size502316	maker	gene	1405	3611	.	+	.	ID=maker-scaffold10.1|size502316-exonerate_est2genome-gene-0.0;Pc2127-00001|v1-gene

	chomp $line;
	#print "$line\n";
	if($line =~ /^scaffold\d+.?\d+\|size\d+\tmaker\tgene\t/g)
	{
		#print "$line\n";
	
		if($line =~ /ID\=(maker\-scaffold\d+.?\d+\|size\d+\-exonerate\_est2genome\-gene\-\d+\.?\d+)\;(.*\-?.*\|?.*)\-gene/g)
		{
			#print "hola\n";
			$count++;
			$maker_id =$1;
			$newID=$2;
			print OUT "$maker_id\-mRNA\-1\t$newID\n";
		}
	}
}

#print "$count\n";
