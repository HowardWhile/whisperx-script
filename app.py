import gradio as gr
import subprocess
import os
import shutil
import uuid
import zipfile
import argparse

def transcribe(video_file, language):
    job_id = str(uuid.uuid4())

    # 建立工作目錄：./log/{job_id}/
    work_dir = os.path.join("log", job_id)
    os.makedirs(work_dir, exist_ok=True)

    # 取得檔案名稱（不含副檔名）
    input_filename = os.path.basename(video_file.name)
    input_name_no_ext = os.path.splitext(input_filename)[0]

    # 建立輸出目錄：{work_dir}/{input_name_no_ext}/
    output_dir = os.path.join(work_dir, input_name_no_ext)
    os.makedirs(output_dir, exist_ok=True)

    # txt文字檔路徑
    txt_path = os.path.join(work_dir, input_name_no_ext, f"{input_name_no_ext}.txt")

    # 複製輸入檔到工作目錄中
    input_path = os.path.join(work_dir, input_filename)
    shutil.copy(video_file.name, input_path)

    # 組合指令
    command = ["./run_whisperx.sh", "--input", input_path, "--output", output_dir]
    command += ["--language", language]

    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        return f"❌ 執行失敗: {e}", None

    # 將 output_dir 壓縮
    zip_path = os.path.join("log", job_id, f"{input_name_no_ext}.zip")
    shutil.make_archive(zip_path.replace(".zip", ""), "zip", output_dir)

    return "✅ 轉錄完成！請下載", zip_path, txt_path

def main():

    parser = argparse.ArgumentParser(description="Run the Gradio STT WebUI")
    parser.add_argument("-p", "--port", type=int, default=7860, help="Server port (default: 7860)")
    parser.add_argument("--show-browser", action="store_true", help="Open browser on launch")
    parser.add_argument("--share", action="store_true", help="Enable public share link")
    args = parser.parse_args()

    # Gradio 介面
    web_ui = gr.Interface(
        fn=transcribe,
        inputs=[
            gr.File(
                label="上傳媒體檔案",
                file_types=[
                    # 視訊
                    ".mp4",
                    ".mov",
                    ".mkv",
                    ".avi",
                    ".flv",
                    ".wmv",
                    ".webm",
                    # 音訊
                    ".mp3",
                    ".wav",
                    ".m4a",
                    ".aac",
                    ".flac",
                    ".ogg",
                    ".opus",
                ],
            ),
            gr.Dropdown(["auto", "zh", "en", "ja"], value="zh", label="語言選擇"),
        ],
        outputs=[
            gr.Text(label="狀態"),
            gr.File(label="下載所有轉錄格式 (.zip)"),
            gr.File(label="下載純文字 (.txt)"),
        ],
        title="AI Speech-to-Text",
        allow_flagging="never",
    )

    web_ui.launch(
        inbrowser=args.show_browser,
        server_port=args.port, 
        server_name="0.0.0.0",
        )
    
    pass


if __name__ == "__main__":    
    main()
    
