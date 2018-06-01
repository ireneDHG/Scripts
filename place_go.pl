#!/usr/bin/perl -w
#Script to place correctly GO terms

use strict;

while (my $line = <>)
{
	if ($line =~ /^(.*)\t(.*)$/)
		{
			my $familia = $1;
			my $genes = $2;
			
			my @lista = split /\, /,$genes;
			
			foreach my $gen (@lista)
			{
				print "$familia\t$gen\n";
			}
		}
	
}

exit;
