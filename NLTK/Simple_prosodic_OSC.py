import os
import spacy
import prosodic
import numpy as np
import random
import pycollider
from numpy import dot
from numpy.linalg import norm
from collections import Counter
from split_sent import split_into_sentences
import liblo, sys

# setup OSC to sclang (57120)
try:
    target = liblo.Address(57120)
except liblo.AddressError as err:
    print(err)
    sys.exit()

os.chdir("/Users/Makis/Desktop/Musikfonds 2020_21-Research/PoeSC_alpha Python/NLTK")

############ Raw Text ######################
text_raw = """and then as I thought the old thought of likenesses,
These you presented to me you fish shaped island,
As I wended the shores I know,
As I walk'd with that electric self seeking types."""

# prosodic_doc = prosodic.Text(text_raw)

###### load spaCy #########
# nlp = spacy.load('en_core_web_md')
# spacy_doc = nlp(text_raw)

# separate sentences in spacy
# sentences = list(spacy_doc.sents)

# sents_splits = split_into_sentences("what a terrible descise! gett ogg me!")

# pycollider.connect()

osc_msg = liblo.Message("/msg")

# receive spacy sentences_list and extract meter with prosodic
def extract_meter(text):
    sents_splits = split_into_sentences(text)
    for s in sents_splits:
        prosodic_text = prosodic.Text(s)
        # print(s.text.strip().replace("\n", " "))
        prosodic_labels(prosodic_text)
        #   pycollider.sendMsg(meter)
        # print(meter)
  # return meter


# prosodic analysis func => 
# analyse input and return a list of [syllable_length, syllable_stress, syllable_weight] 
def prosodic_labels(text):
    new_list = []
    for w in text.words():
        osc_msg.add(len(w.syllables()))
        # osc_msg.add(w.getStress())
        # osc_msg.add(w.weight)
        # new_list.extend([ w.getStress()])
        # yield new_list
    # return new_list

# extract meter and send to Supercollider
meter = extract_meter(text_raw)

liblo.send(target, osc_msg) 
# print(meter)


