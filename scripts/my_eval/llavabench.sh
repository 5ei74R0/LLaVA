#!/bin/bash

MODEL_PATH=${1:-"./checkpoints/llava-v1.5-7b-lora"}
MODEL_BASE=${2:-$(python3 -c "import json; print(json.load(open('$MODEL_PATH/config.json'))['_name_or_path'])")}
CKPT=$(basename $MODEL_PATH)

python -m llava.eval.model_vqa \
    --model-path $MODEL_PATH \
    --model-base $MODEL_BASE \
    --use-flash-attn \
    --question-file ./playground/data/eval/llava-bench-in-the-wild/questions.jsonl \
    --image-folder ./playground/data/eval/llava-bench-in-the-wild/images \
    --answers-file ./playground/data/eval/llava-bench-in-the-wild/answers/$CKPT.jsonl \
    --temperature 0 \
    --conv-mode vicuna_v1

mkdir -p playground/data/eval/llava-bench-in-the-wild/reviews

python llava/eval/eval_gpt_review_bench.py \
    --question playground/data/eval/llava-bench-in-the-wild/questions.jsonl \
    --context playground/data/eval/llava-bench-in-the-wild/context.jsonl \
    --rule llava/eval/table/rule.json \
    --answer-list \
        playground/data/eval/llava-bench-in-the-wild/answers_gpt4.jsonl \
        playground/data/eval/llava-bench-in-the-wild/answers/$CKPT.jsonl \
    --output \
        playground/data/eval/llava-bench-in-the-wild/reviews/$CKPT.jsonl

python llava/eval/summarize_gpt_review.py -f playground/data/eval/llava-bench-in-the-wild/reviews/$CKPT.jsonl
