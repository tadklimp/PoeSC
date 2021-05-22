## Zusammenfassung des Vorhabens (1.000 Zeichen)
- ( Summary of the Project )

During the 6 months of my research I had the opportunity to develop a software interface for live-coding music, which I currently call PoeSC.
Plain text (in english) is used as the coding grammar;  it is analyzed metrically, syntactically and arbitrarily and the data out of this analysis control musical and sonic parameters. 
The goal of this project is to investigate the possibility of creating musical meso-structures/gestures of varied rhythmical character while typing text in "natural language".
My main speculation here was that it is more impulsive to write plain text while performing, than to use a typical programming language.
Thus, constructing textual metrical structures that they are somehow reflected in sound.
For the implementation, 2 programming languages are used, Python and Supercollider; they communicate through the OSC protocol. 
The first language is analyzing the text (metrically & grammatically) and then transmits the data to the latter which transforms it into sound.
Currently, the project has its core constructed and undergoes further development.


## Gab es Änderungen gegenüber dem Antrag? (1.000 Zeichen)  
- ( Where there changes in regard to your application? )

In its essence, the research goal remained the same. 
The need for rhythmical variety and meso-structural development (i.e. musical phrases) in live-coded music was the driving force. 
What changed was the direction of the investigation.
At first, I proposed to look into the combination of midi controllers and live-coding, based on my previous experiments of storing "chunks of code" into physical midi buttons. This, I assumed, would allow me to combine complex programming processes while performing between text and midi controller. In practice, after the first month of development, this approach was pushing me into using the controller as a placeholder of pre-composed material and was turning the performance in an unvaried combinatorial process. I was turning away from the textual interaction, by focusing intensively on the physical midi controller. 
I needed to re-evaluate my approach since I felt that I was not exploring the potentialities that live coding puts forward, e.g. complex structural transformations by text input. 
Therefore, I decided to stay in the textual medium and investigate what is it that I'm missing from my current method of performing/composing in real time.


## Welche Ziele wollten Sie mit dem Stipendium erreichen? (500 Zeichen)
- ( Which goals did you want to achieve through the Scholarship? )

In my practice up to the beginning of the scholarship, the software I would use for live coding (Tidal, SuperCollider) would effect my output towards repetitive structures. It is typical in these environments that the performer triggers a process that loops until a next one is triggered. I was interested in developing a method of generating a varied rhythmical narrative that could evolve easily into complex sonic constructions that would span numerous seconds. I wanted to create long evolving gestures that could slowly transform through code. 


## Wie war die Umsetzung des Vorhabens? (1.000 Zeichen)
- ( How did the Project evolve? )  

As soon as I focused on the aspect of rhythmical variety as one of my main concerns, I started researching how programming languages work in a basic/abstract level. I sensed that this would help me understand the problem better and help me describe the tools I was looking for. My interest in languages in general led me into researching Formal Grammars. Out of this effort, a paper from Curtis Roads, "Composing Grammars" (1978) turned out to be very influential, as it described in a systematic way a "structural/linguistic" model of developing a composing ecosystem. In parallel, I discovered the current work of Allison Parrish in computational poetry and the use of programming languages in creating poems. This fusion of perspectives unveiled to me the main pivotal point of this project. I realized that common speech/text include in their metrical structures the variation of rhythm and meter that I was looking for. I decided, that I should try to create a program where I can input text, extract its metrical qualities and transform them into rhythmical information. That was the only isomorphism between text and sound I was interested to retain. I was not interested in a "proper" sonification of language. Rather, as it turned out, in the creation of a quirky eso-lang.

