#!/bin/bash

#SBATCH --account=pawsey0159
#SBATCH --mail-type=FAIL
#SBATCH --output=%x.%j.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4GB
#SBATCH --time=8:00:00
#SBATCH --partition work

# Script to run fastqc on the raw data files ----

SPECIES=$(basename $PWD) 
echo $SPECIES

# Move to scratch
cd /scratch/pawsey0159/abud

# Specify vairables
RUN="AGRF_NXGSQCAGRF25090204-1_M52NN"
echo $RUN

INPUT="$SPECIES/rawData/$RUN"
OUTPUT="$SPECIES/02-fastQcRawData"
FASTQC="/software/setonix/2024.05/containers/views/modules/fastqc/0.11.9--hdfd78af_1"

# Create the output directory if it does not exist
mkdir -p "$OUTPUT"

# Load software
module load fastqc/0.11.9--hdfd78af_1

# Run FastQC on all FASTQ files in the directory
for FILE in $INPUT/*.fastq.gz; do
    echo "Running FastQC on raw data $FILE..."
    fastqc "$FILE" -o "$OUTPUT"
done

echo "Job complete"

# End script
