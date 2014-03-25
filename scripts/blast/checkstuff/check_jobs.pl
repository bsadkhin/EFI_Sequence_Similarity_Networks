#!/usr/bin/env perl
use strict;
$| = 1;

open F, '../clan_sorted_by_size_smallest_at_top' or die $!;
my @clans = <F>;
my $base_dir = "~/scratch/blastClans2";

my %clan;

foreach my $clan (@clans){
	chomp $clan;
	my $split_dir = "$base_dir/$clan/fasta/split";
	my $blast_dir = "$base_dir/$clan/blast";

	my $piece_count = `ls $split_dir | grep .fa | wc -l`;
	my $blast_count = `ls $blast_dir | grep "blast\$" | wc -l `;
	my $part_count  = `ls $blast_dir | grep "part\$"  | wc -l `;
	chomp($piece_count);chomp($blast_count);chomp($part_count);	



	$clan{$clan}{'expected'} = $piece_count;
	if($blast_count eq $piece_count){
		$clan{$clan}{'complete'} = 1;
		$clan{$clan}{'missing'} = 0;
	}
	else{
		$clan{$clan}{'complete'} = 0;
		$clan{$clan}{'missing'} = ($piece_count - $blast_count);

	}
}

foreach my $clan (@clans){
	if($clan{$clan}{'complete'}){
			print "$clan complete . Found $clan{$clan}{'expected'} blast files\n";
	}
        elsif( $clan{$clan}{'complete'} == 0){
        
                my $count = $clan{$clan}{'expected'} - $clan{$clan}{'missing'};
                print "$clan not complete. Missing";
                print " $clan{$clan}{'missing'} ";
                print " pieces of ";
                print "$clan{$clan}{'expected'}";
                print " pieces ($count complete) \n";
        }
}







