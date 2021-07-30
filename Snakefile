import os
configfile: "config.yaml"

#Definiton of variables
outputdir = config["output_folder"]
inputdir = config["input_folder"]
refgenome = config['reference_genome']

#Global wildcards for list all names of fastq files in input folder
Samples, = glob_wildcards(inputdir + "{sample}.fastq")

rule target:
  input:
    expand(outputdir + "03_variant_detection/{sample}.filt2.vcf", sample=Samples)	
    #"04_Variant_Experiment/sarscov2_ve.rds"
  

############################### MAPPING ##############################################

rule Alignment_minimap2:
  input: 
    refgenome,
    os.path.join(inputdir,"{sample}.fastq")
  output: 
    temp(os.path.join(outputdir, "02_mapping", "{sample}.sam"))
  conda: 
    "workflow/envs/Minimap2.yaml"
  shell: 
    "minimap2 -ax map-ont -R {wildcards.sample} {input[0]} {input[1]} > {output[0]}"

rule Convert_Sam_to_Bam:
  input: 
    rules.Alignment_minimap2.output
  output:
    temp(os.path.join(outputdir, "02_mapping", "{sample}.bam"))
  conda: 
    "workflow/envs/Samtools.yaml"
  shell:
    "samtools view -b {input[0]} -o {output[0]}"

rule Sort_and_index_bamfile:
  input:
    rules.Convert_Sam_to_Bam.output
  output:
    os.path.join(outputdir, "02_mapping", "{sample}.sorted.bam"),
    os.path.join(outputdir, "02_mapping", "{sample}.sorted.bam.bai")
  conda: 
    "workflow/envs/Samtools.yaml"
  shell:"""
    samtools sort {input[0]} -o {output[0]}
    samtools index {output[0]}
  """

############################### DETECT MUTATIONS ##############################################                 

rule Freebayes :  
  input:
    refgenome,
    rules.Sort_and_index_bamfile.output[0] 
  output:
    os.path.join(outputdir, "03_variant_detection", "{sample}.variant.vcf")
  conda: 
    "workflow/envs/Freebayes.yaml" 
  shell: 
   "freebayes -f {input[0]} --ploidy 1 {input[1]} > {output[0]}"

rule compresse_vcf:
  input:
    rules.Freebayes.output
  output:
    temp(os.path.join(outputdir, "03_variant_detection", "{sample}.vcf.gz"))
  conda: 
    "workflow/envs/Bcftools.yaml" 
  shell: 
    "bcftools view {input} -Oz -o {output}"

rule Vcffile_filt1:
  input:
    rules.compresse_vcf.output
  output:
    temp(os.path.join(outputdir, "03_variant_detection", "{sample}.filt1.vcf"))
  conda: 
    "workflow/envs/Bacterio_R.yaml" 
  script: 
    "workflow/scripts/VCF_filt1.R"

rule compresse_vcf2:
  input:
    rules.Vcffile_filt1.output
  output:
    temp(os.path.join(outputdir, "03_variant_detection", "{sample}.filt1.vcf.gz"))
  conda: 
    "workflow/envs/Bcftools.yaml" 
  shell: 
    "bcftools view {input} -Oz -o {output}"

rule Vcffile_filt2:
  input:
    rules.compresse_vcf2.output
  output:
    os.path.join(outputdir, "03_variant_detection", "{sample}.filt2.vcf")
  conda: 
    "workflow/envs/Bacterio_R.yaml" 
  script: 
    "workflow/scripts/VCF_filt2.R"

############################### VARIANT EXPERIMENT OBJECT #######################################

#rule combine_vcfFiles:
#  input:
#    expand("03_variant_detection/{samples}.filt2.vcf", samples=Samples)
#  output:
#    os.path.join(outputdir, "04_variant_experiment", "variant.all.filt.vcf")
#  conda: 
#    "workflow/envs/Bcftools.yaml" 
#  shell: 
#    "bcftools merge {input} > {output}"

#rule CreateVEObj : 
#  input:
#    rules.Vcf_format.output,	
#    config['metadata']
#  output:
#    os.path.join(outputdir, "04_variant_experiment", "sarscov2_ve.rds")
#  conda: 
#    "workflow/envs/Bacterio_R.yaml"
#  script: 
#    "workflow/scripts/CreateVariantExperimentObj.R"
