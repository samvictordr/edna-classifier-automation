# Environmental DNA Metabarcoding Pipeline for Eukaryotic Biodiversity Assessment

An automated metabarcoding workflow for processing paired-end 18S rRNA V4 amplicon sequences from environmental DNA samples. This pipeline implements standardized protocols for taxonomic profiling of eukaryotic microorganisms, utilizing QIIME 2 for sequence processing, DADA2 for amplicon sequence variant (ASV) inference, and SILVA reference database for taxonomic assignment.

## Scientific Background

Environmental DNA (eDNA) metabarcoding has revolutionized biodiversity assessment by enabling the detection and quantification of eukaryotic microorganisms directly from environmental samples without requiring specimen isolation or morphological identification. The 18S rRNA V4 hypervariable region serves as an excellent phylogenetic marker for eukaryotic diversity studies due to its taxonomic resolution and comprehensive reference database coverage.

This pipeline processes eDNA sequence data from the TARA Oceans expedition, specifically sample ERR3444605, implementing established protocols for:

* **Quality-aware ASV inference** using DADA2 error modeling to distinguish genuine biological variants from sequencing artifacts
* **Phylogenetically-informed taxonomic assignment** against the SILVA 138 SSU reference database using Naive Bayes classification
* **Ecological data visualization** for biodiversity pattern exploration and community structure analysis

## Methodological Workflow

The pipeline implements a standardized metabarcoding analysis protocol consisting of six sequential steps:

1. **Raw Data Acquisition**: Downloads paired-end Illumina MiSeq reads (ERR3444605) from the TARA Pacific expedition via EBI's European Nucleotide Archive
2. **Sequence Import and Formatting**: Converts raw FASTQ files into QIIME 2 artifact format with appropriate metadata structure for paired-end analysis
3. **Quality Filtering and ASV Inference**: Applies DADA2 algorithm for quality score-based read filtering, error rate learning, sequence denoising, paired-end merging, and chimera removal to generate amplicon sequence variants
4. **Taxonomic Profiling**: Assigns taxonomic lineages to ASVs using a pre-trained Naive Bayes classifier based on SILVA 138 SSU reference sequences (515F-806R primer region)
5. **Data Export**: Converts QIIME 2 artifacts to standard formats (BIOM, TSV) for downstream ecological analysis and integration with external tools
6. **Biodiversity Visualization**: Generates interactive taxonomic composition plots (sunburst diagrams, treemaps, pie charts) for exploratory data analysis and presentation

## Implementation Requirements

### Prerequisites

* Unix-based operating system (Linux, macOS, or Windows Subsystem for Linux)
* [QIIME 2](https://qiime2.org/) amplicon distribution (version 2025.7 or compatible) installed via conda
* Active internet connection for data retrieval and classifier download
* Minimum 8GB RAM and 10GB free disk space for processing

### Execution Protocol

1. **Repository Setup:**
   ```bash
   git clone https://github.com/samvictordr/edna-classifier-automation.git
   cd edna-classifier-automation
   ```

2. **Environment Activation:** Ensure QIIME 2 conda environment is activated before execution:
   ```bash
   conda activate qiime2-amplicon-2025.7  # Adjust environment name as needed
   ```

3. **Pipeline Execution:** Run the complete analysis workflow:
   ```bash
   chmod +x edna.sh
   ./edna.sh
   ```

**Note:** The script is pre-configured for TARA Pacific sample ERR3444605. Modify data acquisition section (lines 17-18) to process alternative datasets.

## Analysis Outputs

Upon successful completion, the pipeline generates the following files for ecological analysis:

### Primary Data Products
* **`table.qza`**: QIIME 2 artifact containing the ASV abundance matrix (feature table)
* **`rep-seqs.qza`**: Representative sequences for each ASV in QIIME 2 format
* **`taxonomy.qza`**: Taxonomic assignments with confidence scores for all ASVs
* **`denoising-stats.qza`**: DADA2 quality control metrics and filtering statistics

### Exported Data Files
* **`exported-data/feature-table.tsv`**: ASV abundance table in tab-separated format for external analysis
* **`exported-data/taxonomy.tsv`**: Taxonomic assignments in plain text format

### Interactive Visualizations
* **`taxonomic_sunburst.html`**: Hierarchical taxonomic composition as nested circular plot
* **`taxonomic_treemap.html`**: Proportional taxonomic representation using rectangular areas
* **`taxonomic_pie_chart.html`**: Phylum-level taxonomic distribution summary

## Analytical Framework

### Core Bioinformatics Tools
* **[QIIME 2](https://qiime2.org/)**: Integrated microbiome analysis platform providing reproducible, extensible, and decentralized analysis workflows
* **[DADA2](https://benjjneb.github.io/dada2/)**: Sample inference algorithm for amplicon data that resolves ASVs at single-nucleotide resolution through error modeling
* **[SILVA](https://www.arb-silva.de/)**: Comprehensive ribosomal RNA reference database (version 138) providing taxonomic framework for SSU sequence classification

### Reference Database
* **SILVA 138 SSU NR99**: Non-redundant small subunit rRNA sequences clustered at 99% identity, trained for 515F-806R primer region classification

### Data Processing Libraries  
* **BIOM**: Biological Observation Matrix format for ecological data interchange
* **Plotly**: Interactive visualization library for exploratory data analysis and scientific presentation
