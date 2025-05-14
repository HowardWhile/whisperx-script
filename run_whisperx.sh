#!/bin/bash

# 預設參數
INPUT_FILE=""
OUTPUT_DIR="output"
LANGUAGE="zh"  # 預設語言為中文

# 解析參數
while [[ $# -gt 0 ]]; do
  case $1 in
    -i)
      INPUT_FILE="$2"
      shift 2
      ;;
    -l|--language)
      LANGUAGE="$2"
      shift 2
      ;;
    *)
      echo "❌ 不支援的參數: $1"
      echo "✅ 使用方式：./run_whisperx.sh -i <input_file> [-l en|jp|....|auto]"
      exit 1
      ;;
  esac
done

# 確保輸入檔案存在
if [ -z "$INPUT_FILE" ]; then
  echo "❌ 未指定輸入音訊檔案，請使用 -i 參數"
  echo "  範例： ./run_whisperx.sh -i input.mp3"
  exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ 找不到檔案: $INPUT_FILE"
  exit 1
fi

# 檢查 whisperx 環境是否存在
if ! conda env list | grep -qE '^\s*whisperx\s'; then
  echo "❌ Conda environment 'whisperx' does not exist. Please create it first."
  exit 1
fi

# 啟用 Conda 環境
source ~/anaconda3/etc/profile.d/conda.sh
conda activate whisperx

# 檢查 HF_TOKEN 是否有設定
if [ -z "$HF_TOKEN" ]; then
  echo "❌ Environment variable HF_TOKEN is not set. Please run: export HF_TOKEN=your_token"
  exit 1
fi

# 檢查輸出資料夾是否存在，若無則建立
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "📁 Output directory '$OUTPUT_DIR' does not exist. Creating..."
  mkdir -p "$OUTPUT_DIR"
fi

# 組合 whisperx 指令
CMD=(whisperx "$INPUT_FILE"
  --model large-v2
  --chunk_size 6
  -f all
  --vad_method silero
  --diarize
  --hf_token "$HF_TOKEN"
  --verbose True
  --output_dir "$OUTPUT_DIR"
)

# 若不是 auto，加入語言參數
if [ "$LANGUAGE" != "auto" ]; then
  CMD+=(--language "$LANGUAGE")
  echo "🌐 使用語言：$LANGUAGE"
else
  echo "🌐 語言自動偵測中..."
fi

# 執行 whisperx
echo "🚀 開始處理檔案：$INPUT_FILE"
"${CMD[@]}"
