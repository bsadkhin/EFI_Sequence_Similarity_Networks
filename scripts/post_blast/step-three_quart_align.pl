#Calls quart-plots, reserves 3 cpus for each one
use strict;



my %names;

$names{'quart-align'}{'script'} = 'quart-align.pl';
$names{'quart-perid'}{'script'} = 'quart-perid.pl';
$names{'simple-graphs'}{'script'} = 'simple_graphs.pl';

$names{'quart-align'}{'output'} = 'alignment_length.png';
$names{'quart-perid'}{'output'} = 'percent_identity.png';
$names{'simple-graphs'}{'output'} = 'number_of_edges.png';

$names{'quart-align'}{'parameter'} = 'align';
$names{'quart-perid'}{'parameter'} = 'pid';
$names{'simple-graphs'}{'parameter'} = 'multiple';


my $job1 = 'quart-align';
my $job2 = 'quart-perid';
my $job3 = 'simple-graphs';

my $current_job = $job1;
my $script_name = $names{$current_job}{'script'};
my $parameter = $names{$current_job}{'parameter'};
my $outfile = $names{$current_job}{'output'};

my $clan = shift @ARGV;
my $dir  = "/u/sciteam/sadkhin/scratch/blastClans2/" . $clan;
my $blast_file  =  "$dir/1out/1.out";
my $output_file =  "$dir/1out/$outfile";
my $script ="/u/sciteam/sadkhin/EFI/scripts/step3/" . $script_name;

print "ABOUT TO CALL\n";
if(not -e $blast_file || -z $blast_file){
	die "Blast file $blast_file zero lenght or doesnt exist\n";
	
}
else{

	my $call = "perl $script -blastout $blast_file -$parameter $output_file.tmp";
	if($parameter eq 'multiple'){
#	print QSUB "$toolpath/simplegraphs.pl -blastout $ENV{PWD}/$tmpdir/1.out -edges $ENV{PWD}/$tmpdir/number_of_edges.png -fasta $ENV{PWD}/$tmpdir/sequences.fa -lengths $ENV{PWD}/$tmpdir/length_histogram.png -incfrac $incfrac\n";
		$call eq "perl $script -blastout $blast_file -edges $output_file.tmp -fasta $dir/$clan.fasta -lengths $dir/1out/$clan.blast";
	}	



	print "Generating alignment length plot for $clan\n";
	print "$call\n";
	sleep (5);
	system("$call");
	print "Generated plot '$current_job' > $output_file.tmp , moving from tmp to normal \n";
	if(-e "$output_file.tmp" && not -z "$output_file.tmp"){
		system("mv $output_file.tmp $output_file");
		print "Moved success\n";
	}
}

