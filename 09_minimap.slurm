#!/bin/bash

#SBATCH --account=pawsey0159
#SBATCH --mail-type=FAIL
#SBATCH --output=%x.%j.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8GB
#SBATCH --time=1:00:00
#SBATCH --partition work

# Move to scratch
cd /scratch/pawsey0159/abud/ophiodonElongatus

# Specify variables
GENOME=genome/GCA_016806645.1_NWFSC_Oelon_r3.mflye_genomic.fna
REF=dataFiles/drerio_mab21l2.fasta
OUT=dataFiles/oelongatus_mab21l2

# Load and list software
module load singularity/4.1.0
module load samtools/1.15--h3843a85_0
module load bedtools/2.30.0--h468198e_3
module list

MINIMAP2="/software/projects/pawsey0159/setonix/TrEnD_containers/minimap2_2.30--h577a1d6_0.sif"

# Unzip genome
gunzip -dk $GENOME.gz

# Run approximate mapping and covert to map
singularity exec "$MINIMAP2" minimap2 -a "$GENOME" "$REF" \
  | samtools view -b \
  | samtools sort -o "${OUT}.bam"

samtools index "${OUT}.bam"

# Convert to ed
bedtools bamtobed -i "${OUT}.bam" > "${OUT}.bed"

# Get fasta
bedtools getfasta -fi "$GENOME" -bed "${OUT}.bed" -fo "${OUT}.fasta"

# Clean up
rm $GENOME
rm $OUT.bam
rm $OUT.bam.bai

## end script
