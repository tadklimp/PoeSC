import osc_config
from pythonosc.udp_client import SimpleUDPClient


def connect():
    ip = osc_config.HOST
    port = osc_config.PORT
    osc_config.CONNECTION = SimpleUDPClient(ip, port) 

connect()


print("Client active - sending to", osc_config.HOST, "at port", osc_config.PORT)  