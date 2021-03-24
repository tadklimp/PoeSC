# source code mostly from here:
# https://stackoverflow.com/questions/28575082/classify-a-noun-into-abstract-or-concrete-using-nltk-or-similar
# https://towardsdatascience.com/large-objects-in-python-classes-165a6f98d840

# from flask import Flask, Response, request
import spacy
from spacy_syllables import SpacySyllables
from sklearn.linear_model import LogisticRegression
import numpy as np

# added Spacy Syllables
# syllables = SpacySyllables(nlp)
# nlp.add_pipe('syllables', after='tagger')
# print("Pipeline:", nlp.pipe_names)

class Nlp:
    
    model = None
    adj_classifier = None
    adj_classes = ['colour', 'size', 'opinion', 'quantity', 'texture', 'age', 'weight']
    adj_train_set = [
        ['red', 'blue', 'white', 'purple', 'green', 'yellow', 'black', 'turquoise', 'magenta', 'pink'],
        ['big', 'small', 'large', 'huge', 'tiny', 'extensive', 'miniscule', 'long', 'short'] ,
        ['beautiful', 'ugly', 'real', 'true', 'false', 'perfect', 'interesting', 'good', 'bad', 'costly', 'dangerous', 'tricky', 'disgusting', 'tasty', 'smelly', 'cheap', 'boring', 'easy', 'difficult', 'annoying', 'soothing', 'relaxing', 'sleepy', 'shocking', 'surprising', 'expected', 'unacceptable'],
        ['many', 'lot', 'much', 'few', 'none', 'all', 'some', 'two', 'ten', 'hundred', 'thousands', 'million', 'thousand'],
        ['woolen', 'metallic', 'wooden', 'solid', 'soft', 'hard', 'grainy', 'brittle', 'smooth' ],
        ['new', 'old', 'ancient', 'future', 'past', 'current', 'long time', 'short time', 'sudden', 'immediate', 'youthful'],
        ['heavy', 'light', 'hefty', 'weighty', 'overweight', 'massive' ]
    ]

    def __init__(self, text):
        self.text = text

    def main():
        # """ Load Spacy model and keep it in memory """
        if Nlp.model is None:
            Nlp.model = spacy.load("en_core_web_md")
            print(f"Loaded: { Nlp.model } ")
            # g = Nlp.classify_adjectives()
        print("Calculating ... ")
        return Nlp.model


    def classify_adjectives(self):
        if Nlp.adj_classifier is None:
            X = np.stack([list(self.model(w))[0].vector for part in self.adj_train_set for w in part])
            y = [label for label, part in enumerate(self.adj_train_set) for _ in part]
            Nlp.adj_classifier = LogisticRegression(C=0.1, class_weight='balanced', solver='lbfgs', multi_class='auto').fit(X, y)
        print("Classified ...." )    
        return self.adj_classifier


    # collect all [adjective, category] in an array
    def collect_adjectives(self, separator):
        # nlp_text = nlp(text)
        collection = []
        for token in self.model(self.text):
            if token.pos_ == 'ADJ':
                collection.append(token)
                collection.append(self.adj_classes[self.adj_classifier.predict([token.vector])[0]])
                collection.append(separator)
        print(collection)
        # print(self.model, self.text)
        return collection

    def get_adjectives(self, separator):
        self.separator = separator
        self.classify_adjectives()
        self.collect_adjectives(self.separator)





if __name__ == '__main__':
    main()
    # text_raw = """a short text proportional proportional attitude."""

    # text_raw = Nlp("a beautiful big tree was holding many mangos from its turquoise leaves")
    # text_raw.get_adjectives("---")
    # text_raw = "a beautiful big tree was holding many mangos from its turquoise leaves"
    # text_raw = nlp("some of them will hold a brown book, which i find pedantic in its miniscule content. She asked for a white t-shirt, that was bleached into colourful smelly arrogance. Then the thick sharp edge of the knife glimmed onto her face, bursts into unexpected pie of gooey substance, that stood there with a sudden thump")




