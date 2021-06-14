import os
configfile: "config.yaml"

rule target:
  input:
    expand("02-mapping/{sample}.sorted.bam.bai", sample=config["sample"]),
    "04-Variant-Experiment/sarscov2_ve.rds"
    #"03-VCF-freebayes/variant.q20.vcf"

############################### MAPPING ##############################################

rule Alignment_minimap2:
  input: 
    config['reference_genome'],
    "01-raw-data/{sample}.fastq"
  output: 
    temp("02-mapping/{sample}.sam")
  conda: 
    "envs/Snakemake_bacterio.yaml"
  shell: 
    "minimap2 -ax map-ont {input[0]} {input[1]} > {output[0]}"

rule Convert_Sam_to_Bam:
  input: 
    rules.Alignment_minimap2.output
  output:
    temp("02-mapping/{sample}.bam")
  conda: 
    "envs/Snakemake_bacterio.yaml"
  shell:
    "samtools view -b {input[0]} -o {output[0]}"

rule Picardtools:
  input: 
    rules.Convert_Sam_to_Bam.output
  output:
    temp("02-mapping/{sample}.RG.bam")
  conda: 
    "envs/Snakemake_bacterio.yaml"
  shell: 
    "picard AddOrReplaceReadGroups I={input[0]} O={output[0]} RGID=ID{wildcards.sample} RGLB=lib{wildcards.sample} RGPL=illumina RGPU=unit1 RGSM={wildcards.sample}"

rule Sort_and_index_bamfile:
  input:
    rules.Picardtools.output
  output:
    "02-mapping/{sample}.sorted.bam",
    "02-mapping/{sample}.sorted.bam.bai"
  conda: 
    "envs/Snakemake_bacterio.yaml"
  shell:"""
    samtools sort {input[0]} -o {output[0]}
    samtools index {output[0]}
  """

############################### DETECT MUTATIONS ##############################################                 

rule Freebayes :  #TIME CONSUMING !!!!
  input:
    expand("02-mapping/{samples}.sorted.bam", samples=config["sample"])
  output:
    "03-VCF-freebayes/variant.vcf"
  params: 
    config['reference_genome']
  conda: 
    "envs/Snakemake_bacterio.yaml" 
  shell: 
   "freebayes -f {params} --ploidy 1 {input} > 03-VCF-freebayes/variant.vcf"

rule vcffilter: 
  input:
    rules.Freebayes.output
  output:
    "03-VCF-freebayes/variant.q20.vcf"
  conda: 
    "envs/Snakemake_bacterio.yaml"    
  shell: 
   "biopet-vcffilter -I {input[0]} -o {output[0]} --minQualScore 20"

############################### VARIANT EXPERIMENT OBJECT #######################################

rule CreateVEObj : 
  input:
    rules.vcffilter.output,
    #"03-VCF-freebayes/variant.q20.point.vcf",	
    config['metadata']
  output:
    "04-Variant-Experiment/sarscov2_ve.rds"
  conda: 
    "envs/Bacterio_R.yaml"
  script: 
    "Scripts/CreateVariantExperimentObj.R"

