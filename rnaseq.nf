#!/usr/bin/env nextflow

// Include -- import module files
include { FASTQC }                  from './modules/fastqc.nf'
include { TRIM_GALORE }             from './modules/trim_galore.nf'
include { HISAT2_ALIGN }            from './modules/hisat2_align.nf'
include { STRINGTIE_ASSEMBLE }      from './modules/stringtie.nf'
include { STRINGTIE_MERGE }         from './modules/string_merge.nf'
include { STRINGTIE_REESTIMATE }    from './modules/stringtie_reestimate.nf'
include { MULTIQC }                 from './modules/multiqc.nf'

// workflow 
workflow {

    main: 
    // Create 
    read_ch     =   channel.fromFilePairs(params.reads, checkIfExists: true)
    gtf_ch      =   channel.fromPath(params.gtf, checkIfExists: true).first()
    hisat2_ch   =   channel.fromPath(params.hisat2, checkIfExists: true).first()

    // FastQC
    FASTQC(read_ch)

    // Adaptor trimming
    TRIM_GALORE(read_ch)

    // Alignment to reference genome
    HISAT2_ALIGN(TRIM_GALORE.out.trimmed, hisat2_ch)

    // Transcript assembly and quantification
    STRINGTIE_ASSEMBLE(HISAT2_ALIGN.out.bam, gtf_ch)

    // Merge all gtfs from stringtie into one input
    STRINGTIE_MERGE(
        STRINGTIE_ASSEMBLE.out.gtf
            .map { _sample_id, gtf -> gtf }
            .collect(),
        gtf_ch
    )

    STRINGTIE_REESTIMATE(
        HISAT2_ALIGN.out.bam,
        STRINGTIE_MERGE.out.merged_gtf
    )

    // Collect QC from all tools and samples
    MULTIQC(
        FASTQC.out.zip
            .mix(TRIM_GALORE.out.trimming_report)
            .mix(HISAT2_ALIGN.out.log)
            .collect()
    )

    publish:
    // Declare outputs to publish
    fastqc_zip      =   FASTQC.out.zip
    fastqc_html     =   FASTQC.out.html
    trimmed         =   TRIM_GALORE.out.trimmed
    trimming_report =   TRIM_GALORE.out.trimming_report
    bam             =   HISAT2_ALIGN.out.bam
    align_log       =   HISAT2_ALIGN.out.log
    gtf             =   STRINGTIE_ASSEMBLE.out.gtf
    ctab            =   STRINGTIE_ASSEMBLE.out.ctab
    merged_gtf      =   STRINGTIE_MERGE.out.merged_gtf
    reestimate_gtf  =   STRINGTIE_REESTIMATE.out.gtf
    reestimate_ctab =   STRINGTIE_REESTIMATE.out.ctab
    multiqc_report  =   MULTIQC.out.multiqc_report
}

output {
    fastqc_zip {
        path 'fastqc'
    }
    fastqc_html {
        path 'fastqc'
    }
    trimmed {
        path 'trimming'
    }
    trimming_report {
        path 'trimming'
    }
    bam {
        path 'align'
    }
    align_log {
        path 'align'
    }
    gtf {
        path 'stringtie/assembled'
    }
    ctab {
        path 'stringtie/assembled'
    }
    merged_gtf {
        path 'stringtie/merged'
    }
    reestimate_gtf {
        path 'stringtie/final'; mode 'copy'
    }
    reestimate_ctab {
        path 'stringtie/final'; mode 'copy'
    }
    multiqc_report {
        path 'multiqc'
    }
}