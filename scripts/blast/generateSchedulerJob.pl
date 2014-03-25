use strict;

my $clan_list = '80clans';
#my $clan_list = 'clan_sorted_by_size_smallest_at_top';
my $clan_list = '65clans';

open F, $clan_list or die $!;
my @clans = <F>;
my $base_dir = "/scratch/sciteam/sadkhin/blastClans";
mkdir('jobs_created');

my $clanChunkSize = 20;
my @clanChunks ;

my $count =0;
my $clanChunkIndex = 0;
my %clans;

for(my $i = 0; $i < scalar @clans; $i++){
	my $clan = $clans[$i];
	chomp $clan;
	if($i != 0 && $i % 20 == 0){
		$clanChunkIndex ++;
	}
	print "pushing '$clan' to $clanChunkIndex\n";
	push @{$clanChunks[$clanChunkIndex]}, $clan;

}

for (my $clanChunkIndex = 0; $clanChunkIndex < scalar (@clanChunks) ; $clanChunkIndex++){

	my $clanChunkReference = $clanChunks[$clanChunkIndex];
	my @clans = @{$clanChunkReference};


	my $start = $clanChunkIndex * $clanChunkSize;
	my $stop = ($clanChunkIndex + 1) * $clanChunkSize;
	open O, ">jobs_created/clan_$start-$stop" or die $!;	
	print "About to print for clan $start $stop \n";
	foreach my $clan (@clans){
		$clan =~ s/\r|\n//g;

		my $count_command = "ls /scratch/sciteam/sadkhin/blastClans/$clan/fasta/split/ | wc -l";
	
		print $count_command, "\n";	
		my $count = `$count_command`;
		print $count;
		for(my $i =0; $i < $count; $i++){
			print O "$base_dir/$clan/log $clan.fa_$i\n";
		} 
	}
	close O;
}


sub generateQsub{
my $input_file = shift; #clan_o_
return
"


";
}



