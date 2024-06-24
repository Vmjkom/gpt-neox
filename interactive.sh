#!/bin/bash
salloc -A project_462000558 -p dev-g \
    --gpus-per-node=8 \
    --cpus-per-task=7 \
    --mem=480G \
    --exlusive \
    -t $2 \
    -N $1 \
    --job-name=test_neox_LLama2_7B_$1N_PP_1_TP_1_GAS_1_fused \
    -o logs/%x-%j.out \
    -e logs/%x-%j.err