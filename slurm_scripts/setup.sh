#!/bin/bash
#SBATCH --job-name=setup_neox
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=7
#SBATCH --mem=50G
#SBATCH --partition=dev-g
#SBATCH --time=00:10:00
#SBATCH --gpus-per-node=1
#SBATCH --account=project_462000615
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

#Create a directory for logs
mkdir -p logs

#Setup a python virtual enviroment
#module use /local/csc/appl/modulefiles #TODO Change this
module load pytorch/2.4
python3 -m venv .venv --system-site-packages

source .venv/bin/activate

#Pip install requirements
pip install --upgrade pip
pip install -r requirements/requirements.txt