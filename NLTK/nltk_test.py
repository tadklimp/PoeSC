# source: https://www.youtube.com/watch?v=w36-U-ccajM

import pycollider
from nltk.tokenize import sent_tokenize, word_tokenize
from nltk.corpus import stopwords

# example_text = "Hello mr.Kones, how are 4you doing today? The weather is great and Python is awesome."
example_text = "my love of you, has stayed the same"

stop_words = set(stopwords.words("english"))

words = word_tokenize(example_text)

filtered = []
stops = []

for i in words:
    if i not in stop_words:
        filtered.append(i)
    else:
       stops.append(i)

#print(stops)
print(filtered)

pycollider.connect()
pycollider.sendMsg(stops)
# pycollider.sendMsg(filtered)