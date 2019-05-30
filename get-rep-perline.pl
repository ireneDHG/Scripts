#!/usr/bin/perl -w

use strict;

my %site1 = ();
my %site2 = ();
my %site3 = ();
my @array1=();
my @array2=();
my @array3=();
my $line1="";
my $line2="";
my $line3="";

while (my $line = <>){
	chomp $line;
	#print "$line\n";
	if ($line=~ /^SITE1/){
		$line1=$line;
	}
	elsif($line=~ /^SITE2/){
		$line2=$line;
	}
	elsif($line=~ /^SITE3/){
		$line3=$line;
	}
	
}
@array1 = split('\t',$line1); shift(@array1);
@array2 = split('\t',$line2); shift(@array2);
@array3 = split('\t',$line3); shift(@array3);

#foreach my $elem1 (@array1){
#3	print "$elem1\n";
#}

for (@array1){
	$site1{$_}++;
}
for (@array2){
	$site2{$_}++;
}
for (@array3){
	$site3{$_}++;
}

print "SITE1\n";
foreach my $key (sort { $site1{$a} <=> $site1{$b} or $a cmp $b } keys %site1) {
	printf "%-8s %s\n", $key, $site1{$key};
}

print "\nSITE2\n";
foreach my $key (sort { $site2{$a} <=> $site2{$b} or $a cmp $b } keys %site2) {
	printf "%-8s %s\n", $key, $site2{$key};
}

print "\nSITE3\n";
foreach my $key (sort { $site3{$a} <=> $site3{$b} or $a cmp $b } keys %site3) {
	printf "%-8s %s\n", $key, $site3{$key};
}


	
exit;