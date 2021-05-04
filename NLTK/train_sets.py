
# Adjectives Train Sets
adj_classes = ['colour', 'size', 'opinion', 'quantity', 'texture', 'age', 'weight', 'state', 'shape']
adj_train_set = [
    ['red', 'blue', 'white', 'purple', 'green', 'yellow', 'black', 'turquoise', 'magenta', 'pink'],
    ['big', 'small', 'large', 'huge', 'tiny', 'extensive', 'miniscule', 'long', 'short'] ,
    ['beautiful', 'ugly', 'real', 'true', 'false', 'perfect', 'interesting', 'good', 'bad', 'costly', 'dangerous', 'tricky', 'disgusting', 'tasty', 'smelly', 'cheap', 'boring', 'easy', 'difficult', 'annoying', 'soothing', 'relaxing', 'shocking', 'surprising', 'expected', 'unacceptable'],
    ['many', 'lot', 'much', 'few', 'none', 'all', 'some', 'two', 'ten', 'hundred', 'thousands', 'million', 'thousand'],
    ['woolen', 'metallic', 'wooden', 'solid', 'soft', 'hard', 'grainy', 'brittle', 'smooth' ],
    ['new', 'old', 'ancient', 'future', 'past', 'current', 'long time', 'short time', 'sudden', 'immediate', 'youthful'],
    ['heavy', 'light', 'hefty', 'weighty', 'overweight', 'massive' ],
    ['mad', 'sane', 'happy', 'sad', 'furious', 'naked', 'dressed', 'undisguised', 'invisible', 'visible', 'annoyed', 'relaxed', 'sleepy'],
    ['triangle', 'square', 'sawtooth', 'curved', 'bended', 'linear', 'exponential']
]

# letter score. Sum score of each syllable defines syllable's pitch.
# inspired from letter-frequency analysis of more than 97,000 distinct words
# source: http://norvig.com/mayzner.html
# https://en.wikipedia.org/wiki/Letter_frequency

letter_dict = {
    'e': 0, 't': 1, 'a': 2, 'o': 3, 'i': 4, 'n': 5, 's': 6, 'r': 7,
    'h': 8, 'l': 9, 'd': 10, 'c': 11, 'u': 12, 'm': 13, 'f': 14, 'p': 15,
    'g': 16, 'w': 17, 'y': 18, 'b': 19, 'v': 20, 'k': 21, 'x': 22, 
    'j': 23, 'q': 24, 'z': 25
}

def calculate_score(syllable):
    score = 0
    for i in syllable:
        score = score + letter_dict[i.lower()]
    return score


