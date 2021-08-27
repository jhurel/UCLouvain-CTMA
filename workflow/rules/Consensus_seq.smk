rule Consensus_seq :
  input:
    refgenome,
    os.path.join(outputdir, "03_variant_detection", "{samples}.filt2.vcf.gz")
  output:
    os.path.join(outputdir, "04_Consensus_Sequence", "{samples}.consensus.fa")
  shell:
    "bcftools consensus -f {input[0]} {input[1]} > {output}"
    


