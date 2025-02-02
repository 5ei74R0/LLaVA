#!/bin/bash

MODEL_PATH=${1:-"./checkpoints/llava-v1.5-7b-lora"}
MODEL_BASE=${2:-$(python3 -c "import json; print(json.load(open('$MODEL_PATH/config.json'))['_name_or_path'])")}
CKPT=$(basename $MODEL_PATH)

if [ ! -f ./playground/data/eval/pope/answers/$CKPT.jsonl ]; then
    touch ./playground/data/eval/pope/answers/$CKPT.jsonl
fi

python -m llava.eval.model_vqa_loader \
    --model-path $MODEL_PATH \
    --model-base $MODEL_BASE \
    --use-flash-attn \
    --question-file ./playground/data/eval/pope/llava_pope_test.jsonl \
    --image-folder ./playground/data/eval/pope/val2014 \
    --answers-file ./playground/data/eval/pope/answers/$CKPT.jsonl \
    --temperature 0 \
    --conv-mode vicuna_v1

python llava/eval/eval_pope.py \
    --annotation-dir ./playground/data/eval/pope/coco \
    --question-file ./playground/data/eval/pope/llava_pope_test.jsonl \
    --result-file ./playground/data/eval/pope/answers/$CKPT.jsonl
