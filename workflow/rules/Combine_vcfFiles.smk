rule Combine_vcfFiles:
  input:
    expand(outputdir + "03_variant_detection/{samples}.filt2.vcf.gz", samples=Samples)
  output:
    os.path.join(outputdir, "05_Variant_Experiment", "variant.all.filt.vcf")
  conda: 
    "../envs/Bcftools.yaml" 
  shell:
    "bcftools merge --force-sample {input} > {output}"

