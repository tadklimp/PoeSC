## Zusammenfassung des Vorhabens (1.000 Zeichen)
- ( Summary of the Project )

During the 6 months of my research I developed a software interface for live-coding music which I currently call PoeSC.
Plain text (in english) is used as the coding grammar;  it is analyzed metrically, syntactically and arbitrarily and the data out of this analysis control musical and sonic parameters. 
The goal of this project is to investigate the possibility of creating musical structures/gestures of varied rhythmical character while typing text in "natural language".
In other words: to create textual/metrical structures that they are somehow reflected in sound.
My main speculation here was that it is more impulsive to write plain text while performing, than to use a typical programming language.
For the implementation, 2 programming languages are used, Python and Supercollider; they communicate through the OSC protocol. 
The first language is analyzing the text (metrically & grammatically) and transmits the data to the latter which transforms it into sound.
Currently, the project has its core constructed and undergoes further development.


## Gab es Änderungen gegenüber dem Antrag? (1.000 Zeichen)  
- ( Where there changes in regard to your application? )

In its essence the research goal remained the same. 
The need for rhythmical variety and meso-structural development (i.e. musical phrases) in live-coded music was the driving force. 
What changed was the direction of the investigation.
At first, I proposed to look into the combination of midi controllers and live-coding, based on my previous experiments of storing "chunks of code" into physical midi buttons. This, I assumed, would allow me to combine complex programming processes while performing between text and a physical controller. In practice, after the first month of development, I was gradually using the controller as a placeholder of pre-composed material and the performance was evolving into an unvaried combinatorial process. I was turning away from the textual interaction, by focusing intensively on the physical midi controller. 
I needed to re-evaluate my approach since I felt that I was not exploring the potential that live-coding opens up, e.g. complex structural transformations by text input. 
Therefore, I decided to stay in the textual medium and investigate what is it that I'm missing from my current method of performing/composing while coding in real time.


## Welche Ziele wollten Sie mit dem Stipendium erreichen? (500 Zeichen)
- ( Which goals did you want to achieve through the Scholarship? )

In my practice up to the beginning of the scholarship, the software I would use for live coding (Tidal, SuperCollider) would effect my output towards repetitive structures. It is typical in these environments that the performer triggers a process that loops until a next one is triggered. I was interested in developing a method of generating a varied rhythmical narrative that could evolve easily into complex sonic constructions that would span numerous seconds. I wanted to create long evolving gestures that could slowly transform through code. 


## Wie war die Umsetzung des Vorhabens? (1.000 Zeichen)
- ( How did the Project evolve? )  

As soon as I focused on the aspect of rhythmical variety as one of my main concerns, I started researching how programming languages work in a basic/abstract level. I sensed that this investigation would help me clarify the problem programmatically and help me describe the tools I was looking for. My interest in languages in general led me into researching Formal Grammars. Out of this effort, Curtis Roads' paper "Composing Grammars" (1978) turned out to be very influential, as it presented in a systematic way a "structural/linguistic" model of developing a composing ecosystem. In parallel, I discovered the current work of Allison Parrish in computational poetry and the use of programming languages in creating poems. This fusion of perspectives revealed the main pivotal point of the project. I realized that common speech/text includes in its metrical structures a variation of rhythm and meter that I was looking for. I decided, that I should try to create a program where I can input arbitrary text, extract its metrical qualities and transform them into rhythmical information. That was the only isomorphism between text and sound I was mainly interested to retain. I was not interested in a "total" sonification of text. But rather, as it turned out, in the creation of a quirky esolang.

## Wie war der Arbeitsprozess? (1.000 Zeichen)
- ( What was the working process? )

I spent November 2020 developing the originally proposed idea of a "midi_controller and code" integration. As soon as I hit an impasse I started researching into the fields of programming, linguistics and phonology. This process lasted about 1.5 months, until mid-January 2021, where a clear concept of the current project started to form. Meanwhile, I was going through my archive of past musical programming work (12 years) and made a selection of rough sketches that could be developed further for this project. From mid-January until now I have been developing the project. This included:
- learning a new programming language (Python) 
- researching software design patterns (I finally used the Model-View-Controller paradigm) 
- researching prosodic and metrical theory
- creating new synthesis and fx engines for the production of sound
- designing a mapping system between parameters of text and sound
- designing a model of musical phrase development that is based on the Talea/Color model of Isorhythmic Motets.  
- debugging the software code

## Gab es Impulse für Ihre künstlerische Arbeit durch das Stipendium? (1.000 Zeichen)
- ( Did the scholarship give you impetus for your artistic work? )

Yes, in a very substantial way. First, I found the time to learn a new programming language (Python), which already has a large impact on the artistic constructions I can assemble. Then, it allowed me the time for a sober reflection on performative and composing problems that I faced, which meant: time to experiment and having the capacity to fail, re-evaluate and adapt my methodologies. Furthermore, I had time to research prosody, poetry, linguistics, Ars Nova techniques of composition, Esoteric programming languages (esolangs), Natural Language Processing, sound classification software and in general to get in touch with the current state of research in the field of music informatics. Last, through my endeavors in linguistics I discovered the work of Deleuze & Guattari which is becoming a great source of inspiration. In general I can say that I have become diagram.   


## Wurde eine Reflektion der künstlerischen Arbeit ermöglicht? (1.000 Zeichen)
- ( Was a reflection on the artistic process possible? )

The scholarship gave me time to methodically reflect on my compositional and research process. One of the most profound methodological developments I achieved during the last months is a more concrete way to approach short and medium-term artistic goals. The regular (almost daily) documentation of my process led to a substantial observation of my methods and allowed me a more "to the point" response in times of creative blockage. A 2-week routine/review of intermediate goals and focal points of action is a pattern I will preserve and one that helped me tremendously once I adopted. Furthermore, I borrowed techniques on problem-solving from the field of software programming which had a major impact on my work. Specifically, I repeatedly used flowcharts to decode my processes, the software I built and in general for the analysis of complex processes.


## Gab es schon Aufführungen? (1.000 Zeichen)
- ( Have there been performances yet? ) 

Due to the current pandemic restrictions, a live performance has not been yet been possible, but I hope it will soon be. Nevertheless, the software as of date and all the source-code material is available online for anyone to freely access through LINK. I support the open-source sharing of code, software and research in general, as this I believe is fundamental to our nourishment and formation as community; it has already had a huge impact on my education and artistic development and I consider myself part of this millieu. The project is still under development and will continue to be for the following months as more and more elements are refined. That repository will continue to be updated. 