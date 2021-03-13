# https://stackoverflow.com/questions/28575082/classify-a-noun-into-abstract-or-concrete-using-nltk-or-similar

import spacy
from spacy_syllables import SpacySyllables
from sklearn.linear_model import LogisticRegression
import numpy as np

# added Spacy Syllables
nlp = spacy.load("en_core_web_md")
# syllables = SpacySyllables(nlp)
# nlp.add_pipe('syllables', after='tagger')

print("Pipeline:", nlp.pipe_names)


# text_raw = nlp("""a short text proportional proportional attitude.""")
text_raw = nlp("a beautiful big tree was holding many mangos from its turquoise leaves")
# text_raw = nlp("some of them will hold a brown book, which i find pedantic in its miniscule content. She asked for a white t-shirt, that was bleached into colourful smelly arrogance. Then the thick sharp edge of the knife glimmed onto her face, bursts into unexpected pie of gooey substance, that stood there with a sudden thump")

adj_classes = ['colour', 'size', 'opinion', 'quantity', 'texture', 'age']
adj_train_set = [
    ['red', 'blue', 'white', 'purple', 'green', 'yellow', 'black', 'turquoise', 'magenta', 'pink'],
    ['big', 'small', 'large', 'huge', 'tiny', 'extensive', 'miniscule', 'long', 'short'] ,
    ['beautiful', 'ugly', 'real', 'true', 'false', 'perfect', 'interesting', 'good', 'bad', 'costly', 'dangerous', 'tricky', 'disgusting', 'tasty', 'smelly', 'cheap', 'boring', 'easy', 'difficult', 'annoying', 'soothing', 'relaxing', 'sleepy', 'shocking', 'surprising', 'expected', 'unacceptable'],
    ['many', 'lot', 'much', 'few', 'none', 'all', 'some', 'two', 'ten', 'hundred', 'thousands', 'million'],
    ['woolen', 'metallic', 'wooden', 'solid', 'soft', 'hard', 'grainy', 'brittle', 'smooth' ],
    ['new', 'old', 'ancient', 'future', 'past', 'current', 'long time', 'short time', 'sudden', 'immediate']
]
X = np.stack([list(nlp(w))[0].vector for part in adj_train_set for w in part])
y = [label for label, part in enumerate(adj_train_set) for _ in part]
classifier = LogisticRegression(C=0.1, class_weight='balanced', solver='lbfgs', multi_class='auto').fit(X, y)



for token in text_raw:
    if token.pos_ == 'ADJ':
        print(token, adj_classes[classifier.predict([token.vector])[0]])
    # print(token._.syllables)