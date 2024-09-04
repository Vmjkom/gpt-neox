#!/bin/bash
#SBATCH --job-name=1.82B_fineweb-edu_test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem=200G #Maximum amount of memory in the mahti gpu nodes
#SBATCH --cpus-per-task=4
#SBATCH --partition=gputest
#SBATCH --time=00:15:00
#SBATCH --gpus-per-node=v100:4
#SBATCH --account=project_2010225
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err
#set -xe
# symlink logs/latest.out and logs/latest.err
ln -f -s $SLURM_JOB_NAME-$SLURM_JOB_ID.out logs/latest.out
ln -f -s $SLURM_JOB_NAME-$SLURM_JOB_ID.err logs/latest.err

module purge
module load pytorch

DIR=/projappl/project_2010225/villekom/gpt-neox
source /projappl/project_2010225/villekom/gpt-neox/.venv/bin/activate
export PYTHONPATH=$DIR/.venv/lib/python3.9/site-packages
CONFIG=/projappl/project_2010225/villekom/gpt-neox/configs/ablations/1_82B_1N.yml
echo "CONFIG" $CONFIG
echo "NNODES" $SLURM_NNODES

#Debugging
#export TORCH_DISTRIBUTED_DEBUG=INFO
#export NCCL_DEBUG=INFO
#export CUDA_LAUNCH_BLOCKING=1

#Logging
export TRANSFORMERS_NO_ADVISORY_WARNINGS=1
export PYTHONWARNINGS=ignore

# create hostfile
rm hostfiles/*
HOSTFILE="hostfiles/$SLURM_JOB_ID.txt"
mkdir -p $(dirname "$HOSTFILE")
scontrol show hostnames "$SLURM_JOB_NODELIST" | while read n; do
    echo "$n slots=4" >> "$HOSTFILE"
done

echo "START: $(date)"
#echo $PATH
srun --label --export=ALL $DIR/slurm_scripts/mahti_launch.sh $DIR/run.py $DIR/train.py "$CONFIG" --hostfile "$HOSTFILE"

echo "END: $(date)"