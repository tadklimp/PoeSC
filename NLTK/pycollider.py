import math
import socket
import config
from pythonosc.udp_client import SimpleUDPClient

#################
# Configuration #
#################

def setHost(ip):
    config.HOST = ip

def setPort(port):
    config.PORT = port

def connect():
    ip = config.HOST
    port = config.PORT
    config.CONNECTION = SimpleUDPClient(ip, port) 

def sendMsg(msg = "Hello Server!"):
    c = config.CONNECTION
    if c == None:
        print("No connection established")
        return
    c.send_message("/msg", msg)
    print("Message sent to", config.HOST, "at port", config.PORT)  

##########
# Sounds #
##########

def midiToFreq(midiPitch):
    return 2**((midiPitch - 69)/12) * 440

def sine(freq = 440, phase = 0, amp = 1, dur = 1, pan = 0):
    config.CONNECTION.send_message("/sounds/sine", [freq, phase, amp, dur, pan])

def sineMIDI(pitch = 69, phase = 0, amp = 1, dur = 1, pan = 0):
    sine(midiToFreq(pitch), phase, amp, dur, pan)

def saw(freq = 440, phase = 0, amp = 1, dur = 1, pan = 0):
    config.CONNECTION.send_message("/sounds/saw", [freq, phase, amp, dur, pan])

def sawMIDI(pitch = 69, phase = 0, amp = 1, dur = 1, pan = 0):
    saw(midiToFreq(pitch), phase, amp, dur, pan)


