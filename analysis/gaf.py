import sys

inputFile = sys.argv[1]
buckets = int(sys.argv[2])

###################### GAF Parser ###########################
class GAFEntry:
    def __init__(self, row):
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
        row = row.strip().split("\t")
        self.querySeqName = row[0]
        self.querySeqLen = int(row[1])
        self.queryStart = int(row[2])
        self.queryEnd = int(row[3])
        self.strand = row[4]
        self.path = row[5]
        self.pathLen = int(row[6])
        self.startPosPath = int(row[7])
        self.endPosPath = int(row[8])
        self.numMatches = int(row[9])
        self.alignBlockLen = int(row[10])
        self.mapQual = int(row[11])

class GAF:
    def __init__(self, filename):
        self.alignments = []
        with open(filename) as f:
            for line in f:
                self.alignments.append(GAFEntry(line))

    def __len__(self):
        return len(self.alignments)

###################### GAF Analyzer ###########################
align_perc_90 = 0
align_perc_50 = 0
align_perc_other = 0
path_start_pos = []
path_end_pos = []

# Attempt to classify quality of mapping
gfa = GAF(inputFile)
for alignment in gfa.alignments:
    align_perc = float(alignment.alignBlockLen) / float(alignment.querySeqLen)
    if (align_perc > 0.9):
        align_perc_90 += 1
    elif (align_perc > 0.5):
        align_perc_50 += 1
    else:
        align_perc_other += 1

    path_start_pos.append(alignment.startPosPath)
    path_end_pos.append(alignment.endPosPath)

align_perc_90 = float(align_perc_90) / len(gfa)
align_perc_50 = float(align_perc_50) / len(gfa)
align_perc_other = float(align_perc_other) / len(gfa)

# Try to get a sense of where in the graph the reads are being mapped to
path_start_pos = sorted(path_start_pos)
path_end_pos = sorted(path_end_pos)
range_start = min(path_start_pos[0], path_end_pos[0])
range_end = max(path_start_pos[-1], path_end_pos[-1])
bucket_size = (range_end - range_start) // buckets
bucket_counts = [0 for _ in range(buckets)]
next_pos = 1
for pos in path_start_pos:
    if pos < range_start + next_pos * bucket_size:
        bucket_counts[next_pos - 1] += 1
    else:
        while(pos > range_start + next_pos * bucket_size):
            next_pos += 1

#bucket_counts = [float(count) / len(gfa) for count in bucket_counts]
bucket_boundaries = [range_start + bucket_size * i for i in range(buckets + 1)]

###################### Print Analysis ###########################
print("Total alignments {}\n".format(len(gfa)))

print("Number of alignments with path start positions in each window -")
for i in range(len(bucket_counts)):
    print("{}:{} - {} alignment starts".format(bucket_boundaries[i], bucket_boundaries[i + 1], bucket_counts[i]))

print("\n")
print("Alignments broken down by % of query mapped to graph:\n>90% = {}\n50-90% = {}\n0-50% = {}\n".format(align_perc_90, align_perc_50, align_perc_other))
