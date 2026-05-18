# Devon Allies -- RNA-seq Pipeline

A modular, reproducible Nextflow DSL2 pipeline for paired-end RNA-seq analysis.
Built for use on local machines, with HPC and cloud support coming soon.

---

## Pipeline Overview

```
samples/*_{1,2}.fastq.gz
         |
         |---> FASTQC              Quality control on raw reads
         |
         +--> TRIM_GALORE          Adapter and quality trimming
                   |
                   +--> HISAT2_ALIGN        Splice-aware alignment
                              |
                         STRINGTIE_ASSEMBLE  Per-sample transcript assembly
                              |
                         STRINGTIE_MERGE     Merge all GTFs into consensus
                              |
                         STRINGTIE_REESTIMATE  Re-quantify using merged GTF
                              |
                           MULTIQC           Aggregate QC report
```

---

## Requirements

- [Nextflow](https://www.nextflow.io/) >= 24.10
- Java 17+
  - [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
  - [Trim Galore](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)
  - [HISAT2](http://daehwankimlab.github.io/hisat2/)
  - [SAMtools](http://www.htslib.org/)
  - [StringTie](https://ccb.jhu.edu/software/stringtie/)
  - [MultiQC](https://multiqc.info/)
  - [Docker](https://www.docker.com/) (for `-profile docker`) **or** the following tools installed and available on your PATH (for `-profile local`):
  - [Singularity](https://sylabs.io/singularity/) (for `-profile singularity`) **or** the following tools installed and available on your PATH (for `-profile local`):

---

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/DevonAllies/rnaseq_pipeline.git
cd rnaseq_pipeline
```

### 2. Prepare your folder structure

Place your files in the following directories:

```
rnaseq_pipeline/
├── samples/          <-- paired-end FASTQ files
│   ├── sample1_1.fastq.gz
│   ├── sample1_2.fastq.gz
│   ├── sample2_1.fastq.gz
│   └── sample2_2.fastq.gz
│
├── indexes/          <-- HISAT2 index tar.gz (see below)
│   └── genome_index.tar.gz
│
└── genes/            <-- Reference GTF annotation
    └── annotation.gtf
```

### 3. Build your HISAT2 index

The pipeline expects the index to be tarred with the prefix `indexes/genome`
so it matches the default `params.hisat2_prefix`:

```bash
# Build the index
hisat2-build genome.fa indexes/genome

# Tar it up
tar -czf genome_index.tar.gz indexes/

# Move to the indexes folder
mv genome_index.tar.gz indexes/
```

### 4. Run the pipeline

```bash
# With Docker (no tool installation required)
nextflow run rnaseq.nf -profile docker

# With Singularity (for HPC clusters)
nextflow run rnaseq.nf -profile singularity

# With tools installed locally
nextflow run rnaseq.nf -profile local
```
```

---

## Parameters

All parameters have defaults pointing to the expected folder structure.
Override any of them on the command line with `--parameter value`.

| Parameter | Default | Description |
|---|---|---|
| `--reads` | `samples/*_{1,2}.fastq.gz` | Glob pattern for paired FASTQ files |
| `--hisat2` | `indexes/*.tar.gz` | Path to HISAT2 index tar.gz |
| `--hisat2_prefix` | `indexes/genome` | Index prefix inside the tar |
| `--gtf` | `genes/*.gtf` | Reference annotation GTF file |
| `--outdir` | `results` | Output directory |

---

## Output

```
results/
├── fastqc/                      FastQC HTML reports and ZIP files
├── trimming/                    Trimmed reads and trimming reports
├── align/                       Sorted BAM files and HISAT2 logs
├── stringtie/
│   ├── assembled/               Per-sample GTF files and ctab files
│   ├── merged/                  Merged consensus GTF (merged.gtf)
│   └── final/                   Re-estimated GTFs and ctab files
│       ├── sample1/             Per-sample subdirectory for Ballgown
│       │   ├── e2t.ctab
│       │   ├── e_data.ctab
│       │   ├── i2t.ctab
│       │   ├── i_data.ctab
│       │   └── t_data.ctab
│       └── sample2/
└── multiqc/                     Aggregated QC report (HTML)
```

The `stringtie/final/` directory is structured for direct input into
[Ballgown](https://bioconductor.org/packages/release/bioc/html/ballgown.html)
for downstream differential expression analysis in R.

---

## Profiles

| Profile | Description |
|---|---|
| `local` | Run on a local machine. Requires tools installed on PATH. CPUs: 4, Memory: 8GB |
| `docker` | Run with Docker containers. No manual tool installation needed. |
| `singularity` | Run with Singularity containers. Designed for HPC clusters. |

- `cloud` -- Cloud execution with Docker

---

## Downstream Analysis

After the pipeline completes, load the `stringtie/final/` ctab files
into R/RStudio using [Ballgown](https://bioconductor.org/packages/release/bioc/html/ballgown.html)
for differential expression analysis:

```r
library(ballgown)

bg <- ballgown(
    dataDir       = "results/stringtie/final",
    samplePattern = "sample",
    pData         = pheno_data
)
```

---

## Modules

| Module | Tool | Purpose |
|---|---|---|
| `fastqc.nf` | FastQC | Raw read quality control |
| `trim_galore.nf` | Trim Galore | Adapter trimming |
| `hisat2_align.nf` | HISAT2 + SAMtools | Splice-aware alignment |
| `stringtie.nf` | StringTie | Per-sample transcript assembly |
| `string_merge.nf` | StringTie | Merge per-sample GTFs |
| `stringtie_reestimate.nf` | StringTie | Re-estimate expression |
| `multiqc.nf` | MultiQC | Aggregate QC report |

---

## Author

Devon Allies
[GitHub](https://github.com/DevonAllies)