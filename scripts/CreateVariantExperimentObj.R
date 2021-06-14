CreateVariantExperimentObj <- function(variant, coldata, VEObj) {

#Packages
library(SummarizedExperiment)
library(VariantExperiment)
library(VariantAnnotation)
library(SeqArray)

#Creation of the object based on a vcf file
vcf.header <- seqVCF_Header(variant)
seqVCF2GDS(vcf.fn = variant, out.fn = '04-Variant-Experiment/sarscov2.gds', info.import = c('GT','DP'))
sarscov2_ve <- makeVariantExperimentFromGDS('04-Variant-Experiment/sarscov2.gds')
assayNames(sarscov2_ve) <- c('genotype','DP')

#Sample annotations/metadata (aka colData)
col_data <- DataFrame(read.csv(coldata))
rownames(col_data) <- col_data$Sample.ID
col_data <- col_data[match(colnames(sarscov2_ve), col_data$SRA.ID), ]
stopifnot(identical(colnames(sarscov2_ve), col_data$SRA.ID))
SummarizedExperiment::colData(sarscov2_ve) <- col_data

#Feature annotations/medata (aka rowData)
vcffile.fb <- readVcf(variant)
SummarizedExperiment::rowRanges(sarscov2_ve) <- SummarizedExperiment::rowRanges(vcffile.fb)

#Annotation of variants of interest/concern
rowData(sarscov2_ve)$VOC1 <- rowData(sarscov2_ve)$VOC2 <- FALSE
rowData(sarscov2_ve)$VOC1[c(7, 26)] <- TRUE
rowData(sarscov2_ve)$VOC2[38] <- TRUE
sarscov2_ve$has_VOC1 <- sarscov2_ve$has_VOC2 <- FALSE
sarscov2_ve$has_VOC1[c(2, 6, 9)] <- TRUE
sarscov2_ve$has_VOC2[c(3, 5, 8)] <- TRUE

#Serialisation of the object
saveRDS(sarscov2_ve, VEObj)

}
CreateVariantExperimentObj(snakemake@input[[1]], snakemake@input[[2]], snakemake@output[[1]])

