process STRINGTIE_REESTIMATE {
    
    tag "$sample_id"

    input:
    tuple val(sample_id), path(bam)
    path merged_gtf

    output:
    tuple val(sample_id), path("${sample_id}/${sample_id}.gtf"),         emit: gtf
    tuple val(sample_id), path("${sample_id}/"),                         emit: ctab

    script:
    """

    mkdir -p ${sample_id}

    stringtie ${bam} \
    -G ${merged_gtf} \
    -o ${sample_id}/${sample_id}.gtf \
    -e \
    -B \
    --rf
    """
}