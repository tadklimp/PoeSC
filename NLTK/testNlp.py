# sources:
# https://stackoverflow.com/questions/20865010/how-do-i-create-an-input-box-with-python

from teach_spacy_adj_Class import Nlp
import tkinter as tk

Nlp.main()


master = tk.Tk()
e = tk.Entry(master)
e.pack()

e.focus_set()

def callback():
    # print(e.get()) # This is the text you may want to use later
    txt = Nlp(e.get())
    txt.get_adjectives("// ")
    txt.split_sentences()


b = tk.Button(master, text = "OK", width = 10, command = callback)
b.pack()

master.mainloop()