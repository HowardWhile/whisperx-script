import gradio as gr
import subprocess
import os
import shutil
import uuid
import zipfile

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

    return "✅ 轉錄完成！請下載壓縮檔", zip_path

# Gradio 介面
demo = gr.Interface(
    fn=transcribe,
    inputs=[
        gr.File(
            label="上傳媒體檔案",
            file_types=[".mp4", ".mov", ".mkv", ".mp3", ".m4a"]
        ),
        gr.Dropdown(["auto", "en", "jp", "zh", "fr", "de"], value="zh", label="語言選擇"),
    ],
    outputs=[
        gr.Text(label="狀態"),
        gr.File(label="下載轉錄 ZIP")
    ],
    title="WhisperX-WebUI",
    allow_flagging="never"  # 關掉 Flag 按鈕
)

if __name__ == "__main__":
    # demo.launch(share=True)
    demo.launch(inbrowser=True)
