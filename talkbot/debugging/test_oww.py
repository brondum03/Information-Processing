import numpy as np
from scipy.io import wavfile
import sys
from types import ModuleType
sys.modules["onnxruntime"] = ModuleType("onnxruntime")
# make openwakeword think onnxruntime is installed (it doesn't actually need it)
import openwakeword

oww_model_name = "hey_jarvis_v0.1"
openwakeword.utils.download_models([oww_model_name])
oww_model = openwakeword.model.Model(
    wakeword_models=[oww_model_name],
    inference_framework="tflite",
)

def normalized_pcm(sample_rate, audio):
    # crudely downsample to 16kHz
    fs = 16000
    samples = int(np.round(len(audio) * fs / sample_rate))
    fractional_sample_indices = np.arange(samples) * (sample_rate / fs)
    sample_indices = np.clip(np.round(fractional_sample_indices).astype(int), 0, len(audio) - 1)
    audio_data = audio[sample_indices].astype(np.float32)

    # Remove DC offset
    audio_data -= np.mean(audio_data)

    # Compute RMS volume for later
    volume = np.sqrt(np.var(audio_data))

    # Normalize volume. This is being done on each frame separately, rather
    # than slowly evolving a gain on the signal. Could this be an issue for
    # wakeword detection and/or speech-to-text?
    audio_data /= max(1e-7, np.max(np.abs(audio_data)))  # don't divide-by-zero
    audio_data *= 0.99 * np.iinfo(np.int16).max

    # Convert to int16
    return volume, audio_data.astype(np.int16)


def oww_predict(chunk):
    oww_model.predict(chunk)
    return list(oww_model.prediction_buffer.values())[0][-1]


_, jarvis_audio = normalized_pcm(*wavfile.read("jarvis.wav"))

top_p = 0
for audio_frame in np.split(jarvis_audio, np.arange(1280, len(jarvis_audio), 1280)):
    p = oww_predict(audio_frame)
    top_p = max(p, top_p)

print(f"Maximum wakeword detection: {top_p:.2f}")
