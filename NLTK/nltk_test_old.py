# source: https://www.youtube.com/watch?v=w36-U-ccajM

from nltk.tokenize import sent_tokenize, word_tokenize
from nltk.corpus import stopwords
from sc3.all import *

example_text = "Hello mr.Kones, how are 4you doing today? The weather is great and Python is awesome."

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

s.boot()
# s.dump_tree(True)

print(s.addr)