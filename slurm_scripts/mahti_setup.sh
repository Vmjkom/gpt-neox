#!/bin/bash
#SBATCH --job-name=gpt-neox-setup
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=0
#SBATCH --cpus-per-task=12
#SBATCH --partition=test
#SBATCH --time=00:15:00
#SBATCH --account=project_2010225

#Create a directory for logs
mkdir -p logs

#Setup a python virtual enviroment
module purge
module load pytorch
python3 -m venv .venv --system-site-packages

source .venv/bin/activate

#Pip install requirements
pip install --upgrade pip
pip install -r requirements/requirements.txt
pip install -r requirements/requirements-tensorboard.txt
pip install -r requirements/requirements-flashattention.txt