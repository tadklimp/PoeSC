# sources:
# https://stackoverflow.com/questions/20865010/how-do-i-create-an-input-box-with-python
# https://realpython.com/python-gui-tkinter/

from teach_spacy_adj_Class import Nlp
import tkinter as tk
from Osc_send_class import Osc_send
from time import sleep

Nlp.main()
Osc_send.main()


# create new tkinter Window
window = tk.Tk()
e = tk.Text(window, bg="black", fg="white", undo="true")
e.pack()
e.focus_set()


# main Routine
def callback():
    txt = Nlp(e.get("1.0", tk.END))
    txt.get_adjectives("// ")
    splits = txt.split_sentences()
    # trigger new Stanza and pass num of phrases
    Osc_send.new_stanza_trigger(len(splits[1]))
    # check if playback mode is seq or par
    if splits[0] == "par":
        Osc_send.playback_mode("par")
    elif splits[0] == "seq":
        Osc_send.playback_mode("seq")

    for i in splits[1]:
    # delay needed in sclang in order to choose available Server
        sleep(0.2) 
        o = Osc_send()
        o.prosodic_labels(i)
        o.add_adjectives(Nlp.get_adjectives(i))
        o.meter_to_sclang()
        print(i)


b = tk.Button(window, text = "OK", width = 10, command = callback)
b.pack()

window.mainloop()