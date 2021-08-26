rule Consensus_seq :
  input:
    os.path.join(outputdir, "03_variant_detection", "{samples}.filt2.vcf.gz")
  output:
    os.path.join(outputdir, "04_Consensus_Sequence", "{samples}.consensus.fa")
  conda: 
    "../envs/Bcftools.yaml" 
  params:
    refgenome
  shell:
    "bcftools consensus -f {params} {input} > {output}"
    


