#!/bin/bash

echo "🚀 啟動 WhisperX WebUI..."

# 初始化 Conda 環境
source ~/anaconda3/etc/profile.d/conda.sh
source ~/.bashrc

# 切換到目錄並啟動
cd "$(dirname "$0")/.."

# 啟動應用
conda activate whisperx
python app.py --port 7866
