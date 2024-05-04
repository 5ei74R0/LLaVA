#!/bin/bash

MODEL_PATH=${1:-"./checkpoints/llava-v1.5-7b-lora"}
MODEL_BASE=${2:-$(python3 -c "import json; print(json.load(open('$MODEL_PATH/config.json'))['_name_or_path'])")}
CKPT=$(basename $MODEL_PATH)

python -m llava.eval.model_vqa_science \
    --model-path $MODEL_PATH \
    --model-base $MODEL_BASE \
    --use-flash-attn \
    --question-file ./playground/data/eval/scienceqa/llava_test_CQM-A.json \
    --image-folder ./playground/data/eval/scienceqa/images/test \
    --answers-file ./playground/data/eval/scienceqa/answers/$CKPT.jsonl \
    --single-pred-prompt \
    --temperature 0 \
    --conv-mode vicuna_v1

python llava/eval/eval_science_qa.py \
    --base-dir ./playground/data/eval/scienceqa \
    --result-file ./playground/data/eval/scienceqa/answers/$CKPT.jsonl \
    --output-file ./playground/data/eval/scienceqa/answers/$CKPT_output.jsonl \
    --output-result ./playground/data/eval/scienceqa/answers/$CKPT_result.json
