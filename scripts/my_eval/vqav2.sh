#!/bin/bash

gpu_list="${CUDA_VISIBLE_DEVICES:-0}"
IFS=',' read -ra GPULIST <<< "$gpu_list"

CHUNKS=${#GPULIST[@]}

MODEL_PATH=${1:-"./checkpoints/llava-v1.5-7b-lora"}
MODEL_BASE=${2:-$(python3 -c "import json; print(json.load(open('$MODEL_PATH/config.json'))['_name_or_path'])")}

CKPT=$(basename $MODEL_PATH)
SPLIT="llava_vqav2_mscoco_test-dev2015"  # "llava_vqav2_mscoco_test-dev2015" or "llava_vqav2_mscoco_test2015"

for IDX in $(seq 0 $((CHUNKS-1))); do
    CUDA_VISIBLE_DEVICES=${GPULIST[$IDX]} python -m llava.eval.model_vqa_loader \
        --model-path $MODEL_PATH \
        --model-base $MODEL_BASE \
        --use-flash-attn \
        --question-file ./playground/data/eval/vqav2/$SPLIT.jsonl \
        --image-folder ./playground/data/eval/vqav2/test2015 \
        --answers-file ./playground/data/eval/vqav2/answers/$SPLIT/$CKPT/${CHUNKS}_${IDX}.jsonl \
        --num-chunks $CHUNKS \
        --chunk-idx $IDX \
        --temperature 0 \
        --conv-mode vicuna_v1 &
done

wait

output_file=./playground/data/eval/vqav2/answers/$SPLIT/$CKPT/merge.jsonl

# Clear out the output file if it exists.
> "$output_file"

# Loop through the indices and concatenate each file.
for IDX in $(seq 0 $((CHUNKS-1))); do
    cat ./playground/data/eval/vqav2/answers/$SPLIT/$CKPT/${CHUNKS}_${IDX}.jsonl >> "$output_file"
done

python scripts/convert_vqav2_for_submission.py --split $SPLIT --ckpt $CKPT

