# source : https://musicinformationretrieval.com/onset_segmentation.html
import librosa, librosa.display
import numpy, scipy, matplotlib.pyplot as plt
import os

# set the correct directory
os.chdir("/Users/Makis/Desktop/Musikfonds 2020_21-Research/Python OSC")

file_name = 'fm1.wav'

x, sr = librosa.load('audio/'+ file_name)
# print(x, sr)

hop_length =512
onset_frames = librosa.onset.onset_detect(x, sr=sr, hop_length=hop_length, backtrack=True)
# print (onset_frames) # frame numbers of estimated onsets

onset_times = librosa.frames_to_time(onset_frames, sr=sr, hop_length=hop_length)
# print (onset_times)

onset_samples = librosa.frames_to_samples(onset_frames, hop_length=hop_length)
# print (onset_samples)

file_dur = librosa.get_duration(x)
print(file_dur)

# for index, i in enumerate(onset_samples):
#     print(i, index)


def concatenate_segments(x, onset_samples, pad_duration=0.500):
    """Concatenate segments into one signal, adding silence in between."""
    silence = numpy.zeros(int(pad_duration*sr)) # silence
    frame_sz = numpy.diff(onset_samples) #calculate framesize between onsets
    collection = numpy.zeros(int(1)) #create a placeholder array
    for index, i in enumerate(onset_samples):
        if index == (onset_samples.size)-1: #set the duration of last onset to zero
            collection = numpy.concatenate([collection, numpy.zeros(1)])
        else: # add each onset & its duration + silence to the placeholder array
            conc = numpy.concatenate([x[i:i+frame_sz[index]], silence ])
            collection = numpy.concatenate([collection, conc])
    return collection




# write file to disk
def write_file(source,sr,path ):
    librosa.output.write_wav(path, source, sr)

cut_smpl = concatenate_segments(x,onset_samples, 2)

print(cut_smpl)
write_file(cut_smpl, sr, 'audio/fm1_cut.wav')
