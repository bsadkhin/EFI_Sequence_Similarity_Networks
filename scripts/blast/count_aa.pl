#!/usr/bin/env perl
use strict;
use Cwd;
my $dir = getcwd;
$dir =~ /(CL[0-9]+\/)/;
my $clan = $1;
$clan =~ s/\///g;

my @ls;
for(my $i =0; $i < 31 ; $i++){
	push @ls, "$clan.fa_$i";

}



my $average_per_file;
my $count_per_file;

my %hash;
my $average_per_chunk;

foreach my $ls (@ls){
	chomp $ls;
	open F, $ls or die $!;
	print $ls,"\t";	
		while(<F>){
		if ( substr($_,0,1) eq ">"){
			$count_per_file++;
		}
		else{
			$average_per_file+= length $_;
		}

	}
	my $avg = $average_per_file / $count_per_file;
	$average_per_chunk += $avg;
	print "$avg\n";	
	$average_per_file = 0;
	$count_per_file = 0;

}
print $average_per_chunk / scalar @ls;
print "\n";
