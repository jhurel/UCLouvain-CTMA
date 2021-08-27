rule compresse_vcf:
  input:
    os.path.join(outputdir, "03_variant_detection", "{sample}.variant.vcf")
  output:
    temp(os.path.join(outputdir, "03_variant_detection", "{sample}.vcf.gz"))
  shell: 
    "bcftools view {input} -Oz -o {output}"

rule Vcffile_filt1:
  input:
    rules.compresse_vcf.output
  output:
    temp(os.path.join(outputdir, "03_variant_detection", "{sample}.filt1.vcf"))
  script: 
    "../scripts/VCF_filt1.R"

rule compresse_vcf2:
  input:
    rules.Vcffile_filt1.output
  output:
    temp(os.path.join(outputdir, "03_variant_detection", "{sample}.filt1.vcf.gz"))
  shell: 
    "bcftools view {input} -Oz -o {output}"

rule Vcffile_filt2:
  input:
    rules.compresse_vcf2.output
  output:
    temp(os.path.join(outputdir, "03_variant_detection", "{sample}.filt2.vcf"))
  script: 
    "../scripts/VCF_filt2.R"

rule compresse_vcf3:
  input:
    rules.Vcffile_filt2.output
  output:
    os.path.join(outputdir, "03_variant_detection", "{sample}.filt2.vcf.gz")
  shell: """
    bcftools view {input} -Oz -o {output}
    bcftools index {output}
 """
