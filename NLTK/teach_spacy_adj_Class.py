# source code mostly from here:
# https://stackoverflow.com/questions/28575082/classify-a-noun-into-abstract-or-concrete-using-nltk-or-similar
# https://towardsdatascience.com/large-objects-in-python-classes-165a6f98d840
# https://www.youtube.com/watch?v=WbEKxcsO66U check this for splitting new lines ??


import spacy
from spacy.language import Language
from spacy.symbols import ORTH
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
        # self.text = text.replace("\n"," \n ")
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
    # info here: https://spacy.io/usage/processing-pipelines#factories-decorator-component
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
        result = [str(sent).strip() for sent in self.model(self.text).sents]
        for i in result:
            print(i)
            print("--")
        return result

    # depricated 
    # def classify_adjectives(self):
    #     """ classify Adjectives according to given Table  """
    #     if Nlp.adj_classifier is None:
    #         X = np.stack([list(self.model(word))[0].vector for part in self.adj_train_set for word in part] )
    #         y = [label for label, part in enumerate(self.adj_train_set) for _ in part]
    #         Nlp.adj_classifier = LogisticRegression(C=0.1, class_weight='balanced', solver='lbfgs', multi_class='auto').fit(X, y)
    #     print("Classified ...." )    
    #     return self.adj_classifier

    def get_adjectives(self, separator):
        """ collect all [adjective, category, separator] in an array. 
        Seperator expects a String, useful in Sclang to separate sentences """
        collection = []
        for token in self.model(self.text):
            if token.pos_ == 'ADJ':
                collection.append(token)
                collection.append(self.adj_classes[self.adj_classifier.predict([token.vector])[0]])
                collection.append(separator)
        print(collection)
        # print(self.model, self.text)
        return collection






if __name__ == '__main__':
    main()
    # print(adj_train_set)
    # text_raw = """a short text proportional proportional attitude."""

    # text_raw = Nlp("a beautiful big tree was holding many mangos from its turquoise leaves")
    # text_raw.get_adjectives("---")
    # text_raw = "a beautiful big tree was holding many mangos from its turquoise leaves"
    # text_raw = nlp("some of them will hold a brown book, which i find pedantic in its miniscule content. She asked for a white t-shirt, that was bleached into colourful smelly arrogance. Then the thick sharp edge of the knife glimmed onto her face, bursts into unexpected pie of gooey substance, that stood there with a sudden thump")



