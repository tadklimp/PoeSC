
# Introduction

PoeSC is a compositional and live-coding interface that uses plain text as a coding grammar to generate musical phrases. Currently english is supported. 
It is developed with [Python](https://www.python.org/) and [Supercollider](https://supercollider.github.io/).  
After text is input via Python, [NLP analysis](https://en.wikipedia.org/wiki/Natural_language_processing) is performed and data is sent to SuperCollider via [OSC](https://en.wikipedia.org/wiki/Open_Sound_Control) where it is mapped and transformed into sound.  
It is a "slow-coding" experience and most of the text-sound isomorphisms are product of my arbitrary/subjective taste. 
Simply put, the user enters textual structures which are metrically, grammatically and arbitrarily transformed into sound.   
The development of this project was possible through the support of the [Musikfonds "Neustart Kultur" Stipendienprogramm 2020/2021](https://www.musikfonds.de/wp-content/uploads/2020/07/MF-Stipendienprogramm_Ausschreibung_200713.pdf) scholarship.

# Background 

PoeSC started as an attempt to create complex musical meso-structures through live coding.
In my practice up to the beginning of the project, the software I would use for live coding (Tidal, SuperCollider) would effect my output towards repetitive structures. It is typical in these environments that the performer triggers a process that loops until a next one is triggered. I was interested in developing a method of generating a varied rhythmical narrative that could evolve easily into complex sonic constructions that would span numerous seconds. I wanted to create long evolving gestures that could slowly transform through code. 



# Current Status : Under development
## in Python:
* Basic core and communication between Python and Supercollider is established, using [pyliblo3](https://pypi.org/project/pyliblo3/)
* Metrical analysis of text is fully developed, solely based on the python library [prosodic](https://github.com/quadrismegistus/prosodic)
* NLP analysis ( using [spacy](https://github.com/explosion/spaCy) ) is at a primary stage: 
    * Sentence-splitting established 
    * Punctuation detected and mapped
    * Adjectives detected and mapped
    * Each letter is assigned a score, based on [Letter Frequncy analysis](https://en.wikipedia.org/wiki/Letter_frequency)
* Basic GUI for text input using [tkinter](https://en.wikipedia.org/wiki/Tkinter)
## in SuperCollider:
* Stanza dictionary & player established
* Phrase dictionary & player established
* Completed OSC receivers and corresponding Controllers:
    * Stanza trigger 
    * Stanza score
    * Stanza mode 
    * Syllable length
    * Syllable weight
    * Syllable stress 
    * Syllable text
    * Syllable score
    * Phrase punctuation
    * Phrase Adjectives

# TO DO

# Structure

# Curent Rules

# Dependencies

# How to use

# Disclaimer

This is currently a documentation repository of my personal compositional process.  
Please feel free to fork, analyse and develop further. With that said, at the moment this interface is not meant as a release.
