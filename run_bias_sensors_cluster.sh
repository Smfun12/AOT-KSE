#!/bin/bash
#SBATCH --job-name=bias_sensors
#SBATCH --output=bias_sensors_%j.out
#SBATCH --error=bias_sensors_%j.err
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G

# Example SLURM script to run bias_sensors_analysis on a cluster
# Modify the resource requirements above as needed for your cluster

# Load MATLAB module (adjust module name for your cluster)
# module load matlab/R2021a  # Example - adjust for your cluster

# Set MATLAB to run without display
export DISPLAY=""

# Run MATLAB script
# Adjust path to MATLAB executable for your cluster
matlab -nodisplay -nosplash -nodesktop -r "cd('$SLURM_SUBMIT_DIR'); bias_sensors_analysis(); exit;"

# Alternative if using MATLAB compiler runtime:
# matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath('.')); bias_sensors_analysis(); exit;"

echo "Job completed. Check output files for results."

