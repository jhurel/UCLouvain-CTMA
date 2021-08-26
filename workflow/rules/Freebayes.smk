rule Freebayes :  
  input:
    refgenome,
    os.path.join(outputdir, "02_mapping", "{sample}.sorted.bam")
  output:
    os.path.join(outputdir, "03_variant_detection", "{sample}.variant.vcf")
  conda: 
    "../envs/Freebayes.yaml" 
  shell: 
    "freebayes -f {input[0]} --ploidy 1 {input[1]} > {output[0]}"



