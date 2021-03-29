# sources:
# https://stackoverflow.com/questions/20865010/how-do-i-create-an-input-box-with-python
# https://realpython.com/python-gui-tkinter/

from teach_spacy_adj_Class import Nlp
import tkinter as tk
# import prosodic
from Osc_send_class import Osc_send
from time import sleep

Nlp.main()
Osc_send.main()

# n = Nlp(None)
# n.load()
# n.main()


window = tk.Tk()
# e = tk.Entry(window)
e = tk.Text(window, bg="black", fg="white", undo="true")
e.pack()

e.focus_set()

def callback():
    txt = Nlp(e.get("1.0", tk.END))
    txt.get_adjectives("// ")
    txt.split_sentences()
    for i in txt.split_sentences():
        # prosodic_text = prosodic.Text(i)
        o = Osc_send()
        o.attach_labels(i)
        o.meter_to_sclang()
        print(i)
        # sleep(1)


b = tk.Button(window, text = "OK", width = 10, command = callback)
b.pack()

window.mainloop()