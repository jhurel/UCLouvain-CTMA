library(VariantAnnotation)

VCF_filt2 <- function(VcfFile1, VcfFile_filt2) {

  indexVcf(VcfFile1)
  
  filt <- FilterRules(list(FILTGENOT1 = function(x) ( as.numeric(geno(x)$AO)/as.numeric(geno(x)$DP)>0.5 ) ))
  filterVcf(file = VcfFile1, filters =filt, destination = VcfFile_filt2)

}

VCF_filt2(snakemake@input[[1]], snakemake@output[[1]])







