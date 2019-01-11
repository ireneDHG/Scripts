#!/usr/bin/perl -w

#This scritp check two list of names and tell if the names of one list are present on the other
#Get files, store in array, check for duplicated and loop over to get present genes

#Call: check_presence_list.pl (optional > output.txt)

use strict;

open(my $in, "<","new_class.txt") or die "Unable to open the file\n";
chomp(my @nueva_uno = <$in>);
close $in;
my @nueva = ();
my @vieja=();
my %visto_antes=();
my %visto_antes2=();

#eliminar repetidos
foreach my $uno (@nueva_uno){
	push @nueva, $uno if not $visto_antes{$uno}++;
}

open(my $in2, "<", "old_class.txt") or die "Unable to open second file\n";
chomp(my @vieja_dos = <$in2>);
close $in2;

foreach my $dos (@vieja_dos){
	push @vieja, $dos if not $visto_antes2{$dos}++;
}

foreach my $new (@nueva){
	my $count = 0;
	foreach my $vie (@vieja){
		if ($new eq $vie){
			print "$new\t$vie\n";
			$count = 1;
		}
	}
	if($count == 0){
		print "$new\tno\n";
	}
}
