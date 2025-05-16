### Shared Variant Analyzer

This is a Perl script used to identify genetic variants consistently present across multiple samples in cohort studies or population-level analyses. It processes Variant Call Format (VCF) files to detect **single-nucleotide variants (SNVs)** & **indels** shared at defined frequency thresholds **(10% to 100% in 10% increments)**. Unlike simple presence/absence tools, it performs genotype-aware parsing that accurately accounts for heterozygous calls (e.g., **"0/1"** genotypes) and filters out missing data ("./." entries). The tool generates comprehensive reports detailing variant positions (chromosome, coordinate), reference/alternate alleles, and both absolute counts and percentages of samples containing each variant. Its threshold-based approach helps researchers identify core genomic elements in pathogen populations, conserved mutations in cancer cohorts, or transmission clusters in outbreak investigations. The script features robust input validation, automatically verifying file paths and VCF integrity before analysis. Outputs are sorted by genomic position and prevalence frequency, facilitating downstream interpretation in tools like Excel or R. Designed for efficiency, it handles large variant sets through optimized hashing algorithms while maintaining low memory footprint. Applications range from identifying vaccine targets in viral quasispecies to detecting founder mutations in genetic epidemiology studies. The command-line interface supports integration into automated pipelines, and its tab-separated output format enables seamless incorporation into genomic databases or visualization platforms. Particularly valuable for studies requiring variant prioritization based on ubiquity, this tool bridges the gap between raw variant calling and population-level biological interpretation.

## 1. Features

**Multiple VCF file analysis**

1. Genotype-aware variant counting

2. Threshold reporting (10-100% sample sharing)

3. Comprehensive output with percentages

4. Input validation and error checking

## 2. Requirements

1. Perl 5.20+

2. Perl modules: Getopt::Long, List::Util


## 3. Usage

```bash


perl shared_variant_analyzer.pl -i vcf_list.txt > variant_report.tsv


```

## 4. Input Format

**vcf_list.txt**:

```bash


/path/to/sample1.vcf
/path/to/sample2.vcf
/path/to/sample3.vcf


```

## 5. Output Columns

**Chrom	Position	Ref	Alt	SampleCount	Percentage**


## License <a name="license"></a>
MIT License.
