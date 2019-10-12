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

    for line in f:
        row = line.strip().split("\t")
        print row
        querySeqName, querySeqLen, queryStart, queryEnd, strand, path, pathLen, startPosPath, endPosPath, numMatches, alignBlockLen, mapQual = row[0:12]
        

    
