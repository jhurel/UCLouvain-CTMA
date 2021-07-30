library(VariantAnnotation)

VCF_filt1 <- function(VcfFile, VcfFile_filt1) {

  indexVcf(VcfFile)
  
  filt <- FilterRules(list(FILTGENOT1 = function(x) ( (geno(x)$GT == 1) & (rowRanges(x)$QUAL>20 ) )))
  filterVcf(file = VcfFile, filters =filt, destination = VcfFile_filt1)

}

VCF_filt1(snakemake@input[[1]], snakemake@output[[1]])







