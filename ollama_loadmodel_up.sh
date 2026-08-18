#!/bin/bash

OLLAMA_URL="http://127.0.0.1:11434"
KEEP_ALIVE="24h"

MODELS=(
    "gemma4:e2b-it-qat"
    "qwen3.6:35b-a3b-q4_K_M"
    "nemotron-3.5-lightning:30b-a3b-q4_K_M"
)

for MODEL in "${MODELS[@]}"; do
    echo "[+] Loading: $MODEL"

    curl -s "$OLLAMA_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODEL\",
            \"keep_alive\": \"$KEEP_ALIVE\"
        }" \
        > /dev/null

    echo "[OK] $MODEL loaded"
done

echo
echo "===== Ollama Loaded Models ====="

curl -s "$OLLAMA_URL/api/ps"

echo
