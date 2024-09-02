#!/bin/bash
#SBATCH --job-name=preprocess_data
#SBATCH --nodes=1
#SBATCH --mem=400G #Maximum amount of memory in the mahti gpu nodes
#SBATCH --cpus-per-task=64
#SBATCH --partition=interactive
#SBATCH --time=06:00:00
#SBATCH --begin:now+1hour
#SBATCH --account=project_2010225

module load pytorch
source /projappl/project_2010225/villekom/gpt-neox/.venv/bin/activate

python3 /projappl/project_2010225/villekom/gpt-neox/tools/datasets/preprocess_data.py \
    --input /scratch/project_2010225/data/fineweb-edu/fineweb_edu_10BT.jsonl \
    --tokenizer-type HFGPT2Tokenizer \
    --vocab-file 