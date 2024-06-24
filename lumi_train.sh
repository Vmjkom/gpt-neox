#!/bin/bash
#SBATCH --job-name=test_neox_125M_FA_BF16
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=7
#SBATCH --mem=480G
#SBATCH --partition=dev-g
#SBATCH --time=01:00:00
#SBATCH --gpus-per-node=8
#SBATCH --account=project_462000558
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

# symlink logs/latest.out and logs/latest.err
ln -f -s $SLURM_JOB_NAME-$SLURM_JOB_ID.out logs/latest.out
ln -f -s $SLURM_JOB_NAME-$SLURM_JOB_ID.err logs/latest.err

module purge
module load LUMI/23.09
module load PyTorch/2.2.2-rocm-5.6.1-python-3.10-singularity-20240404

#export MASTER_ADDR=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | head -n 1)
#export MASTER_PORT=9999
export TRANSFORMERS_CACHE=$HF_HOME

#DEBUGGING
export SINGULARITYENV_HIP_LAUNCH_BLOCKING=1
export SINGULARITYENV_HSA_FORCE_FINE_GRAIN_PCIE=1
#export SINGULARITYENV_NCCL_DEBUG=INFO
#export SINGULARITYENV_NCCL_DEBUG_SUBSYS=INIT,COLL
export SINGULARITYENV_TORCH_DISTRIBUTED_DEBUG=DETAIL
export SINGULARITYENV_TRANSFORMERS_NO_ADVISORY_WARNINGS=1
export SINGULARITYENV_TRANSFORMERS_VERBOSITY=error
export SINGULARITYENV_CC=gcc-10
export SINGULARITYENV_CXX=g++-10
export SINGULARITYENV_PYTHONWARNINGS=ignore
export SINGULARITYENV_LANGUAGE="en_US.UTF-8" #Perl complains if these are not set
export SINGULARITYENV_LC_ALL="en_US.UTF-8"


CONFIG="configs/ville/125M"

# create hostfile
rm hostfiles/*
HOSTFILE="hostfiles/$SLURM_JOB_ID.txt"
mkdir -p $(dirname "$HOSTFILE")
scontrol show hostnames "$SLURM_JOB_NODELIST" | while read n; do
    echo "$n slots=8" >> "$HOSTFILE"
done
c=fe
MYMASKS="0x${c}000000000000,0x${c}00000000000000,0x${c}0000,0x${c}000000,0x${c},0x${c}00,0x${c}00000000,0x${c}0000000000"

echo "START: $(date)"
echo "NNODES: $((SLURM_NNODES))"
echo "CPUS-PER-TASK: $((SLURM_CPUS_PER_TASK))"


srun --cpu-bind=mask_cpu:$MYMASKS --label singularity exec $SIFPYTORCH \
    conda-python-distributed run.py \
    train.py $CONFIG \
    --hostfile $HOSTFILE

echo "END: $(date)"
