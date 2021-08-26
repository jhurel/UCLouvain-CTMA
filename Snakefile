import os
configfile: "config.yaml"

#Definiton of variables
outputdir = config["output_folder"]
inputdir = config["input_folder"]
refgenome = config['reference_genome']

#Global wildcards for list all names of fastq files in input folder
Samples, = glob_wildcards(inputdir + "{sample}." + config["extension"])

rule target:
  input:
    expand(outputdir + os.path.join("04_Consensus_Sequence", "{sample}_consensus.fa"), sample=Samples),
    os.path.join(outputdir, "05_Variant_Experiment", "variant.all.filt.vcf")
    os.path.join(outputdir, "05_Variant_Experiment", "sarscov2_ve.rds")
  
############################### MAPPING ##############################################

include : 'workflow/rules/Alignment_minimap2.smk'
include : 'workflow/rules/Convert_sort_and_index_bamfile.smk'

############################### DETECT MUTATIONS #####################################           

include : 'workflow/rules/Freebayes.smk'
include : 'workflow/rules/Vcf_compress_filter.smk'

############################### CONSENSUS #####################################   

include : 'workflow/rules/Consensus_seq.smk'

############################### VARIANT EXPERIMENT OBJECT ############################

include : 'workflow/rules/Combine_vcfFiles.smk'
include : 'workflow/rules/CreateVEObj.smk'
