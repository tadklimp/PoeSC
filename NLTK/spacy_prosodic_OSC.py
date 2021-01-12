import os
import spacy
import prosodic
import numpy as np
import random
import pycollider
import config
from numpy import dot
from numpy.linalg import norm
from collections import Counter



os.chdir("/Users/Makis/Desktop/Musikfonds 2020_21-Research/PoeSC_alpha Python/NLTK")

############ Raw Text ######################
text_raw = '''and then as I thought the old thought of likenesses,
These you presented to me you fish shaped island,
As I wended the shores I know,
As I walk'd with that electric self seeking types.
'''

# prosodic_doc = prosodic.Text(text_raw)

###### load spaCy #########
nlp = spacy.load('en_core_web_md')
spacy_doc = nlp(text_raw)

# separate sentences in spacy
sentences = list(spacy_doc.sents)


# prosodic analysis func => 
# analyse input and return a list of [syllable_length, syllable_stress, syllable_weight] 
def extract_meter(text):
  new_list = []
  for w in text.words():
    new_list.append([len(w.syllables()), w.getStress(),w.weight])
  return new_list


# sentence from spacy to prosodic
def sentence_to_prosodic(sentences_list):
    for s in sentences_list:
        prosodic_sent = prosodic.Text(s.text.strip())
        # print(s.text.strip().replace("\n", " "))
        print(extract_meter(prosodic_sent))


# extract meter and send to Supercollider



meter =  sentence_to_prosodic(sentences)

pycollider.connect()
pycollider.sendMsg(meter)