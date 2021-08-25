cwlVersion: v1.2
class: Workflow
id: run_deseq2_analysis
label: Run DESeq2 Analysis comparing samples in histology groups to GTEX
doc: |-
  # Run DESeq2 Analysis comparing samples in histology groups to GTEX

requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

inputs:
  output_basename: {type: string, doc: "Output basename for workflow output files"}
  gene_count_file: {type: File, doc: "RSEM gene counts rds file"}
  histology_file: {type: File, doc: "Histology file, should be the base histology file"}
  tpm_file: {type: File, doc: "TPM counts rds file"}
  hugo_file: {type: File, doc: "ENSG Hugo codes tsv file"}
  mondo_file: {type: File, doc: "MONDO and EFO codes tsv file"}
  uberon_file: {type: File, doc: "UBERON codes tsv file"}

outputs:
  results_dirs: {type: 'Directory[]', outputSource: run_deseq2/results_dir}
steps:

  subset_inputs:
    run: ../tools/deseq_subsetting.cwl
    in:
      count_file: gene_count_file
      histology_file: histology_file
    out: [subsetted_histology, subsetted_count, histology_length_file, gtex_length_file]

  build_hist_array:
    run: ../tools/build_index_array.cwl
    in:
      index_max_file: subset_inputs/histology_length_file
    out: [index_array]

  build_gtex_array:
    run: ../tools/build_index_array.cwl
    in:
      index_max_file: subset_inputs/gtex_length_file
    out: [index_array]

  run_deseq2:
    run: ../tools/run_deseq.cwl
    scatter: [build_hist_array/index_array, build_gtex_array/index_array]
    scatterMethod: flat_crossproduct
    in:
      count_file: subset_inputs/subsetted_count
      histology_file: subset_inputs/subsetted_histology
      tpm_file: tpm_file
      hugo_file: hugo_file
      mondo_file: mondo_file
      uberon_file: uberon_file
      histology_index: build_hist_array/index_array
      gtex_index: build_gtex_array/index_array
      out_dir: output_basename
    out: [results_dir]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 2
