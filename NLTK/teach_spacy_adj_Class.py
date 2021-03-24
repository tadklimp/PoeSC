# source code mostly from here:
# https://stackoverflow.com/questions/28575082/classify-a-noun-into-abstract-or-concrete-using-nltk-or-similar
# https://towardsdatascience.com/large-objects-in-python-classes-165a6f98d840
# https://www.youtube.com/watch?v=WbEKxcsO66U check this for splitting new lines ??


import spacy
from spacy_syllables import SpacySyllables
from sklearn.linear_model import LogisticRegression
from train_sets import adj_classes, adj_train_set
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


    def __init__(self, text):
        self.text = text
        self.adj_classes = adj_classes
        self.adj_train_set = adj_train_set

    def main():
        """ Load Spacy model and keep it in memory """
        if Nlp.model is None:
            Nlp.model = spacy.load("en_core_web_lg")
            # Nlp.model.add_pipe('line_splitter',before='parser')
            Nlp.model.add_pipe('sentencizer')
            print(f"Loaded: { Nlp.model } ")
            # g = Nlp.classify_adjectives()
        print("Ready ... ")
        return Nlp.model

    # @Language.factory('line_splitter')
    def new_line_split(self, doc):
        """ consider new lines as Sentence boundaries """
        for token in doc[:-1]:
            if token.text == "\n":
                doc[token.i+1].is_sent_start = True
        return doc

    def split_sentences(self):
        """Split incoming text into sentences"""
        result = [str(sent).strip() for sent in self.model(self.text).sents]
        print(result)
        return result

    def classify_adjectives(self):
        """ classify Adjectives according to given Table  """
        if Nlp.adj_classifier is None:
            X = np.stack([list(self.model(word))[0].vector for part in self.adj_train_set for word in part] )
            y = [label for label, part in enumerate(self.adj_train_set) for _ in part]
            Nlp.adj_classifier = LogisticRegression(C=0.1, class_weight='balanced', solver='lbfgs', multi_class='auto').fit(X, y)
        print("Classified ...." )    
        return self.adj_classifier

    def get_adjectives(self, separator):
        """ collect all [adjective, category, separator] in an array. 
        Seperator expects a String, useful in Sclang to separate sentences """
        collection = []
        self.classify_adjectives()
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




