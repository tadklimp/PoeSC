import prosodic

class ProsodicLoad:
    
    lib = None

    def __init__(self):
        # self.lib = None
        print("prosodic ya ll")

    def main():
        if ProsodicLoad.lib is None:
            ProsodicLoad.lib = prosodic.Text()
            print("puting some txt mayb?")
            return ProsodicLoad.lib
        return ProsodicLoad.lib    




if __name__ == "__main__":
    main() 