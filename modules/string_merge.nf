process STRINGTIE_MERGE {

    input:
    path gtf_list
    path ref_gtf

    output:
    path "merged.gtf",       emit: merged_gtf

    script:
    """
    stringtie --merge \
    -G ${ref_gtf} \
    -o merged.gtf \
    ${gtf_list}
    """
}