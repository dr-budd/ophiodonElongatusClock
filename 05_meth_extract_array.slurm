#!/bin/bash

#SBATCH --account=pawsey0159
#SBATCH --mail-type=FAIL
#SBATCH --output=%x.%j.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8GB
#SBATCH --time=24:00:00
#SBATCH --partition work

## this script can be submitted with the following command
# sbatch --array=1-$(ls /scratch/pawsey0159/abud/ophiodonElongatus/04-alignedSorted/*_bismark_bt2_pe_sorted.bam | wc -l) 05_meth_extract_array.slurm
## OR (for testing)
# sbatch -a 1-3 05_meth_extract_array.slurm

## check if the array has been specified
if [ -z "${SLURM_ARRAY_TASK_ID}" ]; then
	echo "Error: This is an array job that requires the -a flag."
	exit 1
fi

# Get species (folder) name
SPECIES=$(basename $PWD) 
echo $SPECIES

# Move to scratch
cd /scratch/pawsey0159/abud

## specify variables
INPUT="$SPECIES/04-alignedSorted"
OUTPUT="$SPECIES/05-methylationCalls"

BISMARK="/software/projects/pawsey0159/setonix/TrEnD_containers/bismark_0.24.2--hdfd78af_0.sif"

## create output directories
mkdir -p $OUTPUT

# Load and list software
module load singularity/4.1.0
module list

## get the file to process based on the SLURM array task ID
FILE=$(ls $INPUT/*_bismark_bt2_pe_sorted.bam | sed -n "${SLURM_ARRAY_TASK_ID}p")

## derive the base name for the output files
BASE=$(basename $FILE _bismark_bt2_pe_sorted.bam)

## methylation calling with the Bismark methylation extractor
singularity exec "$BISMARK" bismark_methylation_extractor --paired-end --gzip --bedGraph --comprehensive --multicore $SLURM_CPUS_PER_TASK -o $OUTPUT $FILE

echo "Job complete for $BASE"

## end script
