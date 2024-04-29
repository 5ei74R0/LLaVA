#!/bin/bash
#$ -l rt_AF=1 (A100x8)
#$ -l h_rt=5:00:00 (3.5h/A100x8に1.5hのバッファ)
#$ -j y
#$ -l USE_SSH=1
#$ -v SSH_PORT=2299
#$ -cwd

TRANSFORMERS_CACHE=$(pwd)/hub
WANDB_KEY=$1

source /etc/profile.d/modules.sh
module load singularitypro
singularity run --compat --nv -B $(pwd):/src -B $TRANSFORMERS_CACHE:/hub llava.sif WANDB_API_KEY=$WANDB_KEY sh scripts/v1_5/pretrain_7B.sh
