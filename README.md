# UCLouvain-CTMA

## Introduction

As part of the European project PANDEM-2, this pipeline is developped to analyse SARS-CoV-2 genomic data (from the SRA database) and its associated metadata. The steps performed are the mapping, the transformation of the SAM files, the variants calling and the creation of an experiment variant object. The output file is in .rds format.

## Params in config.yaml

- Reference genome file
- Metadata file 
- Sample names 

## Installation with conda 

Git clone
```
git clone https://github.com/jhurel/UCLouvain-CTMA.git
cd UCLouvain-CTMA
```
Create a conda environnement 
```
conda create -n PANDEM_NGS -c bioconda snakemake
conda activate PANDEM_NGS
```
Launch the pipeline
```
snakemake --use-conda -rp
```
