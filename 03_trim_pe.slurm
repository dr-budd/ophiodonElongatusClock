#!/bin/bash

#SBATCH --account=pawsey0159
#SBATCH --mail-type=FAIL
#SBATCH --output=%x.%j.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8GB
#SBATCH --time=24:00:00
#SBATCH --partition work

# Script to trim paired reads and run fastqc on the results ----

SPECIES=$(basename $PWD) 
echo $SPECIES

# Move to scratch
cd /scratch/pawsey0159/abud

# Specify variables
RUN="AGRF_NXGSQCAGRF25090204-1_M52NN"

INPUT_DIR="$SPECIES/rawData/$RUN"
OUTPUT_DIR="$SPECIES/03-trimmed"
OUTPUT_FQ="$SPECIES/03-trimmedFastQc"

TRIMGALORE="/software/projects/pawsey0159/setonix/TrEnD_containers/trim-galore_0.6.9--hdfd78af_0.sif"

# Create output directories
mkdir -p "$OUTPUT_DIR" "$OUTPUT_FQ"

# Load software
module load singularity/4.1.0

# Loop through all _R1_001.fastq.gz files
for R1 in "$INPUT_DIR"/*_L001_R1.fastq.gz; do

    # Derive the corresponding R2 file name
    R2="${R1/_R1/_R2}"

    # Derive the base name for the output files
    BASE=$(basename "$R1" _L001_R1.fastq.gz)

    # Trim Galore
    singularity exec "$TRIMGALORE" trim_galore --paired \
        --output_dir "$OUTPUT_DIR" \
        --clip_R1 1 --clip_R2 1 \
        --three_prime_clip_R1 1 --three_prime_clip_R2 1 \
        --gzip --fastqc --fastqc_args "--outdir $OUTPUT_FQ" \
        --trim-n "$R1" "$R2"

    # Log completion
    echo "Trimmed $BASE completed at $(date)"
    
done

echo "Job complete"

# End script
