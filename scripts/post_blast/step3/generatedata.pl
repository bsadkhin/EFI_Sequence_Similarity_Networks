#!/usr/bin/env perl
#version 0.1 the make it work version
#version 0.2 combined initial db creation, population, and pythoscape scripts up to inserting edges
#version 0.2.1 added expression line to select type of search done in plugin1 of initial_import.py, added capacity to include sequence length
#version 0.3.0 added ability to input edges through Input_edges.pl
#version 0.5.0 added ability to create quartiles, bandpass sequences based off length, and fixed a problem in fracfile when np was around the number of sequences in a file.
#version 0.6.0 removed ability to create quartiles, removed use of mysql database, the first pure perl version
#version 0.7.0 major rewrite, removes need for mysql database, remove all of original pythoscape code
#version 0.8.0 split pipeline into two parts, added code to create quartiles
#version 0.8.1 Added ability to run program off pfam or Interpro numbers
#version 0.8.3 Added ability to run program off Tax IDs
#version 0.8.5 Added $maxhits (set to 50,000 for now) so we can get up to 50k results from a single blast search
#version 0.9.0 Updated from the getsequence.pl progrma to sqlite-getsequence (new file uses sqlite db of match_coplete and also allows for ssf and gene3d numbers to generate networks.

#perl module for loading command line options
use Getopt::Long;
#for testing various stages, comment out prior backtick lines to keep from re-running jobs

$result=GetOptions ("fasta=s"		=> \$file,
		    "np=i"		=> \$np,
		    "queue=s"		=> \$queue,
		    "tmp=s"		=> \$tmpdir,
		    "evalue=s"		=> \$evalue,
		    "flat=s"		=> \$flat,
		    "hilen=i"		=> \$hilen,
		    "lowlen=i"		=> \$lowlen,
		    "maxlen=i"		=> \$maxlen,
		    "minlen=i"		=> \$minlen,
		    "expression=s"	=> \$expression,
		    "incfrac=f"		=> \$incfrac,
		    "ipro=s"		=> \$ipro,
		    "pfam=s"		=> \$pfam,
		    "taxid=s"		=> \$taxid,
		    "gene3d=s"		=> \$gene3d,
		    "ssf=s"		=> \$ssf,
		    "blasthits=i"	=> \$blasthits,
		    "memqueue=s"	=> \$memqueue,
		    "maxsequence=s"	=> \$maxsequence);

$toolpath=$ENV{'EFIEST'};
$efiestmod=$ENV{'EFIESTMOD'};


unless(defined $blasthits){
  $blasthits=50000;  
}

#$queue.=" -l nodes=compute-4-0";

unless(defined $file or defined $ipro or defined $pfam or defined $taxid){
  die "You must spedify the -fasta, -ipro, -taxid, or -pfam variables\n";
}
if(defined $file and (defined $ipro or defined $pfam)){
  die "You cannot specify both the -fasta and -ipro or -pfam variable\n";
}
unless(defined $np){
  die "You must spedify the -np variable\n";
}
unless(defined $queue){
  #die "You must spedify the -queue variable\n";
  print "-queue not specified, using default\n";
  $queue="default";
}
unless(defined $memqueue){
  print "-memqueue not specifiied, using blacklight\n";
  $memqueue="blacklight";
}

unless(defined $tmpdir){
  die "You must spedify the -tmp variable\n";
}
unless(defined $evalue){
  #die "You must spedify the -evalue variable\n";
  print "-evalue not specified, using default of 5\n";
  $evalue="1e-5";
}else{
  if( $evalue =~ /^\d+$/ ) { 
    $evalue="1e-$evalue";
  }
}
unless(defined $flat or defined $pfam or defined $ipro or defined $taxid){
  die "You must spedify the -flat variable if submitting a fasta file\n";
}
unless(defined $pfam){
  $pfam=0;
}
unless(defined $ipro){
  $ipro=0;
}

unless(defined $taxid){
  $taxid=0;
}

unless(defined $gene3d){
  $gene3d=0;
}

unless(defined $ssf){
  $ssf=0;
}

unless(defined $maxlen){
  $maxlen=0;
}
unless(defined $minlen){
  $minlen=0;
}
unless(defined $incfrac){
  print "-incfrac not specified, using default of 0.99\n";
  $incfrac=0.99;
}

unless(defined $maxsequence){
  $maxsequence=0;
}

#create tmp directories
mkdir $tmpdir;

#sequence length filter (optional)

if(defined $hilen or defined $lowlen){
  print "defined\n";
  system("$toolpath/bandpass.pl -in $file -out ".$ENV{PWD}."/$tmpdir/bandpassfiltered.fasta -hi $hilen -low $lowlen");
  $file=$ENV{PWD}."/$tmpdir/bandpassfiltered.fasta";
}

