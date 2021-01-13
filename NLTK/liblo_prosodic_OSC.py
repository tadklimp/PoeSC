import os
import prosodic
import liblo, sys
from split_sent import split_into_sentences

# setup OSC connection to sclang (57120)
try:
    target = liblo.Address(57120)
except liblo.AddressError as err:
    print(err)
    sys.exit()


# create the OSC_messages (empty placeholders)
osc_sylab_length = liblo.Message("/sylab/length")
osc_sylab_stress = liblo.Message("/sylab/stress")
osc_sylab_weight = liblo.Message("/sylab/weight")

# receive text and extract meter with prosodic
def extract_meter(text):
    sents_splits = split_into_sentences(text)
    for s in sents_splits:
        prosodic_text = prosodic.Text(s)
        # print(s.strip().replace("\n", " "))
        prosodic_labels(prosodic_text)
        insert_break()


# prosodic analysis func => 
# detect [syllable_length, syllable_stress, syllable_weight] 
# add them to the OSC_messages
def prosodic_labels(text):
    for w in text.words():
        osc_sylab_length.add(len(w.syllables()))
        osc_sylab_stress.add(w.getStress())
        osc_sylab_weight.add(w.weight)

# a simple way to define a sentence-end
# insert the "break" string at the end of each sentence (in the OSC_message)
def insert_break():
        osc_sylab_length.add("Rest(1)")
        osc_sylab_stress.add("Rest(1)")
        osc_sylab_weight.add("Rest(1)")



# put it all together and send to Supercollider-sclang
def meter_to_sclang(text):
    extract_meter(text)
    liblo.send(target,liblo.Bundle(osc_sylab_length, osc_sylab_stress, osc_sylab_weight)) 





# a simple test
if __name__ == "__main__":
    os.chdir("/Users/Makis/Desktop/Musikfonds 2020_21-Research/PoeSC_alpha Python/NLTK")

    ############ Raw Text ######################
    # text_raw = """and then as I thought the old thought of likenesses,
    # These you presented to me you fish shaped island,
    # As I wended the shores I know,
    # As I walk'd with that electric self seeking types."""
    text_raw = """maybe you think too much, 
    maybe you run
    i hope you are reall
    or?"""

    # extract meter 
    meter_to_sclang(text_raw)
