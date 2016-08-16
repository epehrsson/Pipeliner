#!/usr/bin/perl -w
use strict;
use List::Util 'shuffle';

#INPUT

my $outfile = 'mutect_variants_alview.input'; #to fix...
open C, ">$outfile";
#print C "Chromosome\tRead_1_Start\tRead_2_Start\tHighCounts\tLowCounts\tHomozygous_informative\tHeterozygous_informative\tComps\tHighProp\tLowProp\tWinner\n";

my $maffile = $ARGV[0]; #to fix...
my @line = ();
my $sample = 'null';
my $muts=0;
my $name = 'null';
my $gene = 'null';
my @type = ();
my @full = ();
my $a = 0;
my @chrom=();
my @position=();
my @tumorsample=();
my @germsample=();

my $cmd = '';
$cmd = 'sort -k1,1 -k16,16 mutect_variants.maf | awk \'BEGIN { FS = OFS = "\t" } { for(i=1; i<=NF; i++) if($i ~ /^ *$/) $i ="-" }; 1\' > mutect_variants_sorted.maf';
system($cmd);

open G, "<$maffile";
while (<G>){
	chomp;
  	last if m/^$/;
  	@line = split;
  	next if (($line[0] =~ m'#') || ($line[0] =~ m"Hugo_Symbol") || ($line[8] =~ m"Silent") || ($line[8] =~ m"IGR") || ($line[8] =~ m"Intron"));
	if ($line[0] !~ m'#') {
		if (($line[0] eq $gene) || ($gene eq 'null')) {
			if (($line[16] ne $sample) || ($sample eq 'null')) {
				$gene = $line[0];
				$sample = $line[16];
				push @chrom, $line[4];
				push @position, $line[5];
				push @tumorsample, $line[15];
				push @germsample, $line[16];
				push @type, $line[8];
				push @full, $_;
				$muts++;
			}
			else {
				push @chrom, $line[4];
				push @position, $line[5];
				push @tumorsample, $line[15];
				push @germsample, $line[16];
				push @type, $line[8];
				push @full, $_;
			}
		}
		else {
			if ($muts > 1) {
				$a = 0;
				for ($a = 0; $a < @type; $a++) {
					print C "$chrom[$a]\t$position[$a]\t$tumorsample[$a]\t$gene\t$muts\t$type[$a]\n";
					print C "$chrom[$a]\t$position[$a]\t$germsample[$a]\t$gene\t$muts\t$type[$a]\n";
				}
			}
			@type = ();
			@full = ();
			@chrom = ();
			@position=();
			@tumorsample=();
			@germsample=();
			$gene = $line[0];
			$sample = $line[16];
			push @chrom, $line[4];
			push @position, $line[5];
			push @tumorsample, $line[15];
			push @germsample, $line[16];				
			push @type, $line[8];
			push @full, $_;
			$muts=1;
		}
	}
}
$a = 0;
for ($a = 0; $a < @type; $a++) {
	print C "$chrom[$a]\t$position[$a]\t$tumorsample[$a]\t$gene\t$muts\t$type[$a]\n";
	print C "$chrom[$a]\t$position[$a]\t$germsample[$a]\t$gene\t$muts\t$type[$a]\n";
}
close C;
close G;

$cmd = './data/CCBR/apps/ALVIEW/alvgenslideshow mutect_variants_images mutect_variants_alview.input ' . $ARGV[1];
system($cmd);