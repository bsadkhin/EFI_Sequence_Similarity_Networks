#!/usr/bin/env perl
#Checks to see if blast is done for a clan, and concatenates the blast jobs into one result.
use strict;
my $clan = shift;
if(!$clan){ die "Not enough args\n" ; }

my $dir = "/u/sciteam/sadkhin/scratch/blastClans2/$clan";
my $out_dir = "/u/sciteam/sadkhin/scratch/blastClans2/$clan/1out";
print "Creating dir $out_dir \n";
mkdir($out_dir);

my $blast_dir = $dir . "/blast";
my @blasts = `ls $blast_dir | grep -v '.stderr' `;
my @incomplete = `ls $blast_dir | grep part | grep -v '.stderr' `;
my @zero ;

foreach my $blast (@blasts){
	chomp $blast;
	my $blastfile = "$blast_dir/$blast";
	if (-z $blastfile ){
		push @zero, $blastfile;
	}else{
		$blast = "$blast_dir/$blast";}
}
if( scalar @incomplete > 0 || scalar @zero > 0){
	print "The following files are incomplete or zero size, skipping blast\n";
	print "@incomplete \n";
	print "zero";
	print "@zero \n";
}
else{
	print "All blasts completed for $clan";
	cat();
}

sub cat{
	print "\n About to cat for $clan to $out_dir \n";
	if( (not -e "$out_dir/$clan.blast")){
		print "$out_dir/$clan.blast does not exist! about to cat\n";
		my $cat = `cat @blasts > $out_dir/$clan.blast.cat`;
		print "Cat complete. moving $out_dir/$clan.blast.cat to $out_dir/$clan.blast\n";
		my $mv = `mv $out_dir/$clan.blast.cat $out_dir/$clan.blast`;
	}
	else{
		print "Cat Clan exists for $clan \n  skipping\n";
	}	



}

