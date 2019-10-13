import sys

if __name__ == "__main__":

    with open(sys.argv[1], "r") as ifi:
        for line in ifi:
            if line.startswith("L"):
                line = line.strip()
                tokens = line.split("\t")
                tokens.append("0M")
                print("\t".join(tokens))
            else:
                print(line.strip())