print "$file\n";
if($pfam or $ipro){
  #create fasta and struct.out files
  open(QSUB,">$tmpdir/initial_import.sh") or die "could not create blast submission script $tmpdir/createdb.sh\n";
  print QSUB "#!/bin/bash\n";
  print QSUB "#PBS -j oe\n";
  print QSUB "#PBS -S /bin/bash\n";
  print QSUB "#PBS -q $queue\n";
  print QSUB "#PBS -l nodes=1:ppn=1\n";
  print QSUB "module load $efiestmod\n";
#  print QSUB "module load blast\n";
  print QSUB "cd $ENV{PWD}/$tmpdir\n";
  print QSUB "which perl\n";
  #print QSUB "$toolpath/initial_import.py -u $dbusername -p $dbpassword -d $dbusername -f $file -t ".$ENV{PWD}."/$tmpdir -a $flat -e $expression\n";
  print QSUB "$toolpath/sqlite-getsequence.pl -ipro $ipro -pfam $pfam -ssf $ssf -gene3d $gene3d -out ".$ENV{PWD}."/$tmpdir/sequences.fa -maxsequence $maxsequence -access ".$ENV{PWD}."/$tmpdir/accession.txt\n";
  print QSUB "$toolpath/getannotations.pl -out ".$ENV{PWD}."/$tmpdir/struct.out -fasta ".$ENV{PWD}."/$tmpdir/sequences.fa\n";

  close QSUB;

  $importjob=`qsub $ENV{PWD}/$tmpdir/initial_import.sh`;
  print "import job is:\n $importjob";
  @importjobline=split /\./, $importjob;

}elsif($taxid){
    #create fasta and struct.out files
  open(QSUB,">$tmpdir/initial_import.sh") or die "could not create blast submission script $tmpdir/createdb.sh\n";
  print QSUB "#!/bin/bash\n";
  print QSUB "#PBS -j oe\n";
  print QSUB "#PBS -S /bin/bash\n";
  print QSUB "#PBS -q $queue\n";
  print QSUB "#PBS -l nodes=1:ppn=1\n";
  print QSUB "module load $efiestmod\n";
  print QSUB "cd $ENV{PWD}/$tmpdir\n";
  #print QSUB "$toolpath/initial_import.py -u $dbusername -p $dbpassword -d $dbusername -f $file -t ".$ENV{PWD}."/$tmpdir -a $flat -e $expression\n";
  print QSUB "getseqtaxid.pl -fasta sequences.fa -struct struct.out -taxid $taxid\n";

  close QSUB;

  $importjob=`qsub $ENV{PWD}/$tmpdir/initial_import.sh`;
  print "import job is:\n $importjob";
  @importjobline=split /\./, $importjob;
}else{
  #import sequences then other information from uniprot
  open(QSUB,">$tmpdir/initial_import.sh") or die "could not create blast submission script $tmpdir/createdb.sh\n";
  print QSUB "#!/bin/bash\n";
  print QSUB "#PBS -j oe\n";
  print QSUB "#PBS -S /bin/bash\n";
  print QSUB "#PBS -q $queue\n";
  print QSUB "#PBS -l nodes=1:ppn=1\n";
  print QSUB "module load $efiestmod\n";
  #print QSUB "module load blast\n";
  print QSUB "cd $ENV{PWD}/$tmpdir\n";
  #print QSUB "$toolpath/initial_import.py -u $dbusername -p $dbpassword -d $dbusername -f $file -t ".$ENV{PWD}."/$tmpdir -a $flat -e $expression\n";
  print QSUB "$toolpath/simplifyfasta.pl -fasta $file -out ".$ENV{PWD}."/$tmpdir/sequences.fa\n";
  print QSUB "$toolpath/getannotations-old.pl -masterstruct $toolpath/data_files/master.struct -struct ".$ENV{PWD}."/$tmpdir/struct.out -fasta ".$ENV{PWD}."/$tmpdir/sequences.fa\n";

  close QSUB;

  $importjob=`qsub $ENV{PWD}/$tmpdir/initial_import.sh`;
  print "import job is:\n $importjob";
  @importjobline=split /\./, $importjob;
}


#qsub script to create fracfiles

open(QSUB,">$tmpdir/fracfile.sh") or die "could not create blast submission script $tmpdir/fracfile.sh\n";
print QSUB "#!/bin/bash\n";
print QSUB "#PBS -j oe\n";
print QSUB "#PBS -S /bin/bash\n";
print QSUB "#PBS -q $queue\n";
print QSUB "#PBS -l nodes=1:ppn=1\n";
print QSUB "#PBS -W depend=afterok:@importjobline[0]\n"; 
print QSUB "$toolpath/fracsequence.pl -np $np -tmp ".$ENV{PWD}."/$tmpdir\n";
close QSUB;

