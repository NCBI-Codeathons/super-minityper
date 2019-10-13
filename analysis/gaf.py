import sys

inputFile = sys.argv[1]

with open(inputFile) as f:
    #1   string  Query sequence name
    #2   int Query sequence length
    #3   int Query start (0-based; closed)
    #4   int Query end (0-based; open)
    #5   char    Strand relative to the path: "+" or "-"
    #6   string  Path matching /([><][^\s><]+(:\d+-\d+)?)+|([^\s><]+)/
    #7   int Path length
    #8   int Start position on the path (0-based)
    #9   int End position on the path (0-based)
    #10  int Number of residue matches
    #11  int Alignment block length
    #12  int Mapping quality (0-255; 255 for missing)

    total_alignments = 0

    align_perc_90 = 0
    align_perc_50 = 0
    align_perc_other = 0
    for line in f:
        row = line.strip().split("\t")
        querySeqName, querySeqLen, queryStart, queryEnd, strand, path, pathLen, startPosPath, endPosPath, numMatches, alignBlockLen, mapQual = row[0:12]

        total_alignments += 1

        # Find measure of overlap
        align_perc = float(alignBlockLen) / float(querySeqLen)
        if (align_perc > 0.9):
            align_perc_90 += 1
        elif (align_perc > 0.5):
            align_perc_50 += 1
        else:
            align_perc_other += 1

    print("Total alignments {}\n".format(total_alignments))
    print("Alignments broken down by % of query mapped to graph:\n>90% = {}\n>50% = {}\nRest = {}\n".format(align_perc_90, align_perc_50, align_perc_other))
