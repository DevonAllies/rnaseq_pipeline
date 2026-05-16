process TRIM_GALORE {

    tag "$sample_id"

    input: 
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("*_val_1.fq.gz"), path("*val_2.fq.gz"),   emit: trimmed
    path "*_trimming_report.txt",                                        emit: trimming_report

    script:
    """
    trim_galore \
    --paired \
    --gzip \
    ${reads[0]} ${reads[1]}
    """
}