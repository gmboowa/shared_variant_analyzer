#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(max);
use Getopt::Long;

# Configure command-line options
my ($input_file, $help);
GetOptions(
    'i|input=s' => \$input_file,
    'h|help'    => \$help
) or die "Invalid options! Try -h for help.\n";

# Show help if requested
if ($help) {
    print <<"HELP";
Usage: $0 -i <sample-list.txt>
    
Analyzes variant sharing between samples from VCF files
    
Options:
    -i, --input   File containing list of VCF paths (one per line)
    -h, --help    Show this help message

HELP
    exit;
}

# Validate input
die "Must specify input file with -i!\n" unless $input_file;
die "Input file $input_file not found!\n" unless -e $input_file;

# Read sample list
my @vcf_files;
open my $list_fh, '<', $input_file or die "Cannot open $input_file: $!";
while (<$list_fh>) {
    chomp;
    next if /^\s*$/;  # Skip empty lines
    die "VCF file $_ does not exist!\n" unless -e $_;
    push @vcf_files, $_;
}
close $list_fh;

my %variant_counts;
my $total_samples = scalar @vcf_files;

# Process each VCF file
foreach my $vcf_file (@vcf_files) {
    open my $vcf_fh, '<', $vcf_file or die "Cannot open $vcf_file: $!";
    my %sample_variants;
    
    while (<$vcf_fh>) {
        next if /^#/;  # Skip header lines
        
        my @fields = split /\t/;
        next unless @fields >= 10;  # Skip incomplete lines
        
        my ($chrom, $pos, $id, $ref, $alt, $format) = @fields[0..4,8];
        my @alts = split /,/, $alt;
        my $sample_data = $fields[9];
        
        # Extract genotype information
        my @format_fields = split /:/, $format;
        my $gt_index = -1;
        for my $i (0..$#format_fields) {
            if ($format_fields[$i] eq 'GT') {
                $gt_index = $i;
                last;
            }
        }
        next if $gt_index == -1;  # Skip if no GT field
        
        my $gt = (split /:/, $sample_data)[$gt_index];
        next if $gt =~ /^\./;  # Skip missing genotypes
        
        # Process alleles
        my @alleles = split /[\/|]/, $gt;
        foreach my $allele (@alleles) {
            next if $allele eq '.' || $allele == 0;  # Skip reference alleles
            
            my $alt_idx = $allele - 1;
            next if $alt_idx >= @alts;  # Skip invalid indices
            
            my $alt_allele = $alts[$alt_idx];
            my $variant_key = join(":", $chrom, $pos, $ref, $alt_allele);
            $sample_variants{$variant_key} = 1;
        }
    }
    
    close $vcf_fh;
    
    # Update global counts
    $variant_counts{$_}++ for keys %sample_variants;
}

# Calculate thresholds and prepare report
my %threshold_variants;
foreach my $threshold (10, 20, 30, 40, 50, 60, 70, 80, 90, 100) {
    my $required = ceil($total_samples * $threshold / 100);
    $threshold_variants{$threshold} = [
        grep { $variant_counts{$_} >= $required } keys %variant_counts
    ];
}

# Generate output report
print "Variant Sharing Analysis Report\n";
print "Total Samples: $total_samples\n";
print "=" x 50 . "\n";

foreach my $threshold (sort {$b <=> $a} keys %threshold_variants) {
    my @variants = @{$threshold_variants{$threshold}};
    my $count = scalar @variants;
    
    print "\nVariants shared by ≥$threshold% samples ($count variants):\n";
    print "Chrom\tPosition\tRef\tAlt\tSampleCount\tPercentage\n";
    
    foreach my $var (sort {
        $variant_counts{$b} <=> $variant_counts{$a} || $a cmp $b
    } @variants) {
        my ($c, $p, $r, $a) = split /:/, $var;
        my $cnt = $variant_counts{$var};
        my $perc = sprintf("%.1f%%", ($cnt/$total_samples)*100);
        print join("\t", $c, $p, $r, $a, $cnt, $perc) . "\n";
    }
}

sub ceil {
    my $num = shift;
    return int($num) + ($num > int($num) ? 1 : 0);
}
