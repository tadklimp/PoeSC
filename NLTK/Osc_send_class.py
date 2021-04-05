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
        self.collect_sylls = []  

    def main():
        if Osc_send.target is None:
            # setup OSC connection to sclang (57120)
            try:
                Osc_send.target = liblo.Address(57120)
            except liblo.AddressError as err:
                print(err)
                sys.exit()
        print("Osc connection established")


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
                self.collect_sylls.append(s.token)
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
        liblo.send(self.target,liblo.Bundle( self.syllab_length, self.syllab_stress, self.syllab_weight, self.syllab_text)) 

    # for each new Stanza send an OSC trigger msg and pass the num of phrases
    @staticmethod
    def new_stanza_trigger(size):
        liblo.send(Osc_send.target,"/stanza/trigger",size)
        print("you have ", size, " phrases")

    # in case Stanza starts with "//" inform that it should be played by Ppar
    @staticmethod
    def playback_mode(mode):
        if mode == "par":
            liblo.send(Osc_send.target,"/stanza/mode","par")
        elif mode == "seq":
            liblo.send(Osc_send.target,"/stanza/mode","seq")
        print("the mode is: ", mode)

    
    if __name__ == "__main__":
        main()
