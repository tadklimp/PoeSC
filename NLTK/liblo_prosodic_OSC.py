import os
import prosodic
import spacy
import liblo, sys
from split_sent import split_into_sentences
from teach_spacy_adj import collect_adjectives
from teach_spacy_adj import load_model

# setup OSC connection to sclang (57120)
try:
    target = liblo.Address(57120)
except liblo.AddressError as err:
    print(err)
    sys.exit()

# nlp = spacy.load("en_core_web_md")

# create the OSC_messages (empty placeholders)
osc_sylab_length = liblo.Message("/sylab/length")
osc_sylab_stress = liblo.Message("/sylab/stress")
osc_sylab_weight = liblo.Message("/sylab/weight")
osc_sylab_text = liblo.Message("/sylab/text")
osc_adjectives = liblo.Message("/sylab/adj")

# collect all syllables in a list
collect_sylls = []

# extract adjectives and add them to osc list
# PROBLEM HERE!
def adjectives_to_osc(text):
    separator = "Rest(0)"
    adjs = collect_adjectives(text, separator)
    print(list(adjs))
    # osc_adjectives.add( adjs )

# receive text and extract meter with prosodic
def extract_meter(text):
    sents_splits = split_into_sentences(text)
    for s in sents_splits:
        prosodic_text = prosodic.Text(s)
        # print(s.strip().replace("\n", " "))
        prosodic_labels(prosodic_text)
        insert_break()
        print(collect_sylls)


# prosodic analysis func :
# detect [syllable_length, syllable_stress, syllable_weight] 
# add them to the OSC_messages
def prosodic_labels(text):
    for w in text.words():
        osc_sylab_length.add(len(w.syllables()))
        osc_sylab_stress.add(w.getStress())
        osc_sylab_weight.add(w.weight)
        for s in w.syllables():
            collect_sylls.append(s.token)
            osc_sylab_text.add(s.token)

# a simple way to define a sentence-end:
# insert the "Rest(0)" string at the end of each sentence (in the OSC_message)
def insert_break():
    identifier = "Rest(0)"
    osc_sylab_length.add(identifier )
    osc_sylab_stress.add(identifier )
    osc_sylab_weight.add(identifier )



# put it all together and send to Supercollider-sclang
def meter_to_sclang(text):
    extract_meter(text)
    adjectives_to_osc(text)
    liblo.send(target,liblo.Bundle(osc_sylab_length, osc_sylab_stress, osc_sylab_weight, osc_sylab_text, osc_adjectives)) 



# a simple test
if __name__ == "__main__":
    os.chdir("/Users/Makis/Desktop/Musikfonds 2020_21-Research/PoeSC_alpha Python/NLTK")

    ############ Raw Text ######################
    # text_raw = """and then as I thought the old thought of likenesses,
    # These you presented to me you fish-shaped island,
    # As I wended the shores I know,
    # As I walk'd with that electric self seeking types."""

    text_raw = """a beautiful big tree was holding many mangos from its turquoise leaves."""
    # text_raw = """a short text proportional proportional attitude bazerkadu."""
    # text_raw = """a bridge above phonetics attitude abbreviation addition. """
    # text_raw = """maybe you think too much, 
    # maybe you run
    # i hope you are real
    # or?"""

    # text_raw = """jibberish bulka danihou, ablonezon parelna sylala."""
    # text_raw = """ka manakalalaka."""
    
    # extract meter 
    meter_to_sclang(text_raw)
    # print(prosodic.Sentence(text_raw))
