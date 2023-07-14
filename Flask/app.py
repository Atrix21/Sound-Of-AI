import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from flask import Flask,request,jsonify,send_file
import numpy as np
import librosa

import csv
import soundfile as sf
import librosa.display
from PIL import Image
import os
import tensorflow as tf
import scipy.signal as signal

app = Flask(__name__)
audio_classes = {}
with open('/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/py/hs.csv', 'r') as file:
    reader = csv.DictReader(file)
    for row in reader:
        audio_classes[row['File']] = row['Class']

model = tf.keras.models.load_model("/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/models/heart_resnet_spectro.hdf5")
model1 = tf.keras.models.load_model("/Users/atrix/Downloads/urban_sound_model_1")
d1 = {0: 'air_conditioner', 1: 'car_horn', 2: 'children_playing', 3: 'dog_bark', 4: 'drilling', 5: 'engine_idling', 6:'gun_shot', 7: 'jackhammer', 8: 'siren', 9: 'street_music'}
def func(filename):
    audio, sample_rate = librosa.load(filename)
    mfccs_features = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=40)
    mfccs_scaled_features = np.mean(mfccs_features.T,axis=0)
    mfccs_scaled_features=mfccs_scaled_features.reshape(1,-1)
    predicted_label=np.argmax(model1.predict(mfccs_scaled_features),axis=1)
    return d1[predicted_label[0]]

d={0:'Artifact', 1:'Extrasystole', 2:'Murmur', 3:'Normal'}

def plot_graphs(filename):
    plt.figure(figsize=(5, 2))
    data, sample_rate = librosa.load(filename)
    librosa.display.waveshow(data, sr=sample_rate)
    plt.savefig("/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/Testing_plots/plot_fig.png")
    plt.close()
    spectrogram = librosa.feature.melspectrogram(y=data, sr=sample_rate)
    spectrogram_db = librosa.power_to_db(spectrogram, ref=np.max)
    plt.figure(figsize=(3.5,3.5))
    librosa.display.specshow(spectrogram_db, sr=sample_rate,x_axis='time', y_axis='log')
    plt.savefig("/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/Testing_plots/spect_fig.png", transparent=True)
    plt.close()


def delete_files_in_folder(folder_path):
    for file_name in os.listdir(folder_path):
        file_path = os.path.join(folder_path, file_name)
        if os.path.isfile(file_path):
            os.remove(file_path)
            print(f"Deleted file: {file_path}")

def save_spect_testing(data, sr, filename,i):
    # Extract spectrogram
    spectrogram = librosa.feature.melspectrogram(y=data, sr=sr)

    # Convert to decibels
    spectrogram_db = librosa.power_to_db(spectrogram, ref=np.max)

    # Plot spectrogram
    plt.figure(figsize=(1.28,1.28))
    librosa.display.specshow(spectrogram_db, sr=sr)
    plt.savefig(("/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/Testing_spects/{}_{}.png").format(filename,i), transparent=True)
    plt.close()

# Step 1: Denoising using a low pass filter
def apply_low_pass_filter(audio, sampling_rate, cutoff_freq):
    nyquist_freq = 0.5 * sampling_rate
    normalized_cutoff_freq = cutoff_freq / nyquist_freq
    b, a = signal.butter(4, normalized_cutoff_freq, btype='low', analog=False)
    denoised_audio = signal.lfilter(b, a, audio)
    return denoised_audio

# Downsampling audio
def downsample_audio(audio,original_sampling_rate,target_sampling_rate):
    resampled_audio = librosa.resample(audio, orig_sr=original_sampling_rate, target_sr=target_sampling_rate)
    return resampled_audio

# Split audio into fixed-length segments
def split_audio(audio, segment_length):
    num_segments = len(audio) // segment_length
    segments = [audio[i*segment_length:(i+1)*segment_length] for i in range(num_segments)]
    return segments

def pred(audio_path, model,filename):
    m=0
    p=""

    audio, sampling_rate = librosa.load(audio_path, sr=None)

    # Denoising
    cutoff_frequency = 195
    denoised_audio = apply_low_pass_filter(audio, sampling_rate, cutoff_frequency)

    # Downsampling
    target_sampling_rate = sampling_rate // 10
    downsampled_audio = downsample_audio(denoised_audio, sampling_rate, target_sampling_rate)

    # Create a WAV file from downsampled audio
    audio_file_path = "/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/Testing_audio/audio.wav"
    sf.write(audio_file_path, downsampled_audio, target_sampling_rate)

    # Splitting audio
    segment_length = target_sampling_rate * 3
    segments = split_audio(downsampled_audio, segment_length)
    i=0
    
    for segment in segments:
        save_spect_testing(segment,target_sampling_rate,filename,i)

        img=Image.open(("/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/Testing_spects/{}_{}.png").format(filename,i)).convert('RGB')
        img_arr=np.asarray(img)
        img_arr=img_arr/255

        img_arr = img_arr.reshape(1, 128, 128, 3)
        
        prediction = model.predict(img_arr)
        x=np.argmax(prediction)
        confidence = prediction[0, x]
        i=i+1
        classes={0:'Artifact', 1:'Extrasystole', 2:'Murmur', 3:'Normal'}
        if(confidence>m):
            m=confidence
            p=classes[x]
        print(classes[x],confidence)
    return(p)

@app.route('/predict_ub',methods=['POST'])
def predict_ub():
    if 'audio' not in request.files:
        return 'No file provided', 400

    audio_file = request.files['audio']
    if not audio_file.filename.lower().endswith('.wav'):
        return 'Invalid file type, must be .wav', 400
    preditction = func(audio_file)
    print(preditction)
    return preditction

@app.route('/predict',methods=['POST'])
def predict():
    if 'audio' not in request.files:
        return 'No file provided', 400

    audio_file = request.files['audio']
    if not audio_file.filename.lower().endswith('.wav'):
        return 'Invalid file type, must be .wav', 400
    filename = audio_file.filename
    preditction = pred(audio_file, model, "file")
    ground_truth = audio_classes.get(filename)
    delete_files_in_folder("/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/Testing_spects")
    return str(f"{preditction},{ground_truth}")

@app.route('/graphs',methods=['POST'])
def graphs():
    if 'audio' not in request.files:
        return 'No file provided', 400

    audio_file = request.files['audio']
    if not audio_file.filename.lower().endswith('.wav'):
        return 'Invalid file type, must be .wav', 400
    plot_graphs(audio_file)
    return "done"


@app.route('/plot', methods=['GET'])
def serve_plot():
    # Return the image file
    return send_file("/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/Testing_plots/plot_fig.png", mimetype='image/png')

@app.route('/spectrogram', methods=['GET'])
def generate_and_send_spectrogram():
    return send_file("/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/Testing_plots/spect_fig.png", mimetype='image/png')

@app.route('/audio', methods=['GET'])
def serve_audio():
    audio_file_path = "/Users/atrix/Documents/desktop_folders/PS/heartbeat_classification/Testing_audio/audio.wav"
    if os.path.isfile(audio_file_path):
        return send_file(
            audio_file_path,
            mimetype='audio/wav',
            as_attachment=True
        )
    else:
        return "Audio file not found", 404

if __name__ == '__main__':
    app.run(debug=True)

