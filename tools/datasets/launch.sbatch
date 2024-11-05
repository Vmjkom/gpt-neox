#!/bin/bash
#SBATCH -A project_462000444
#SBATCH -J fw-tokenize-neox
#SBATCH -p small
#SBATCH -c 2
#SBATCH -n 64
#SBATCH --mem=300G
#SBATCH -t 12:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err


module purge
export EBU_USER_PREFIX=/projappl/project_462000353/Easybuild
module load LUMI/23.09
module load PyTorch/2.2.2-rocm-5.6.1-python-3.10-singularity-20240617
#339M in fw-edu
FW_EDU=339000000
#519M in fw
FW=519000000
#Number of documents for every chunk
NUM_DOCS=$((FW_EDU/SLURM_NTASKS))
export DIR=/projappl/project_462000353/villekom/gpt-neox/tools/datasets/
export NUM_THREADS=$SLURM_CPUS_PER_TASK
echo "Starting job"
srun -l singularity exec $SIF $DIR/multinode_prepare_data.sh $DIR/file_paths.txt \
    --num-docs $NUM_DOCS \
    --tokenizer-type GPT2BPETokenizer \
    --vocab-file /scratch/project_462000353/tokenizers/gpt2/vocab.json \
    --merge-file /scratch/project_462000353/tokenizers/gpt2/merges.txt \
    --output-prefix /scratch/project_462000353/data/fineweb-edu/350BT/tokenized/ \
    --dataset-impl mmap \
    --workers $SLURM_CPUS_PER_TASK \
    --log-interval 1000 \
echo "Finished job:" $SLURM_JOB_ID