# source code mostly from here:
# https://stackoverflow.com/questions/28575082/classify-a-noun-into-abstract-or-concrete-using-nltk-or-similar
# https://towardsdatascience.com/large-objects-in-python-classes-165a6f98d840
# https://www.youtube.com/watch?v=WbEKxcsO66U check this for splitting new lines ??


import spacy
from spacy.language import Language
# from spacy.symbols import ORTH
from spacy_syllables import SpacySyllables
from sklearn.linear_model import LogisticRegression
import train_sets
import numpy as np

# added Spacy Syllables
# syllables = SpacySyllables(nlp)
# nlp.add_pipe('syllables', after='tagger')
# print("Pipeline:", nlp.pipe_names)

class Nlp:
    """ Initialize Spacy and keep it in Memory as a reference. 
    This way the model doesn't have to be loaded repeatedly. 
    Initialize Adjective Classifier. Probably this has to be moved in a separate Class. """
    
    model = None
    adj_classifier = None
    adj_classes = train_sets.adj_classes
    adj_train_set = train_sets.adj_train_set

    def __init__(self, text):
        self.text = text

    def main():
        """ Load Spacy model and Classifiers. Keep them in memory """

        if Nlp.model is None:
            Nlp.model = spacy.load("en_core_web_lg")
            # special_case = [{ORTH: "\n"}]
            # Nlp.model.tokenizer.add_special_case("\n", special_case)
            Nlp.model.add_pipe("line_splitter", before="parser")
            Nlp.model.add_pipe('sentencizer')
            print(f"Loaded: { Nlp.model } ")
            print(Nlp.model.pipe_names)
        print("Ready ... ")

        # classify Adjectives according to given Table 
        if Nlp.adj_classifier is None:
            X = np.stack([list(Nlp.model(word))[0].vector for part in Nlp.adj_train_set for word in part] )
            y = [label for label, part in enumerate(Nlp.adj_train_set) for _ in part]
            Nlp.adj_classifier = LogisticRegression(C=0.1, class_weight='balanced', solver='lbfgs', multi_class='auto').fit(X, y)
        print("Classified ..." )    

    # define a custom Spacy pipeline, splitting lines at \n
    # more info here: https://spacy.io/usage/processing-pipelines#factories-decorator-component
    @Language.factory('line_splitter')
    def new_line_splitter(nlp, name):
        def line_component(doc):
            for i, token in enumerate(doc[:-1]):
                if token.text == "\n":
                    doc[i+1].is_sent_start = True
            return doc
        return line_component


    def split_sentences(self):
        """Split incoming text into sentences"""
        sentences = [str(sent).strip() for sent in self.model(self.text).sents]
        # set default playback mode to "seq"
        mode = "seq"
        # if sentence is empty, clear it 
        for i, sent in enumerate(sentences):
            if len(sent) == 0:
                del sentences[i]
        # if Stanza starts with '//' it denotes parallel playback of sentences/phrases
        if sentences[0][0] == "/" and sentences[0][1] == "/": 
            mode = "par"
            del sentences[0]
        print([mode, sentences])
        return [mode,sentences]


    # depricated 
    # def classify_adjectives(self):
    #     """ classify Adjectives according to given Table  """
    #     if Nlp.adj_classifier is None:
    #         X = np.stack([list(self.model(word))[0].vector for part in self.adj_train_set for word in part] )
    #         y = [label for label, part in enumerate(self.adj_train_set) for _ in part]
    #         Nlp.adj_classifier = LogisticRegression(C=0.1, class_weight='balanced', solver='lbfgs', multi_class='auto').fit(X, y)
    #     print("Classified ...." )    
    #     return self.adj_classifier
    @staticmethod
    def get_adjectives(text):
        """ collect all [adjective, category, separator] in an array. 
        Seperator expects a String, useful in Sclang to separate sentences """
        collection = []
        for token in Nlp.model(text):
            if token.pos_ == 'ADJ':
                # collection.append(token)
                collection.append(Nlp.adj_classes[Nlp.adj_classifier.predict([token.vector])[0]])
                # collection.append(separator)
        print(collection)
        # print(self.model, self.text)
        return collection






if __name__ == '__main__':
    main()



