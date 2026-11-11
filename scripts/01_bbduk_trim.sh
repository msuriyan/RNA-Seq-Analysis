#!/bin/bash
#PBS -q auto_free
#PBS -j oe
#PBS -k oed
#PBS -N bbmap
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=18:mpiprocs=18:ompthreads=1:mem=160g

# -----------------------------------------------------------------------------
# Step 1: Adapter trimming, PhiX removal and quality trimming with BBDuk
#
# Input : paired-end reads in the working directory, named <sample>_1.fastq.gz
#         and <sample>_2.fastq.gz
# Output: bbduk_trimmed/<sample>_1.filt.fastq.gz, <sample>_2.filt.fastq.gz
#
# Pass 1 - adapter trimming (ktrim=r, k=23, mink=11, hdist=1, tpe, tbo)
# Pass 2 - PhiX removal (k=27, hdist=1) + quality trimming (qtrim=rl, trimq=20),
#          reads shorter than 40 bp discarded
# -----------------------------------------------------------------------------

# ---- paths (edit for your system) ----
BBDUK=/scratch/snm_02/conda_envs/bbmap/bin/bbduk.sh
BBMAP_RES=/scratch/snm_02/bbmap/BBMap/resources
ADAPTERS=${BBMAP_RES}/adapters.fa
PHIX=${BBMAP_RES}/phix174_ill.ref.fa.gz

cd "$PBS_O_WORKDIR" || exit 1

source ~/.bashrc
module load Anaconda3
source activate bbmap

export _JAVA_OPTIONS="-Xmx120g"

mkdir -p bbduk_trimmed temp

for i in *_1.fastq.gz
do
    sample="${i%_1.fastq.gz}"

    echo "Running BBDuk for ${sample}"

    # Adapter trimming
    ${BBDUK} \
        -Xmx60g \
        threads=8 \
        in="${sample}_1.fastq.gz" \
        in2="${sample}_2.fastq.gz" \
        out="temp/${sample}_1.temp.fastq.gz" \
        out2="temp/${sample}_2.temp.fastq.gz" \
        ref=${ADAPTERS} \
        ktrim=r \
        k=23 \
        mink=11 \
        hdist=1 \
        tpe=t \
        tbo=t \
        overwrite=t

    # PhiX removal and quality trimming
    ${BBDUK} \
        -Xmx60g \
        threads=8 \
        in="temp/${sample}_1.temp.fastq.gz" \
        in2="temp/${sample}_2.temp.fastq.gz" \
        out="bbduk_trimmed/${sample}_1.filt.fastq.gz" \
        out2="bbduk_trimmed/${sample}_2.filt.fastq.gz" \
        ref=${PHIX} \
        k=27 \
        hdist=1 \
        qtrim=rl \
        trimq=20 \
        minlen=40 \
        qin=33 \
        qout=33 \
        overwrite=t

    rm -f \
        "temp/${sample}_1.temp.fastq.gz" \
        "temp/${sample}_2.temp.fastq.gz"

done

rmdir temp 2>/dev/null

echo "BBDuk completed: $(date)"
