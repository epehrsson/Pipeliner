#!/usr/bin/perl -w
use strict;
use List::Util 'shuffle';

#INPUT

my $finalmaf = $ARGV[1] . '_out/oncotator_out/' . $ARGV[1] . '_merged.maf'; #to fix...
open C, ">$finalmaf";

my $maffile = $ARGV[0]; #to fix...
my $fixedmaf = $ARGV[1] . '_out/oncotator_out/' . $ARGV[1] . '_variants_fixed.maf';
my @line = ();
my $header='null';
my @variants=();
my @freq='';
my $calc='';
my $gene='null';
my $muts=0;
my @hugoid=();
my @count=();
my $sample='null';

my $cmd = '';
$cmd = 'awk \'BEGIN { FS = OFS = "\t" } { for(i=1; i<=NF; i++) if($i ~ /^ *$/) $i ="-" }; 1\' ' . $maffile . ' > ' . $fixedmaf;
system($cmd);

open G, "<$fixedmaf";
while (<G>){
	chomp;
  	last if m/^$/;
  	@line = split "\t", $_;
	if ($line[0] =~ m'Hugo') {
		if ($header eq 'null') {
			$header=$_;
			print C "$header\ttumor_freq\n";
		}
	}
	elsif ($line[0] !~ m'#') {
		print C "$_\t";
		if ($line[39] != 0){
		$calc=($line[41]/$line[39]);
		print C "$calc\n";
		}
		else {
		print "0\n";		
	}
	}
}

close C;