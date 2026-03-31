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
# sbatch --array=1-$(ls /scratch/pawsey0159/abud/ophiodonElongatus/03-trimmed/*_R1_val_1.fq.gz | wc -l) 04_align_sort_array_pe.slurm
## OR (for testing)
# sbatch -a 1-3 04_align_sort_array_pe.slurm

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

# Specify variables
INPUT_DIR="$SPECIES/03-trimmed"
OUTPUT_DIR="$SPECIES/04-alignedSorted"
GENOME_DIR="$SPECIES/genome"
TEMP_DIR="$SPECIES/temp"

BISMARK="/software/projects/pawsey0159/setonix/TrEnD_containers/bismark_0.24.2--hdfd78af_0.sif"

# Create output directories
mkdir -p $OUTPUT_DIR $TEMP_DIR

# Load and list software
module load samtools/1.15--h3843a85_0
module load singularity/4.1.0
module list

# Get the files to process based on the SLURM array task ID
R1=$(ls $INPUT_DIR/*_R1_val_1.fq.gz | sed -n "${SLURM_ARRAY_TASK_ID}p")
R2="${R1/_R1_val_1/_R2_val_2}"

echo $R1
echo $R2

# Derive the base name for the output files
BASE=$(basename $R1 _R1_val_1.fq.gz)

# Create a unique temporary directory for this job
TEMP_SMPL_DIR="${TEMP_DIR}/${BASE}Temp"
mkdir -p $TEMP_SMPL_DIR

# Perform alignment with Bismark and Bowtie2
singularity exec "$BISMARK" bismark --non_directional -N 1 \
	--temp_dir $TEMP_SMPL_DIR -o $OUTPUT_DIR -p $SLURM_CPUS_PER_TASK -B ${BASE}_bismark_bt2 \
	$GENOME_DIR -1 $R1 -2 $R2

# Sort BAM file by read name for downstream compatibility
INPUT_BAM="${OUTPUT_DIR}/${BASE}_bismark_bt2_pe.bam"
SORTED_BAM="${OUTPUT_DIR}/${BASE}_bismark_bt2_pe_sorted.bam"
samtools sort -n -o "$SORTED_BAM" "$INPUT_BAM"

# Remove the temporary directory
rm -rf $TEMP_SMPL_DIR

echo "Job complete for $BASE"

# End script
