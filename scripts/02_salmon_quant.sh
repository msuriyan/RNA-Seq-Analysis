#!/bin/bash
#PBS -q auto_free
#PBS -j oe
#PBS -k oed
#PBS -N RNA_salmon
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=36:mpiprocs=36:ompthreads=1:mem=240g

# -----------------------------------------------------------------------------
# Step 2: Transcript quantification with Salmon (v2.4)
#
# Input : trimmed reads from step 1 (<sample>_1.filt.fastq.gz / _2.filt.fastq.gz)
#         - run this from the bbduk_trimmed/ directory
# Output: salmon/<sample>_quant/ (quant.sf, quant.genes.sf, logs)
#
# Options: automatic library-type detection (-l A), selective alignment
#          (--validateMappings), sequence- and GC-bias correction, gene-level
#          aggregation via a tx2gene table (-g)
# -----------------------------------------------------------------------------

# ---- paths (edit for your system) ----
SALMON=/scratch/snm_02/conda_envs/salmon2.4/bin/salmon
INDEX=/scratch/snm_02/Genome/ilBicGentrome_salmonIndex
TX2GENE=/scratch/snm_02/Genome/tx2gene_XMR.tsv
OUTDIR=/scratch/snm_02/BanyRNA/bbduk_trimming/salmon

cd "$PBS_O_WORKDIR" || exit 1

module load Anaconda3/2023.09-0
source activate salmon2.4

mkdir -p ${OUTDIR}

for i in `ls -1 *_1.filt.fastq.gz | sed 's/_1.filt.fastq.gz//'`
do
  echo "Run salmon for ${i}"

  ${SALMON} quant -i ${INDEX} \
    -p 24 \
    --libType A \
    -g ${TX2GENE} \
    -1 ${i}_1.filt.fastq.gz \
    -2 ${i}_2.filt.fastq.gz \
    --validateMappings \
    --seqBias \
    --gcBias \
    -o ${OUTDIR}/${i}_quant

done
