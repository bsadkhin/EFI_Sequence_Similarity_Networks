#!/usr/bin/env perl
#Splits clan blasts into 1.outs by using the accessionList
use strict;
#require "";
#my %cfg = our %cfg;

my $clan = shift;
my $dir  = "/u/sciteam/sadkhin/scratch/blastClans2/$clan";
my @list_of_accessionLists = `ls $dir/accessionList`;
my $blast_file = "$dir/1out/1.out";


if(not -e $blast_file || -z $blast_file){
	die "$blast_file does not exist\n";
}

print "\n";

foreach my $pfam_fp (@list_of_accessionLists){
	
	my %accessions;
	chomp $pfam_fp;


	my ($pfam,$rest) = split /\./, $pfam_fp;
	$pfam_fp = "$dir/accessionList/$pfam_fp";



	
		
	my $output_chunk = "$dir/1out/chunks/$pfam.1.out";		


	#Get list of accessions into memory
	open F, $pfam_fp or die $!. $pfam_fp;
	while( my $accession = <F>){
		chomp $accession;	
		$accessions{$accession} = undef;
	}
	close F;
	print "Got all acessions in $pfam_fp   \n";

	
	open O, ">$output_chunk" or die $! . " ERROR COULD NOT PRINT TO $output_chunk";
	open F, "$blast_file" or die $! . " ERROR COULD NOT READ $blast_file";
	while (my $line = <F>){
		my ($query,$hit) = split /\t/, $line, 3;
		if(exists $accessions{$query} and exists $accessions{$hit}){
			print O $line;
		}
	}
	close F;
	close O;
	print "Printed $clan:$blast_file for PFAM=$pfam to $output_chunk\n\n";



}
