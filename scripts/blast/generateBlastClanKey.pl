use strict;

my @list_of_clans = `ls ../blastClans`;

open F, '>blastClanKey' or die $!;

foreach my $clan (@list_of_clans){
	chomp $clan;
	my @parts = `ls ../blastClans/$clan/fasta/split | egrep -o "_[0-9]+" | egrep -o "[0-9]+" | sort -n`;
	my @chomp_parts;
	foreach my $part(@parts){
		chomp $part;
		push @chomp_parts, "$clan.fa_" . $part ;
	}
	#print F "$clan\t", (join ",",@chomp_parts), "\n";
	print F join ("\n", @chomp_parts),"\n";
}
close F;
