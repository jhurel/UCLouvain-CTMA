rule CreateVEObj : 
  input:
    os.path.join(outputdir, "05_Variant_Experiment", "variant.all.filt.vcf"),
    config['metadata']
  output:
    os.path.join(outputdir, "05_Variant_Experiment", "sarscov2_ve.rds"),
    os.path.join(outputdir, "05_Variant_Experiment", "sarscov2.gds")
  script: 
    "../scripts/CreateVariantExperimentObj.R"
