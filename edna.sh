#!/bin/bash

# ==============================================================================
# QIIME 2 eDNA ANALYSIS PIPELINE FOR TARA PACIFIC SAMPLE (18S)
# ==============================================================================
# This script automates the entire workflow, from data download to analysis.
# To run: save as run_pipeline.sh and execute with -> bash run_pipeline.sh
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- 1. ENVIRONMENT SETUP & DATA DOWNLOAD ---
echo "STEP 1: Downloading raw sequence data..."

# Download paired-end reads for TARA Pacific run ERR3444605
wget -O ERR3444605_1.fastq.gz ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR344/005/ERR3444605/ERR3444605_1.fastq.gz
wget -O ERR3444605_2.fastq.gz ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR344/005/ERR3444605/ERR3444605_2.fastq.gz

# Unzip the files
gunzip -f *.fastq.gz

echo "Data download complete."
echo "-------------------------"


# --- 2. QIIME 2 DATA IMPORT ---
echo "STEP 2: Importing data into QIIME 2..."

# Activate your QIIME 2 conda environment (replace with your specific environment name)
# NOTE: You must run this script from a terminal where conda is initialized.
# The script will try to activate it, but it's best to be in the environment already.
source $(conda info --base)/etc/profile.d/conda.sh
conda activate qiime2-amplicon-2025.7 #<-- IMPORTANT: CHANGE THIS TO YOUR ENV NAME

# Create the manifest file using printf to ensure correct formatting
printf "sample-id\tforward-absolute-filepath\treverse-absolute-filepath\n" > manifest.tsv
printf "tara-pacific-sample\t\$PWD/ERR3444605_1.fastq\t\$PWD/ERR3444605_2.fastq\n" >> manifest.tsv

# Import the data into a QIIME 2 artifact
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.tsv \
  --output-path demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

echo "QIIME 2 import complete. Artifact: demux.qza"
echo "-------------------------"


# --- 3. QUALITY CONTROL & ASV GENERATION (DADA2) ---
echo "STEP 3: Running DADA2 for QC and ASV generation..."

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux.qza \
  --p-trunc-len-f 240 \
  --p-trunc-len-r 240 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza

echo "DADA2 complete. Outputs: table.qza, rep-seqs.qza"
echo "-------------------------"


# --- 4. TAXONOMIC CLASSIFICATION ---
echo "STEP 4: Assigning taxonomy..."

# Download the pre-trained SILVA classifier if it doesn't exist
CLASSIFIER_FILE="silva-138-99-515-806-nb-classifier.qza"
if [ ! -f "$CLASSIFIER_FILE" ]; then
    echo "Downloading pre-trained SILVA classifier..."
    wget -O "$CLASSIFIER_FILE" "https://raw.githubusercontent.com/tripitakit/qiime2classifiers/master/silva-138.2-ssu-nr99-341f-806r-classifier.qza"
fi

# Run the classifier
qiime feature-classifier classify-sklearn \
  --i-classifier "$CLASSIFIER_FILE" \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

echo "Taxonomy assignment complete. Output: taxonomy.qza"
echo "-------------------------"


# --- 5. EXPORT DATA FOR VISUALIZATION ---
echo "STEP 5: Exporting data for custom plotting..."

# Create a directory for the exported files
mkdir -p exported-data

# Export feature table and convert to TSV
qiime tools export \
  --input-path table.qza \
  --output-path exported-data

biom convert \
  -i exported-data/feature-table.biom \
  -o exported-data/feature-table.tsv \
  --to-tsv

# Export taxonomy file
qiime tools export \
  --input-path taxonomy.qza \
  --output-path exported-data

echo "Data export complete."
echo "-------------------------"


# --- 6. CREATE ADVANCED VISUALIZATIONS ---
echo "STEP 6: Creating advanced visualizations with Python script..."

# Check if the visualization script exists, if not, create it.
PLOT_SCRIPT="create_plots.py"
if [ ! -f "$PLOT_SCRIPT" ]; then
    echo "Creating Python plot script: $PLOT_SCRIPT"
    # Use a "here document" to write the Python script to a file
    cat << 'EOF' > $PLOT_SCRIPT
import pandas as pd
import plotly.express as px

# --- Load and Merge Data ---
print("Loading exported data...")
abundances = pd.read_csv('exported-data/feature-table.tsv', sep='\t', skiprows=1)
abundances.rename(columns={'#OTU ID': 'ASV_ID', 'tara-pacific-sample': 'Abundance'}, inplace=True)
taxonomy = pd.read_csv('exported-data/taxonomy.tsv', sep='\t')
taxonomy.rename(columns={'Feature ID': 'ASV_ID', 'Taxon': 'Taxonomy'}, inplace=True)
df = pd.merge(abundances, taxonomy, on='ASV_ID')

# --- Clean and Prepare Taxonomic Data ---
print("Preparing taxonomic data for plotting...")
tax_levels = ['Domain', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species']
tax_split = df['Taxonomy'].str.split(';', expand=True)
for i, level in enumerate(tax_levels):
    if i < tax_split.shape[1]:
        df[level] = tax_split[i].str.replace(r'^[dpcofgs]__', '', regex=True)
    else:
        df[level] = 'Unassigned'
df.replace('', pd.NA, inplace=True)
for level in tax_levels:
    df[level].fillna('Unassigned', inplace=True)

# --- Generate Visualizations ---
print("Generating interactive sunburst chart...")
sunburst_fig = px.sunburst(df, path=['Domain', 'Phylum', 'Class'], values='Abundance', title='Hierarchical Taxonomic Composition', color='Phylum')
sunburst_fig.write_html("taxonomic_sunburst.html")

print("Generating interactive treemap...")
treemap_fig = px.treemap(df, path=['Domain', 'Phylum', 'Class'], values='Abundance', title='Hierarchical Taxonomic Composition (Treemap View)', color='Phylum')
treemap_fig.write_html("taxonomic_treemap.html")

print("Generating pie chart...")
phylum_df = df[df['Phylum'] != 'Unassigned']
pie_fig = px.pie(phylum_df.groupby('Phylum')['Abundance'].sum().reset_index(), names='Phylum', values='Abundance', title='Taxonomic Composition at Phylum Level')
pie_fig.write_html("taxonomic_pie_chart.html")

print("\nAll visualizations created successfully!")
EOF
fi

# Run the Python script
python $PLOT_SCRIPT

echo "========================================="
echo "          PIPELINE COMPLETE!             "
echo "========================================="
echo "Check the directory for your final interactive plots (e.g., taxonomic_sunburst.html)"