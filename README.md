# eDNA Biodiversity Analsys pipeline (paired-end 18S V4 data)
An automated, end-to-end bioinformatics pipeline for processing raw environmental DNA (eDNA) reads to identify eukaryotic taxa and assess biodiversity. This project uses a QIIME 2-based workflow for high-resolution ASV generation and a Python script with Plotly for advanced, interactive visualizations.

## Project Overview

The analysis of environmental DNA (eDNA) presents a significant computational challenge, requiring the processing of millions of noisy, short-read sequences to extract a meaningful biological signal. This pipeline provides a robust solution, transforming raw paired-end FASTQ files into a clean, classified, and visualized taxonomic profile.

The workflow uses modern bioinformatics best practices, including:
* **High-resolution feature generation** with DADA2 to create Amplicon Sequence Variants (ASVs).
* **Supervised machine learning** for taxonomic classification using a pre-trained Naive Bayes classifier.
* **Automated data processing** and visualization generation through a portable shell script.

## Workflow

The pipeline follows a series of automated steps to process the raw data:

1.  **Data Import**: Raw paired-end FASTQ files are imported into the QIIME 2 environment.
2.  **Quality Control & Denoising**: The DADA2 plugin filters low-quality reads, corrects sequencing errors, merges read pairs, and generates a high-fidelity ASV abundance table.
3.  **Taxonomic Classification**: ASVs are classified using a pre-trained Naive Bayes classifier against the SILVA reference database.
4.  **Data Export**: The final ASV table and taxonomy are exported to plain-text formats for custom analysis.
5.  **Interactive Visualization**: A Python script reads the exported data and generates interactive sunburst charts, treemaps, and pie charts using Plotly.

## Getting Started

### Prerequisites

* A Unix-like environment (Linux, macOS, or WSL on Windows).
* [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Anaconda](https://www.anaconda.com/products/distribution) installed.

### Installation

1.  **Clone this repository:**
    ```bash
    git clone [https://github.com/your-username/edna-pipeline.git](https://github.com/your-username/edna-pipeline.git)
    cd edna-pipeline
    ```

2.  **Run the setup script:** This script will download the required QIIME 2 classifier and generate the Python plotting script.
    ```bash
    chmod +x edna.sh
    ```

## Output

After a successful run, the script will generate several files prefixed with your chosen `<sample-id>`, including:
* **`<sample-id>_table.qza`**: The final ASV abundance table.
* **`<sample-id>_taxonomy.qza`**: The taxonomic assignments for your ASVs.
* **`<sample-id>_sunburst.html`**: An interactive sunburst plot of the taxonomic composition.
* **`<sample-id>_treemap.html`**: An interactive treemap visualization.
* **`<sample-id>_piechart.html`**: An interactive pie-chart visualization.

## Tools Used

* **QIIME 2**: The core bioinformatics platform for orchestrating the analysis.
* **DADA2**: For denoising raw reads and generating high-resolution ASVs.
* **`q2-feature-classifier`**: The QIIME 2 plugin used for taxonomic classification.
* **Plotly**: The Python library used for creating rich, interactive visualizations.