$fracfilejob=`qsub $tmpdir/fracfile.sh`;
print "fracfile job is:\n $fracfilejob";
@fracfilejobline=split /\./, $fracfilejob;


#open(QSUB,">$tmpdir/annotations.sh") or die "could not create blast submission script $tmpdir/annotations.sh\n";
#print QSUB "#!/bin/bash\n";
#print QSUB "#PBS -j oe\n";
#print QSUB "#PBS -S /bin/bash\n";
#print QSUB "#PBS -q $queue\n";
#print QSUB "#PBS -l nodes=1:ppn=1\n";
#print QSUB "#PBS -l mem=20gb\n";
#print QSUB "#PBS -W depend=afterok:@importjobline[0]\n"; 
#print QSUB "module load perl\n";
#print QSUB "$toolpath/getannotations.pl -fasta $ENV{PWD}/$tmpdir/sequences.fa -dat $flat -uniprotgi $toolpath/idmapping/gionly.dat -uniprotref $toolpath/idmapping/RefSeqonly.dat -struct $ENV{PWD}/$tmpdir/struct.out";
#close QSUB;

#$annojob=`qsub $tmpdir/annotations.sh`;
#print "Annotation job is:\n $annojob";

#make the blast database and put it into the temp directory
open(QSUB,">$tmpdir/createdb.sh") or die "could not create blast submission script $tmpdir/createdb.sh\n";
print QSUB "#!/bin/bash\n";
print QSUB "#PBS -j oe\n";
print QSUB "#PBS -S /bin/bash\n";
print QSUB "#PBS -q $queue\n";
print QSUB "#PBS -l nodes=1:ppn=1\n";
print QSUB "#PBS -W depend=afterok:@fracfilejobline[0]\n";
#print QSUB "module load blast+\n";
print QSUB "module load $efiestmod\n";
print QSUB "cd $ENV{PWD}/$tmpdir\n";
#print QSUB "makeblastdb -in sequences.fa -out database";
print QSUB "formatdb -i sequences.fa -n database\n";
close QSUB;

$createdbjob=`qsub $tmpdir/createdb.sh`;
print "createdb job is:\n $createdbjob";
@createdbjobline=split /\./, $createdbjob;

#generate qsub scripts
#one for every fracfile-* script created above

#for(my $i=1; $i<=$np; $i++){
  open(QSUB,">$tmpdir/blast-qsub.sh") or die "could not create blast submission script $tmpdir/blast-qsub-$i.sh\n";
  print QSUB "#!/bin/bash\n";
  print QSUB "#PBS -t 1-$np\n";
  print QSUB "#PBS -j oe\n";
  print QSUB "#PBS -S /bin/bash\n";
  print QSUB "#PBS -q $queue\n";
  print QSUB "#PBS -l nodes=1:ppn=1\n";
  print QSUB "#PBS -W depend=afterok:@createdbjobline[0]\n";
  print QSUB "export BLASTDB=$ENV{PWD}/$tmpdir\n";
  #print QSUB "module load blast+\n";
  #print QSUB "blastp -query  $ENV{PWD}/$tmpdir/fracfile-\${PBS_ARRAYID}.fa  -num_threads 2 -db database -gapopen 11 -gapextend 1 -comp_based_stats 2 -use_sw_tback -outfmt \"6 qseqid sseqid bitscore evalue qlen slen length qstart qend sstart send pident nident\" -num_descriptions 5000 -num_alignments 5000 -out $ENV{PWD}/$tmpdir/blastout-\${PBS_ARRAYID}.fa.tab -evalue $evalue\n";
  print QSUB "module load $efiestmod\n";
  print QSUB "blastall -p blastp -i $ENV{PWD}/$tmpdir/fracfile-\${PBS_ARRAYID}.fa -d $ENV{PWD}/$tmpdir/database -m 8 -e $evalue -b $blasthits -o $ENV{PWD}/$tmpdir/blastout-\${PBS_ARRAYID}.fa.tab\n";
  close QSUB;
#}

$blastjob=`qsub $tmpdir/blast-qsub.sh`;
print "blast job is:\n $blastjob";
@blastjobline=split /\./, $blastjob;

#submit qsub scripts

