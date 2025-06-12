#!/bin/bash

echo "🚀 啟動 WhisperX WebUI..."

# 初始化 Conda 環境
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/anaconda3/etc/profile.d/conda.sh"
else
    echo "❌ 找不到 conda.sh，請確認是否已安裝 Conda。"
    exit 1
fi

source ~/.bashrc

# 切換到目錄並啟動
cd "$(dirname "$0")/.."

# 啟動應用
conda activate whisperx
python app.py --port 7866
