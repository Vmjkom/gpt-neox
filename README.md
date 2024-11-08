# Lumi documentation
This is a fork spesific to the HPC [`Lumi`](https://docs.lumi-supercomputer.eu/). 
## UPDATES
* 8.11.2024 - On the current version of the upstream repo there is an issue with LLAMA and in perticular the mlp layer, which leads to faulty layer weights. [`An issue has been made for this`](https://github.com/EleutherAI/gpt-neox/issues/1319). For now the default branch was changed to "revert". This branch goes back to an earlier commit before llama mlp changes.

## Module
All of the dependencies are available in the module PyTorch/2.2.2-rocm-5.6.1-python-3.10-singularity-20240404
The easybuild config is from https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/p/PyTorch/PyTorch-2.2.2-rocm-5.6.1-python-3.10-singularity-20240617/
The missing dependencies from [`requirements.txt`](./requirements/lumi_requirements.txt) we're pip installed into the venv inside the module.
The module is located in `/projappl/project_462000353/Easybuild`, so to get access run: 
```
module --force purge #Lumi module cannot be loaded when changing the EBU_USER_PREFIX enviroment variable
export EBU_USER_PREFIX=/projappl/project_462000353/Easybuild #Wont work without export
module load LUMI/23.09 #CrayEnv also works here
module load PyTorch/2.2.2-rocm-5.6.1-python-3.10-singularity-20240617
```

## Prepare data

To download and prepare the enwiki8 dataset, with the default GPT2Tokenizer
```
module --force purge #This must be done before chaning EBU_USER_PREFIX
export EBU_USER_PREFIX=/projappl/project_462000353/Easybuild #Get access to the correct module
python prepare_data.py -d ./data 
```

To see more examples see [`Datasets`](#datasets)

## Launching a job
You can launch a run simply with ```sbatch lumi_train.sh```. Module loading is handled inside the `lumi_train.sh` script.
For debugging/testing it might be wiser to first get an salloc and iteratively run `lumi_train.sh` through that. There is an ease of use script for salloc [`interactive.sh`](./interactive.sh) (params) NNODES TIME JOB_NAME. For example, to get a 1 node allocation with 1 hour runtime you do this:
```
./interactive.sh 1 01:00:00 test-neox
```
and then:
```
./lumi_train.sh
```
Read through the rest of gpt-neox's official README to get a better idea configure your own jobs.
### NOTE

There was trouble using `deepy.py` with any of the supported launchers on Lumi, so instead of the `deepy.py` we use `run.py`
