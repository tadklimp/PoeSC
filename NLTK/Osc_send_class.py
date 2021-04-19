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
    punctuation = None
    phrase_adjectives = None

    def __init__(self):
        ''' create the OSC_messages (empty placeholders) '''
        self.syllab_length = liblo.Message("/syllab/length")
        self.syllab_stress = liblo.Message("/syllab/stress")
        self.syllab_weight = liblo.Message("/syllab/weight")
        self.syllab_text = liblo.Message("/syllab/text")
        self.punctuation = liblo.Message("/phrase/punct") 
        self.phrase_adjectives = liblo.Message("/phrase/adj")

    def main():
        ''' setup OSC connection to sclang (57120) '''
        if Osc_send.target is None:
            try:
                Osc_send.target = liblo.Address(57120)
            except liblo.AddressError as err:
                print(err)
                sys.exit()
        print("Osc connection established")


    def prosodic_labels(self, text):
        ''' prosodic analysis func :
        extract [syllable_length, syllable_stress, syllable_weight] and
        add them to the OSC_messages '''
        prosodic_text = prosodic.Text(text)
        # check for punctuation - this is possible through wordtokens()       
        for w in prosodic_text.wordtokens():
            if any([ w.token in """, ; : . .. ... ? ! ( ) [ ] { } < > """ ]):
                self.punctuation.add("{punc}".format(punc = w.token )) 
                self.insert_break()
            # print(w.phonemes(), w.str_ipasyllstress())
            if not w.is_punct:
                word = w.children[0]
                for syl in word.syllables():
                    self.punctuation.add('None')
                    self.syllab_text.add(syl.token)
                # alltogether.append(s.token)
                self.syllab_length.add(len(word.syllables()))
                self.syllab_stress.add(w.stress)
                self.syllab_weight.add(w.weight)

    # def prosodic_labels(self, text):
    #     ''' prosodic analysis func :
    #     extract [syllable_length, syllable_stress, syllable_weight] and
    #     add them to the OSC_messages '''
    #     prosodic_text = prosodic.Text(text)
    #     # check for punctuation - this is possible through wordtokens()       
    #     for w in prosodic_text.words():
    #         # print(prosodic.gleanPunc(w.token))
    #         print(w.token)
    #         if any([ w.token in """, ; : . .. ... ? ! ( ) [ ] { } < > """ ]):
    #             self.punctuation.add("{punc}".format(punc = w.token )) 
    #             # self.insert_break()
    #         self.syllab_length.add(len(w.syllables()))
    #         self.syllab_stress.add(w.getStress())
    #         self.syllab_weight.add(w.weight)
    #         # print(w.phonemes(), w.str_ipasyllstress())
    #         for s in w.sylls_text:
    #             self.punctuation.add('None')
    #             self.syllab_text.add(s)
    #             # alltogether.append(s.token)


    def add_adjectives(self, values):
        ''' receive the Adjectives list and add it to OSC msg '''
        for val in values:
            self.phrase_adjectives.add(val)

    def insert_break(self):
        ''' a simple way to define a sentence-end:
        insert the "Rest(0)" string at the end of each sentence (in the OSC_message) '''
        identifier = "Rest(0)"
        self.syllab_length.add(identifier )
        self.syllab_stress.add(identifier )
        self.syllab_weight.add(identifier )


    # put it all together and send to Supercollider-sclang
    def meter_to_sclang(self):
        liblo.send(self.target,liblo.Bundle( self.syllab_length, self.syllab_stress, self.syllab_weight, self.punctuation, self.syllab_text, self.phrase_adjectives )) 

    @staticmethod
    def new_stanza_trigger(size):
        ''' for each new Stanza send an OSC trigger msg and pass the num of lines '''
        liblo.send(Osc_send.target,"/stanza/trigger",size)
        print("there are ", size, " lines")

    @staticmethod
    def playback_mode(mode):
        ''' in case Stanza starts with "//" inform that it should be played by Ppar '''
        if mode == "par":
            liblo.send(Osc_send.target,"/stanza/mode","par")
        elif mode == "seq":
            liblo.send(Osc_send.target,"/stanza/mode","seq")
        print("the mode is: ", mode)

    
    if __name__ == "__main__":
        main()
