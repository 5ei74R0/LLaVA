#!/bin/bash
#$ -l rt_AF=1
#$ -l h_rt=11:00:00
#$ -j y
#$ -l USE_SSH=1
#$ -v SSH_PORT=2299
#$ -cwd

TRANSFORMERS_CACHE=$(pwd)/hub
WANDB_KEY=<insert-api-key>  # Insert your Weights & Biases API key here ...

source /etc/profile.d/modules.sh
module load singularitypro
singularity run --compat --nv -B $(pwd):/src -B $TRANSFORMERS_CACHE:/hub --env WANDB_API_KEY=$WANDB_KEY llava.sif sh scripts/v1_5/finetune_7B.sh
