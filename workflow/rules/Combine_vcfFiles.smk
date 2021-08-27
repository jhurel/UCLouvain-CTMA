rule Combine_vcfFiles:
  input:
    expand(outputdir + "03_variant_detection/{samples}.filt2.vcf.gz", samples=Samples)
  output:
    temp(os.path.join(outputdir, "05_Variant_Experiment", "variant1.all.filt.vcf")),
    temp(os.path.join(outputdir, "05_Variant_Experiment", "sample_names.txt")),
    os.path.join(outputdir, "05_Variant_Experiment", "variant.all.filt.vcf")
  conda: 
    "../envs/Bcftools.yaml" 
  shell:"""
    bcftools merge --force-sample {input} > {output[0]}
    printf '%s\n' {Samples} > {output[1]}
    bcftools reheader -s {output[1]} {output[0]} > {output[2]}
  """
