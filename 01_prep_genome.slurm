#!/bin/bash

#SBATCH --account=pawsey0159
#SBATCH --mail-type=FAIL
#SBATCH --output=%x.%j.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16GB
#SBATCH --time=8:00:00
#SBATCH --partition work

# Script to in silico bisulfite convert and then index the reference assembly ----

SPECIES=$(basename $PWD)

# Move to scratch
cd /scratch/pawsey0159/abud

# Specify vairables
GENOME_DIR=$SPECIES/genome

# Load software
module load singularity/4.1.0

# Run bismark genome preparation (default is for bowtie2)
singularity exec /software/projects/pawsey0159/setonix/TrEnD_containers/bismark_0.24.2--hdfd78af_0.sif bismark_genome_preparation $GENOME_DIR

echo "Job complete"

# End script
