#!/usr/bin/env perl
#Calls Dan's filter script using a fasta file and a 
use strict;
require "/u/sciteam/sadkhin/EFI/generateNetworks/config/config.pl";
my %cfg = our %cfg;

my $clan = shift @ARGV;

if(!$clan){
	die "Enter a clan\n";
}
my $base_dir = $cfg{'step-three'}{'dir'};;
my $fasta_file = "$base_dir/$clan/fasta/$clan.fa";
my $blast_file = "$base_dir/$clan/1out/$clan.blast";
my $output     = "$base_dir/$clan/1out/1.out";
#my $script = $cfg{'scripts'}{'step-threeout'};
my $script     = "/u/sciteam/sadkhin/EFI/scripts/step-three_filterblast.pl";

if(not -e $fasta_file || not -e $blast_file || -z $fasta_file || -z $blast_file){
	print "Cannot proceed, no $fasta_file or no $blast_file, or zero sized";
	die;
}
if(-e $output && not -z $output){
	die "Skipping this file! 1out for $clan already exists!";

}


my $call = "perl $script $blast_file $fasta_file> $output.temp";
print "About to generate 1.out file for \n";
print "$call\n";
system($call);
print "1.out complete, moving \n $output.temp to \n $output \n";
if(-z "$output.temp"){
	die "EMPTY FILE! CAN'T MOVE $output \n!";
}
system("mv $output.temp $output");



