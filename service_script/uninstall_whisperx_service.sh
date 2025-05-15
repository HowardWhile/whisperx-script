#!/bin/bash

SERVICE_NAME="whisperx"
SYSTEMD_PATH="/etc/systemd/system/$SERVICE_NAME.service"

echo "🛠️ 停止並停用 $SERVICE_NAME 服務..."
sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME

echo "🧹 刪除 systemd 服務檔案 $SYSTEMD_PATH ..."
sudo rm -f "$SYSTEMD_PATH"

echo "🔄 重新加載 systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "✅ 已卸載 $SERVICE_NAME 服務。"
