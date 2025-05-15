#!/bin/bash

SERVICE_NAME="whisperx"
USER_NAME="$USER"
WORK_DIR="/home/$USER/workspaces/whisperx_script"
SCRIPT_PATH="$WORK_DIR/service_script/run_app.sh"
SYSTEMD_PATH="/etc/systemd/system/$SERVICE_NAME.service"

# 確保執行檔有執行權限
chmod +x "$SCRIPT_PATH"

echo "🛠️ 建立 systemd 服務檔 $SYSTEMD_PATH ..."
sudo tee "$SYSTEMD_PATH" > /dev/null <<EOF
[Unit]
Description=WhisperX WebUI (Conda App)
After=network.target

[Service]
Type=simple
User=$USER_NAME
WorkingDirectory=$WORK_DIR
ExecStart=$SCRIPT_PATH
Restart=always
Environment=HOME=/home/$USER_NAME
Environment=HF_TOKEN=$HF_TOKEN

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 重新加載 systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "✅ 啟用並啟動 $SERVICE_NAME 服務..."
sudo systemctl enable $SERVICE_NAME
sudo systemctl restart $SERVICE_NAME

echo "📋 服務狀態："
sudo systemctl status $SERVICE_NAME --no-pager
