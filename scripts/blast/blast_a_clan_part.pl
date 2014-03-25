#!/usr/bin/env perl

use strict;
use Term::ANSIColor;

if(scalar @ARGV <1){
	die "not enough args\n";
}

my $clan_piece =  $ARGV[0];
my ($clan,$rest) = split /\./, $clan_piece;

#Prepare Variables
my $base_dir = "/scratch/sciteam/sadkhin/blastClans2";
my $blastall = '/u/sciteam/sadkhin/bin/blast-2.2.26/bin/blastall';
my $blast_db = "$base_dir/$clan/fasta/$clan.fa";
chomp(my $b = `LC_ALL=C fgrep ">" $blast_db  | wc -l`);


#Make a directory, or if it exists do nothing
my $mkdir = "$base_dir/$clan/blast";
if(not -e $mkdir){
  print( "Making $mkdir");
  mkdir($mkdir);
}


#Prepare Blast
my $input_file = "$base_dir/$clan/fasta/split/$clan_piece";
my $output_file_temp = "$base_dir/$clan/blast/$clan_piece.part";
my $output_file_complete = "$base_dir/$clan/blast/$clan_piece.blast";
my $call = "$blastall -p blastp -b $b  -m8 -e 1e-5 -d $blast_db -i $input_file -o $output_file_temp 2> $output_file_temp.stderr";

#Prepare to Call!
yellow( "\nAbout to blast $input_file \n" );

#Did this job run already?
shouldIRun();

#If so, we can either rerun it safely, or die because something weird happened




sub shouldIRun{

	if(-e $output_file_complete && not -z $output_file_complete){
		green("Blast for $clan_piece is done. Skipping ... \n");exit 0; #LINE 49
	}
	else{
		if(-e $output_file_complete && -z $output_file_complete){
			red("Zero size $output_file_complete \n");
		}
		if( unlink ($output_file_temp) ){
			magenta("Removed $output_file_temp\n");
		}
		unlink ($output_file_complete);
		run_the_job();
	}
}

sub run_the_job(){  
	print "$call\n";system($call);move(); #LINE 70
}

sub move{
	if(not -e $output_file_temp){
		red("Couldn't move as no file was generated! \n");exit 1; #LINE 75
	}
	elsif( -z $output_file_temp){
		red("Didn't want to move an empty file! Something went wrong! \n");exit 1; #LINE 78
	}	
	my $mv ="";
	$mv = "mv $output_file_temp $output_file_complete";
	my $move_result = system($mv);
	print "MOVE RESULT = $move_result \n";

	if($move_result == 0) {
		green("Just moved $mv \n");
	}
	else{
		red("Failed to move $mv\n");
	}
	exit(0); #LINE 92

}




sub magenta{
	print color 'magenta';
	print @_;
	print color 'reset';
}
sub red{
	print color 'red';
	print @_;
	print color 'reset';
}

sub green{
	print color 'green';
	print @_;
	print color 'reset';
}

sub yellow{
	print color 'yellow';
	print @_;
	print color 'reset';

}
