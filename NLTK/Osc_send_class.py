import os
import prosodic
import spacy
import liblo, sys
from split_sent import split_into_sentences



class Osc_send:

    target = None
    syllab_length = None
    syllab_stress = None
    syllab_weight = None
    syllab_text = None
    phrase_adjectives = None
    collect_sylls = None

    def __init__(self):
        # create the OSC_messages (empty placeholders)
        self.syllab_length = liblo.Message("/syllab/length")
        self.syllab_stress = liblo.Message("/syllab/stress")
        self.syllab_weight = liblo.Message("/syllab/weight")
        self.syllab_text = liblo.Message("/syllab/text")
        self.phrase_adjectives = liblo.Message("/phrase/adj")
        # if collect_sylls is None:
            # collect_sylls = []  

    def main():
        if Osc_send.target is None:
            # setup OSC connection to sclang (57120)
            try:
                Osc_send.target = liblo.Address(57120)
            except liblo.AddressError as err:
                print(err)
                sys.exit()
        print("Osc connection established")

    # nlp = spacy.load("en_core_web_md")

    # collect all syllables in a list


    # receive text and extract meter with prosodic
    def extract_meter(text):
        # sents_splits = split_into_sentences(text)
        # sents_splits = ["beehwk aries, I didn't know it was planned.", 'Suddenly the earth sacked its ditches']
        for s in sents_splits:
            prosodic_text = prosodic.Text(s)
            # print(s.strip().replace("\n", " "))
            prosodic_labels(prosodic_text)
            # insert_break()


    # prosodic analysis func :
    # detect [syllable_length, syllable_stress, syllable_weight] 
    # add them to the OSC_messages
    def attach_labels(self, text):
        prosodic_text = prosodic.Text(text)
        for w in prosodic_text.words():
            self.syllab_length.add(len(w.syllables()))
            self.syllab_stress.add(w.getStress())
            self.syllab_weight.add(w.weight)
            for s in w.syllables():
                # self.collect_sylls.append(s.token)
                self.syllab_text.add(s.token)

    # a simple way to define a sentence-end:
    # insert the "Rest(0)" string at the end of each sentence (in the OSC_message)
    def insert_break():
        identifier = "Rest(0)"
        osc_sylab_length.add(identifier )
        osc_sylab_stress.add(identifier )
        osc_sylab_weight.add(identifier )



    # put it all together and send to Supercollider-sclang
    def meter_to_sclang(self):
        # extract_meter(text)
        # print(collect_sylls)
        # adjectives_to_osc(text)
        liblo.send(self.target,liblo.Bundle( self.syllab_length, self.syllab_stress, self.syllab_weight, self.syllab_text)) 



    # a simple test
    if __name__ == "__main__":
        # os.chdir("/Users/Makis/Desktop/Musikfonds 2020_21-Research/PoeSC_alpha Python/NLTK")
        main()
        ############ Raw Text ######################
        # text_raw = """and then as I thought the old thought of likenesses,
        # These you presented to me you fish-shaped island,
        # As I wended the shores I know,
        # As I walk'd with that electric self seeking types."""

        # text_raw = """a beautiful big tree was holding many mangos from its turquoise leaves."""
        # text_raw = """white, your white pupil thrives cry your cries anomalies"""
        # text_raw = """white, your white pupil thrives. cry; your cries anomalies."""
        # text_raw = """beehwk aries, I didn't know it was planned. Suddenly the earth sacked its ditches."""
        # text_raw = """a short text proportional proportional attitude bazerkadu."""
        # text_raw = """a bridge above phonetics attitude abbreviation addition. """
        # text_raw = """maybe you think too much, 
        # maybe you run
        # i hope you are real
        # or?"""

        # text_raw = """jibberish bulka danihou, ablonezon parelna sylala."""
        # text_raw = """ka manakalalaka."""
        
        # extract meter 
        # meter_to_sclang(text_raw)
        # print(prosodic.Sentence(text_raw))
