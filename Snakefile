import os
configfile: "config.yaml"

rule target:
  input:
    expand("02-mapping/{sample}.sorted.bam.bai", sample=config["sample"]),
    "04-Variant-Experiment/sarscov2_ve.rds"
    #"03-VCF-freebayes/variant.q20.vcf"


############################### MAPPING ##############################################

#1 - minimap2 -ax map-ont Sars-Cov2_reference_genome_2020.fasta Raw-data//SRR12881615_1.fastq > 02-mapping/SRR12881615_1.sam

rule Alignment_minimap2 :
  input: 
    config['reference_genome'],
    "01-raw-data/{sample}.fastq"
  output: 
    temp("02-mapping/{sample}.sam")
  shell: 
    "minimap2 -ax map-ont {input[0]} {input[1]} > {output[0]}"


#2 - Samtools view -b 02-mapping/SRR12881615_1.sam -o 02-mapping/SRR12881615_1.bam 

rule Convert_Sam_to_Bam :
  input: 
    rules.Alignment_minimap2.output
  output:
    temp("02-mapping/{sample}.bam")
  shell:
    "samtools view -b {input[0]} -o {output[0]}"
 

#3 - picard AddOrReplaceReadGroups I=02-mapping/SRR12881615_1.bam O=02-mapping/SRR12881615_1.RG.bam  RGID=3 RGLB=lib3 RGPL=illumina RGPU=unit1 RGSM=SRR12881615_1

rule Picardtools:
  input: 
    rules.Convert_Sam_to_Bam.output
    #expand(["{sample}.{id}", zip, sample=config["sample"], id=config["Id"])
  output:
    temp("02-mapping/{sample}.RG.bam")
  shell: 
    "picard AddOrReplaceReadGroups I={input[0]} O={output[0]} RGID=ID{wildcards.sample} RGLB=lib{wildcards.sample} RGPL=illumina RGPU=unit1 RGSM={wildcards.sample}"

#4 - samtools sort 02-mapping/SRR12881615_1.RG.bam -o 02-mapping/SRR12881615_1.sorted.bam
#5 - samtools index 02-mapping/SRR12881615_1.sorted.bam
rule Sort_and_index_bamfile :
  input:
    rules.Picardtools.output
  output:
    "02-mapping/{sample}.sorted.bam",
    "02-mapping/{sample}.sorted.bam.bai"
  shell:"""
    samtools sort {input[0]} -o {output[0]}
    samtools index {output[0]}
  """

############################### DETECT MUTATIONS ##############################################

#freebayes -f Sars-Cov2_reference_genome_2020.fasta --ploidy 1 Programs/Pipeline_Bacterio_JA/02-mapping//SRR12881613_1.sorted.bam Programs/Pipeline_Bacterio_JA/02-mapping//SRR12881614_1.sorted.bam > 03-VCF-freebayes/variant.vcf                     

rule Freebayes :  #TIME CONSUMING !!!!
  input:
    expand("02-mapping/{samples}.sorted.bam", samples=config["sample"])
  output:
    "03-VCF-freebayes/variant.vcf"
  params: 
    config['reference_genome']
  shell: 
   "freebayes -f {params} --ploidy 1 {input} > 03-VCF-freebayes/variant.vcf"

#myarg <- c('-f "QUAL > 20" 03-VCF-freebayes/variant.vcf >03-VCF-freebayes/variant.q20.vcf' )
#system2(command='vcffilter',args=myarg)

rule vcffilter : 
  input:
    rules.Freebayes.output
  output:
    "03-VCF-freebayes/variant.q20.vcf"
  shell: 
   "biopet-vcffilter -I {input[0]} -o {output[0]} --minQualScore 20"

############################### VARIANT EXPERIMENT OBJECT #######################################

rule CreateVEObj : 
  input:
    #rules.vcffilter.output,
    "03-VCF-freebayes/variant.q20.point.vcf",	
    config['metadata']
  output:
    "04-Variant-Experiment/sarscov2_ve.rds"
  conda: 
    "Env_conda/Bacterio_R.yaml"
  script: 
    "Scripts/CreateVariantExperimentObj.R"

