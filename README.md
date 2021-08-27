# UCLouvain-CTMA

## Introduction

As part of the European project PANDEM-2, this pipeline is developped to analyse SARS-CoV-2 genomic data (from the SRA database) and its associated metadata. The steps performed are the mapping, the transformation of the SAM files, the variants calling, the consensus sequences and the creation of an experiment variant object. The output file is in .rds format.

## Params in config.yaml

- Reference genome file
- Metadata file
- Genomic input data path with extension format
- Results path 

## Installation with mamba/conda 

Git clone
```
git clone https://github.com/jhurel/UCLouvain-CTMA.git
cd UCLouvain-CTMA
```
Create a conda/mamba environnement 
```
conda env remove -n PANDEM2_env
mamba env create --file workflow/envs/PANDEM2_env.yml
conda activate PANDEM2_env
```
Launch the pipeline
```
snakemake --cores all -rp
```
