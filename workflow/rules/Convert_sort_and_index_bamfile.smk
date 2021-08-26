rule Convert_sort_and_index_bamfile:
  input:
    os.path.join(outputdir, "02_mapping", "{sample}.sam")
  output:
    os.path.join(outputdir, "02_mapping", "{sample}.bam"),
    os.path.join(outputdir, "02_mapping", "{sample}.sorted.bam"),
    os.path.join(outputdir, "02_mapping", "{sample}.sorted.bam.bai")
  conda: 
    "../envs/Samtools.yaml"
  shell:"""
    samtools view -b {input[0]} -o {output[0]}
    samtools sort {output[0]} -o {output[1]}
    samtools index {output[1]}
  """


