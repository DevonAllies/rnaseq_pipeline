process FASTQC {

    tag "$sample_id"

    input:
    tuple val(sample_id), path(reads)

    output:
    path "*_fastqc.zip",          emit: zip
    path "*_fastqc.html",         emit: html

    script:
    """
    fastqc ${reads}
    """
}