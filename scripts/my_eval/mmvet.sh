#!/bin/bash

MODEL_PATH=${1:-"./checkpoints/llava-v1.5-7b-lora"}
MODEL_BASE=${2:-$(python3 -c "import json; print(json.load(open('$MODEL_PATH/config.json'))['_name_or_path'])")}
CKPT=$(basename $MODEL_PATH)

python -m llava.eval.model_vqa \
    --model-path $MODEL_PATH \
    --model-base $MODEL_BASE \
    --use-flash-attn \
    --question-file ./playground/data/eval/mm-vet/llava-mm-vet.jsonl \
    --image-folder ./playground/data/eval/mm-vet/images \
    --answers-file ./playground/data/eval/mm-vet/answers/$CKPT.jsonl \
    --temperature 0 \
    --conv-mode vicuna_v1

mkdir -p ./playground/data/eval/mm-vet/results

python scripts/convert_mmvet_for_eval.py \
    --src ./playground/data/eval/mm-vet/answers/$CKPT.jsonl \
    --dst ./playground/data/eval/mm-vet/results/$CKPT.json

