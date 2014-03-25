#!/usr/bin/env perl
use strict;
my $fp = shift @ARGV;

if(not $fp){
	die "Need fp to format\n";

}

print "About to format db $fp\n";



my $call = "formatdb -i $fp.fa.renamed -p T";
print $call,"\n";
system($call);
