from collections import defaultdict
from sys import argv

"""
Usage: python giab_fixup.py HG002_SVs.vcf > hg002.fixedup.vcf
Takes in a VCF file with ref/alts from GIAB HG002 tier 1 SVs
then:
1. fills in the CHR2 info field
2. Gets Insertion sequences and places them in the "SEQ" info field
3. Rips out the ref/alt bases that eat valuable VCF space.


"SEQ" and "CHR2" should be added as valid INFO tags to the header as well
"""

chr2_tag_line = "##INFO=<ID=CHR2,Number=1,Type=String,Description=\"Second chromosome of SV\">"
seq_tag_line = "##INFO=<ID=SEQ,Number=1,Type=String,Description=\"Insertion sequence\">"

if __name__ == "__main__":

    print(chr2_tag_line)
    print(seq_tag_line)
    with open(argv[1], "r") as ifi:
        for line in ifi:
            line = line.strip()
            if line.startswith("#"):
                print(line)

            else:
                tokens = line.split("\t")
                infos = defaultdict(str)
                info_splits = tokens[7].split(";")
                for i in info_splits:
                    x_split = i.split("=")
                    if len(x_split) == 2:
                        infos[x_split[0]] = x_split[1]
                    else:
                        infos[x_split[0]] = x_split[0]
                infos["CHR2"] = tokens[0]
                if infos["SVTYPE"] == "INS":
                    seq = tokens[4][1:]
                    infos["SEQ"] = seq
                keepinfos = defaultdict(str)
                for i in ["SEQ", "END", "CHR2", "SVTYPE"]:
                    if i in infos:
                        keepinfos[i] = infos[i]
                infos = keepinfos
                info_strs = [ "=".join([i, infos[i]]) if i != infos[i] else [i] for i in infos]
                tokens[7] = ";".join(info_strs)
                tokens[4] = "<" + infos["SVTYPE"] + ">"
                print("\t".join(tokens))

