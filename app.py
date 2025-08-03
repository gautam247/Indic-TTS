from flask import Flask, render_template, request, send_file, url_for
import subprocess
import os
import uuid

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/synthesize', methods=['POST'])
def synthesize():
    text = request.form['text']
    speaker = request.form['speaker']
    unique_id = uuid.uuid4().hex[:6]
    output_filename = f"hindi_{speaker}_{unique_id}.wav"
    output_path = os.path.join('static', output_filename)

    command = [
        'tts',
        '--text', text,
        '--model_path', 'models/v1/hi/fastpitch/best_model.pth',
        '--config_path', 'models/v1/hi/fastpitch/config.json',
        '--vocoder_path', 'models/v1/hi/hifigan/best_model.pth',
        '--vocoder_config_path', 'models/v1/hi/hifigan/config.json',
        '--speaker_idx', speaker,
        '--out_path', output_path
    ]

    print("Executing command:", ' '.join(command))

    try:
        subprocess.run(command, check=True)
        return render_template('result.html', audio_file=output_filename)
    except subprocess.CalledProcessError as e:
        print("Error occurred:", e)
        return f"Error occurred: {e}"

if __name__ == '__main__':
    app.run(debug=True)
