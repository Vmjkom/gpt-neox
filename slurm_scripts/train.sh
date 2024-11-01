#!/bin/bash
#SBATCH --job-name=neox_1.8B_europa
#SBATCH --nodes=32
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=7
#SBATCH --mem=480G
#SBATCH --exclusive
#SBATCH --partition=standard-g
#SBATCH --time=02-00:00:00
#SBATCH --gpus-per-node=8
#SBATCH --account=project_462000353
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

# symlink logs/latest.out and logs/latest.err
ln -f -s $SLURM_JOB_NAME-$SLURM_JOB_ID.out logs/latest.out
ln -f -s $SLURM_JOB_NAME-$SLURM_JOB_ID.err logs/latest.err

module --force purge
export EBU_USER_PREFIX=/projappl/project_462000353/Easybuild
module load LUMI/23.09
module load PyTorch/2.2.2-rocm-5.6.1-python-3.10-singularity-20240617


export TRANSFORMERS_CACHE=$HF_HOME

#DEBUGGING
export SINGULARITYENV_HIP_LAUNCH_BLOCKING=1
export SINGULARITYENV_HSA_FORCE_FINE_GRAIN_PCIE=1
#export SINGULARITYENV_NCCL_DEBUG=INFO
#export SINGULARITYENV_NCCL_DEBUG_SUBSYS=INIT,COLL
export SINGULARITYENV_TORCH_DISTRIBUTED_DEBUG=DETAIL
export SINGULARITYENV_TRANSFORMERS_NO_ADVISORY_WARNINGS=1
export SINGULARITYENV_TRANSFORMERS_VERBOSITY=error

#Compilers for data builders
export SINGULARITYENV_CC=gcc-10
export SINGULARITYENV_CXX=g++-10

#Reduce verbosity in logs
export SINGULARITYENV_PYTHONWARNINGS=ignore
export SINGULARITYENV_LANGUAGE="en_US.UTF-8" #Perl complains if these are not set
export SINGULARITYENV_LC_ALL="en_US.UTF-8"


CONFIG="configs/ville/125M.yml"

echo "CONF" $CONFIG

# create hostfile
HOSTFILE="hostfiles/$SLURM_JOB_ID.txt"
mkdir -p $(dirname "$HOSTFILE")
scontrol show hostnames "$SLURM_JOB_NODELIST" | while read n; do
    echo "$n slots=8" >> "$HOSTFILE"
done

#CPU Bindings
c=fe
MYMASKS="0x${c}000000000000,0x${c}00000000000000,0x${c}0000,0x${c}000000,0x${c},0x${c}00,0x${c}00000000,0x${c}0000000000"

echo "START: $(date)"
echo "NNODES: $((SLURM_NNODES))"
echo "CPUS-PER-TASK: $((SLURM_CPUS_PER_TASK))"


srun --cpu-bind=mask_cpu:$MYMASKS --label singularity exec $SIFPYTORCH \
    conda-python-distributed run.py \
    train.py $CONFIG \
    --hostfile $HOSTFILE

rm hostfiles/*
echo "END: $(date)"