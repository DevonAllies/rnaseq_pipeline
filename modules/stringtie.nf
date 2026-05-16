process STRINGTIE_ASSEMBLE {

    tag "$sample_id"

    input:
    tuple val(sample_id), path(bam)
    path gtf

    output:
    tuple val(sample_id), path("${sample_id}.gtf"),         emit: gtf
    tuple val(sample_id), path("*.ctab"),                   emit: ctab

    script:
    """
    stringtie ${bam} \
    -G ${gtf} \
    -o ${sample_id}.gtf \
    -e \
    -B \
    --rf
    """
}