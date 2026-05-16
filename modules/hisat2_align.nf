process HISAT2_ALIGN {

    tag "$sample_id"

    input:
    tuple val(sample_id), path(read1), path(read2)
    path hisat2

    output:
    tuple val(sample_id), path("${sample_id}.bam"), emit: bam
    path "${sample_id}.hisat2.log",                 emit: log

    script:
    """
    tar -xzf ${hisat2}

    hisat2 \
    -x ${params.hisat2_prefix} \
    -1 ${read1} \
    -2 ${read2} \
    --dta \
    --new-summary \
    --summary-file ${sample_id}.hisat2.log | \
    samtools sort -o ${sample_id}.bam
    """
}