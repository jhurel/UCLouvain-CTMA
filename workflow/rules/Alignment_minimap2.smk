rule Alignment_minimap2:
  input: 
    refgenome,
    os.path.join(inputdir,"{sample}.fastq")
  output: 
    temp(os.path.join(outputdir, "02_mapping", "{sample}.sam"))
  conda: 
    "../envs/Minimap2.yaml"
  shell: 
    "minimap2 -ax map-ont -R {wildcards.sample} {input[0]} {input[1]} > {output[0]}"
