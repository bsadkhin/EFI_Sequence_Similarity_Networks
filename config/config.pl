use strict;
#This file is a loadable file that 
our %cfg;


{
#--------General-----------#
my $install_dir = "~/EFI/generateNetworks";
my $scripts_dir = "$install_dir/scripts";
my $config_dir  = "$install_dir/scripts/config";
#--------Step_Tne----------# 
my $step_one_clanfile = "";;
#--------Step_Two----------#
my $step_two_clanfile = "";
#--------Step_Three--------#
my $step_three_clanfile = "";

 
$cfg{'step-one'}{'dir'} = "/u/sciteam/sadkhin/scratch/blastClans2";

$cfg{'step-two'}{'dir'} = "/u/sciteam/sadkhin/scratch/blastClans2";
$cfg{'step-two'}{'fasta'} = "fasta/split";
$cfg{'step-two'}{'blast_db'} = "fasta" ;

$cfg{'step-three'}{'dir'} = "/u/sciteam/sadkhin/scratch/blastClans2";
$cfg{'step-three'}{'1out'} = "1out";
}










my $project_dir = "/u/sciteam/sadkhin/EFI/generateNetworks" ; #$ENV{'scripts_dir'}
my $blast_dir = "/u/sciteam/sadkhin/scratch/blastClans2";   #$ENV{'blast_dir'}
my $configuration_dir = "$project_dir/configuration/";
my $clan_list = "$configuration_dir/clans.tsv";
my $ordered_clan_list = "$configuration_dir/clans_smallest_from_largest";
my %configuration;
$configuration{'blastClans'} = $blast_dir;
my @list_of_directories = qw(fasta fasta/split log 1out);


#open F, $ordered_clan_list or die $!;
#my @clans_sorted = <



sub generateConfigurationFiles{
	generateBlastPieces();
}


sub generateQsubScripts{
	my $tar_qsub_path = create_tar_qsub();
	my $blast_qsub_path = create_blast_qsub_400();
	my $large_qsub_path = create_blast_qsub_large();
}


sub create_blast_qsub_400{
	
	for(my $i =0; $i < 400; $i++){




	}




}

