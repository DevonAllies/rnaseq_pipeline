process MULTIQC {

    input:
    path qc_files

    output:
    path "multiqc_report.html",     emit: multiqc_report
    path "multiqc_data/",           emit: multiqc_data

    script:
    """
    multiqc .
    """
}