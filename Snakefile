import os
configfile: "config.yaml"

rule target:
  input:
    expand("02_mapping/{sample}.sorted.bam.bai", sample=config["sample"]),
    "04_Variant_Experiment/sarscov2_ve.rds"
    #"03-VCF-freebayes/variant.q20.vcf"

############################### MAPPING ##############################################

rule Alignment_minimap2:
  input: 
    config['reference_genome'],
    "01-raw-data/{sample}.fastq"
  output: 
    temp("02_mapping/{sample}.sam")
  conda: 
    "envs/Minimap2.yaml"
  shell: 
    "minimap2 -ax map-ont {input[0]} {input[1]} > {output[0]}"

rule Convert_Sam_to_Bam:
  input: 
    rules.Alignment_minimap2.output
  output:
    temp("02_mapping/{sample}.bam")
  conda: 
    "envs/Samtools.yaml"
  shell:
    "samtools view -b {input[0]} -o {output[0]}"

rule Picardtools:
  input: 
    rules.Convert_Sam_to_Bam.output
  output:
    temp("02_mapping/{sample}.RG.bam")
  conda: 
    "envs/Samtools.yaml"
  shell: 
    "picard AddOrReplaceReadGroups I={input[0]} O={output[0]} RGID=ID{wildcards.sample} RGLB=lib{wildcards.sample} RGPL=illumina RGPU=unit1 RGSM={wildcards.sample}"

rule Sort_and_index_bamfile:
  input:
    rules.Picardtools.output
  output:
    "02_mapping/{sample}.sorted.bam",
    "02_mapping/{sample}.sorted.bam.bai"
  conda: 
    "envs/Samtools.yaml"
  shell:"""
    samtools sort {input[0]} -o {output[0]}
    samtools index {output[0]}
  """

############################### DETECT MUTATIONS ##############################################                 

rule Freebayes :  #TIME CONSUMING !!!!
  input:
    expand("02_mapping/{samples}.sorted.bam", samples=config["sample"])
  output:
    "03_VCF_freebayes/variant.vcf"
  params: 
    config['reference_genome']
  conda: 
    "envs/Freebayes.yaml" 
  shell: 
   "freebayes -f {params} --ploidy 1 {input} > 03_VCF_freebayes/variant.vcf"

rule Vcffilter: 
  input:
    rules.Freebayes.output
  output:
    "03_VCF_freebayes/variant2.vcf",
    "03_VCF_freebayes/variant.q20.vcf"
  conda: 
    "envs/Vcffilter.yaml"    
  shell: """
    cat <(echo "##contig=<ID=MN908947.3,length=29903>") {input[0]} > {output[0]}
    biopet-vcffilter -I {output[0]} -o {output[1]} --minQualScore 20
"""
############################### VARIANT EXPERIMENT OBJECT #######################################

rule Vcf_format :
  input:
    rules.Vcffilter.output[1]
  output:
    "03_VCF_freebayes/variant.q20.format.vcf"
  shell: """
    awk -F'\t' -vOFS='\t' '{{ gsub(",", ".", $6) ; print }}' {input[0]} > {output[0]}
  """

rule CreateVEObj : 
  input:
    rules.Vcf_format.output,	
    config['metadata']
  output:
    "04_Variant_Experiment/sarscov2_ve.rds"
  conda: 
    "envs/Bacterio_R.yaml"
  script: 
    "scripts/CreateVariantExperimentObj.R"