open(QSUB,">$tmpdir/catjob.sh") or die "could not create blast submission script $tmpdir/catjob.sh\n";
print QSUB "#!/bin/bash\n";
print QSUB "#PBS -j oe\n";
print QSUB "#PBS -S /bin/bash\n";
print QSUB "#PBS -q $queue\n";
print QSUB "#PBS -l nodes=1:ppn=1\n";
print QSUB "#PBS -W depend=afterokarray:@blastjobline[0]\n"; 
print QSUB "cat $ENV{PWD}/$tmpdir/blastout-*.tab |grep -v '#' >$ENV{PWD}/$tmpdir/blastfinal.tab";
close QSUB;

#submit the cat script, job dependences should keep it from running till all blasts are done

$catjob=`qsub $tmpdir/catjob.sh`;
print "Cat job is:\n $catjob";

#create submit script for filtering out duplicates and likewise compares

@catjobline=split /\./, $catjob;

open(QSUB,">$tmpdir/filterjob.sh") or die "could not create blast submission script $tmpdir/filterjob.sh\n";
print QSUB "#!/bin/bash\n";
print QSUB "#PBS -j oe\n";
print QSUB "#PBS -S /bin/bash\n";
print QSUB "#PBS -q $memqueue\n";
print QSUB "#PBS -l nodes=1:ppn=1\n";
print QSUB "#PBS -W depend=afterok:@catjobline[0]\n"; 
print QSUB "$toolpath/step_2.2-filterblast.pl $ENV{PWD}/$tmpdir/blastfinal.tab $ENV{PWD}/$tmpdir/sequences.fa > $ENV{PWD}/$tmpdir/1.out";
close QSUB;

#submit the filter script, job dependences should keep it from running till all blast out files are combined

$filterjob=`qsub $tmpdir/filterjob.sh`;
print "Filter job is:\n $filterjob";

@filterjobline=split /\./, $filterjob;

#submit the quartiles scripts, should not run until filterjob is finished
#nothing else depends on this scipt

open(QSUB,">$tmpdir/quartalign.sh") or die "could not create blast submission script $tmpdir/quartalign.sh\n";
print QSUB "#!/bin/bash\n";
print QSUB "#PBS -j oe\n";
print QSUB "#PBS -S /bin/bash\n";
print QSUB "#PBS -q $memqueue\n";
print QSUB "#PBS -l nodes=1:ppn=1\n";
print QSUB "#PBS -W depend=afterok:@filterjobline[0]\n"; 
print QSUB "module load $efiestmod\n";
print QSUB "$toolpath/quart-align.pl -blastout $ENV{PWD}/$tmpdir/1.out -align $ENV{PWD}/$tmpdir/alignment_length.png\n";
close QSUB;

$quartalignjob=`qsub $tmpdir/quartalign.sh`;
print "Quartile Align job is:\n $quartalignjob";

open(QSUB,">$tmpdir/quartpid.sh") or die "could not create blast submission script $tmpdir/quartpid.sh\n";
print QSUB "#!/bin/bash\n";
print QSUB "#PBS -j oe\n";
print QSUB "#PBS -S /bin/bash\n";
print QSUB "#PBS -q $memqueue\n";
print QSUB "#PBS -l nodes=1:ppn=1\n";
print QSUB "#PBS -W depend=afterok:@filterjobline[0]\n"; 
print QSUB "#PBS -m e\n";
print QSUB "module load $efiestmod\n";
print QSUB "$toolpath/quart-perid.pl -blastout $ENV{PWD}/$tmpdir/1.out -pid $ENV{PWD}/$tmpdir/percent_identity.png\n";
close QSUB;

$quartpidjob=`qsub $tmpdir/quartpid.sh`;
print "Quartiles Percent Identity job is:\n $quartpidjob";

open(QSUB,">$tmpdir/simplegraphs.sh") or die "could not create blast submission script $tmpdir/simplegraphs.sh\n";
print QSUB "#!/bin/bash\n";
print QSUB "#PBS -j oe\n";
print QSUB "#PBS -S /bin/bash\n";
print QSUB "#PBS -q $memqueue\n";
print QSUB "#PBS -l nodes=1:ppn=1\n";
print QSUB "#PBS -W depend=afterok:@filterjobline[0]\n"; 
print QSUB "module load $efiestmod\n";
print QSUB "$toolpath/simplegraphs.pl -blastout $ENV{PWD}/$tmpdir/1.out -edges $ENV{PWD}/$tmpdir/number_of_edges.png -fasta $ENV{PWD}/$tmpdir/sequences.fa -lengths $ENV{PWD}/$tmpdir/length_histogram.png -incfrac $incfrac\n";
close QSUB;

$simplegraphjob=`qsub $tmpdir/simplegraphs.sh`;
print "Simplegraphs job is:\n $simplegraphjob";



