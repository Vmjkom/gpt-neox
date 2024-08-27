#!/bin/bash
salloc -A project_2010225 \
    -p $4 \
    --ntasks-per-node=4 \
    --gpus-per-node=a100:4 \
    --cpus-per-task=32 \
    --mem=470G \
    --exclusive \
    --bell \
    -t $2 \
    -N $1 \
    -J $3 \