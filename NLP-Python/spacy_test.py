# source : https://gist.github.com/aparrish/4a5f4f2dd313ca37d37dacade7c8ac84
import spacy   
import random
import numpy as np
from numpy import dot
from numpy.linalg import norm
from collections import Counter


# simple print function to separate print areas
def print_space(text):
    print(' ')
    print(text)
    print("================")

######## simple investigations ########
#######################################

# words = open("whitman-leaves.txt").read().split()
# word_count = Counter(words)

# for word in random.sample(words, 25):
    # print(word)

# print( word_count["autumn"])


# for word, number in word_count.most_common(20):
    # print(word, number)


############## spacy ##################
#######################################

nlp = spacy.load('en_core_web_md')
text = open("whitman-leaves.txt").read()
doc = nlp(text)


sentences = list(doc.sents)
words = [w for w in list(doc) if w.is_alpha]
noun_chunks = list(doc.noun_chunks)
entities = list(doc.ents)

# 5 random sentences
print_space("5 random sentences")
for item in random.sample(sentences, 5):
    print(item.text.strip().replace("\n", " "))
    print("---")

# 10 random chunks
print_space("10 random chunks")
for item in random.sample(noun_chunks, 10):
    print(item.text)


# 10 random entities
print_space("10 random entities")
for item in random.sample(noun_chunks, 10):
    print(item.text)



######## Parts of Speech #############
######################################

nouns = [w for w in words if w.pos_ == "NOUN"]
verbs = [w for w in words if w.pos_ == "VERB"]
adjs = [w for w in words if w.pos_ == "ADJ"]
advs = [w for w in words if w.pos_ == "ADV"]

# 10 random partsOfSpeech
print_space("10 random partsOfSpeech")
for item in random.sample(adjs, 10): # change "nouns" to "verbs" or "adjs" or "advs" to sample from those lists!
    print(item.text)



######## Entity Types ###############
#####################################

people = [e for e in entities if e.label_ == "PERSON"]
locations = [e for e in entities if e.label_ == "LOC"]
times = [e for e in entities if e.label_ == "TIME"]

print_space("20 random Entity Types")
for item in random.sample(locations, 20): 
    print(item.text.strip())



########################################
######### WORD VECTORS #################
########################################

# cosine similarity
# cosine() returns a measure of "distance" between two vectors.
def cosine(v1, v2):
    if norm(v1) > 0 and norm(v2) > 0:
        return dot(v1, v2) / (norm(v1) * norm(v2))
    else:
        return 0.0

# a set of only the unique words of the whole text (and lowered)
unique_words = list(set([w.text.lower() for w in words]))


# returns the words with the highest cosine similarity from the source text
def similar_words(word_to_check, source_set):
    return sorted(source_set,
                  key=lambda x: cosine(nlp.vocab[word_to_check].vector, nlp.vocab[x].vector),
                  reverse=True)


print_space("Similar Words")
print(similar_words("butterfly",unique_words)[:10])


#######################################
######### SENTENCE VECTORS ############
#######################################

# takes a spaCy-parsed sentence and returns the averaged vector of the words in the sentence.
def sentence_vector(sent):
    vec = np.array([w.vector for w in sent if w.has_vector and np.any(w.vector)])
    if len(vec) > 0:
        return np.mean(vec, axis=0)
    else:
        raise ValueError("no words with vectors found")   

# takes an arbitrary string as a parameter and returns the sentences in our text closest in meaning (using the list of sentences assigned to the sentences variable further up)    
def similar_sentences(input_str, num=10):
    input_vector = sentence_vector(nlp(input_str))
    return sorted(sentences,
                  key=lambda x: cosine(np.mean([w.vector for w in x], axis=0), input_vector),
                  reverse=True)[:num]



print_space("Similar Sentences")
sentence_to_check = "Trees of light, I wondered in my youth; will I ever see you?"
# sentence_to_check = "It ain't no use to sit and wonder why babe, if you don't know by now."
# sentence_to_check = "a cold heart, with ears burning. My eyes are sore."
for item in similar_sentences(sentence_to_check):
    print(item.text.strip())
    print("")

