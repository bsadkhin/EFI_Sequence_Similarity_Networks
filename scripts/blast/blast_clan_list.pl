#!/usr/bin/env perl

use strict;
    use Term::ANSIColor;

if(scalar @ARGV <2){
	die "not enough args\n";
}

my $clan =  $ARGV[0];
my @pieces = split /,/ , $ARGV[1];
@pieces = sort{ $a <=> $b} (@pieces);
my $base_dir = "/u/sciteam/sadkhin/EFI/blastClans";
my $blastall = '/u/sciteam/sadkhin/bin/blast-2.2.26/bin/blastall';
my $blast_db = "$base_dir/$clan/fasta/$clan.fa";

my $mkdir = "$base_dir/$clan/blast";
red( "Making $mkdir");
mkdir($mkdir);

foreach my $piece(@pieces){
    my $input_file = "$base_dir/$clan/fasta/split/$piece";
    my $output_file_temp = "$base_dir/$clan/blast/$piece.part";
    my $output_file_complete = "$base_dir/$clan/blast/$piece.blast";
   
	
	yellow( "\nAbout to blast $input_file \n" );

	#If the job is complete
    if(not (-e $output_file_complete) && not (-z $output_file_complete) ){
	green("$output_file_complete does not exist! \n");

        my $call = getBlastCall($input_file,$output_file_temp);
        print $call,"\n";
        system($call);
        
	if(-z $output_file_temp){
		die "Couldn't move an empty file! $output_file_temp didn't run successfully \n";
	}	
	my $mv = "mv $output_file_temp $output_file_complete";
        if(-e $output_file_complete){
		#Something must have happened , this shouldnt happen
		$mv .= ".duplicateComplete";
	}	

	print $mv,"\n";
        system($mv);
    }else{
	magenta( "$output_file_complete exists! Skipping ...\n");
    }
}

sub getBlastCall{
    my $input_file = shift;
    my $output_file_temp = shift;
    my $call = "$blastall -p blastp -v 50000 -m8 -e 1e-5 -d $blast_db -i $input_file -o $output_file_temp 2> $output_file_temp.stderr";
    return $call;
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
