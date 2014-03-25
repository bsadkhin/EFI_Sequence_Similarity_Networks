use strict;


my $clan_list = '65clans';
my $clan_list = '47clans';
my $clan_list = '22clans';
my $clan_list = '13clans';
my $clanNumber = '13';
my $clanDir = "single_clans$clanNumber";


open F, $clan_list or die $!;
my @clans = <F>;
my $base_dir = "/scratch/sciteam/sadkhin/blastClans";
mkdir($clanDir);
mkdir("$clanDir/qsub");
foreach my $clan (@clans){
	chomp $clan;
	open O, ">$clanDir/$clan" or die $!;
	print "About to print for clan $clan \n";

	my $count_command = "ls /scratch/sciteam/sadkhin/blastClans/$clan/fasta/split/ | grep fa | wc -l";
	print $count_command, "\n";	
	my $count = `$count_command`;
	print $count;
#	for(my $i =$count-1; $i >= 0; $i--){
#		print O "$base_dir/$clan/log $clan.fa_$i\n";
#	}
	for(my $i =0; $i < $count; $i++){
		print O "$base_dir/$clan/log $clan.fa_$i\n";
	}

	close O;
	open O, ">$clanDir/qsub/$clan.qsub" or die $!;
	my $qsub = generateQsub($clan);
	print O $qsub;
	close O;
}


sub generateQsub{
	my $clan = shift;
	return
"
#!/bin/sh
#PBS -j oe
#PBS -l nodes=60:ppn=32:xe
#PBS -l walltime=24:00:00
#PBS -q normal
#PBS -N $clan
".
"
cd /u/sciteam/sadkhin/EFI/scheduler/
source /opt/modules/default/init/bash
aprun -n 720 -N 12 -d 2 ./scheduler.x $clanDir/$clan /u/sciteam/sadkhin/EFI/scheduler/blast_a_clan_part.pl > logs/$clan";

}



