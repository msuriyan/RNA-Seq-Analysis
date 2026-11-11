# Bicyclus anynana RNA-seq pipeline

Scripts used for RNA-seq processing and downstream analysis of the butterfly
*Bicyclus anynana*. Jobs are written for a PBS Pro HPC cluster and run
sequentially, one sample after another, within a single job.

## Pipeline

| Step | Script | Tool | What it does |
|------|--------|------|--------------|
| 1 | [`scripts/01_bbduk_trim.sh`](scripts/01_bbduk_trim.sh) | BBDuk (BBMap) | Adapter trimming, PhiX removal, quality trimming (Q20, min length 40 bp) |
| 2 | [`scripts/02_salmon_quant.sh`](scripts/02_salmon_quant.sh) | Salmon 2.4 | Transcript quantification with sequence/GC-bias correction and gene-level aggregation |

More steps (differential expression, alternative splicing) will be added.

## Requirements

- PBS Pro scheduler (`qsub`)
- Conda environments with [BBMap](https://sourceforge.net/projects/bbmap/) and [Salmon](https://github.com/COMBINE-lab/salmon) 2.4
- A Salmon index of the *B. anynana* transcriptome and a transcript-to-gene table (`tx2gene`)

## Usage

Each script has a `paths` block near the top — edit those to match your system.

```bash
# Step 1: run in the folder holding the raw <sample>_1.fastq.gz / <sample>_2.fastq.gz
qsub scripts/01_bbduk_trim.sh

# Step 2: run in bbduk_trimmed/
cd bbduk_trimmed
qsub ../scripts/02_salmon_quant.sh
```

## Input naming

Paired-end files must follow `<sample>_1.fastq.gz` and `<sample>_2.fastq.gz`.
The sample name is taken from everything before `_1`.

## Author

Suriya
