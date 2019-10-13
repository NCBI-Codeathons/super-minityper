import csv
from collections import defaultdict
import argparse

nodes = {}
out_edges = defaultdict(list)
in_edges = defaultdict(list)

def build_graph(graph):
    with open(graph, 'r') as csvfile:
        reader = csv.reader(csvfile)
        for r in reader:
            k1 = r[1]
            k2 = r[2]
            nodes[k1] = True
            nodes[k2] = True
            # Store the mean distance between kmers in graph
            out_edges[k1].append(k2)
            in_edges[k2].append(k1)

def build_read_sketch(read):
    hits = []
    for node in nodes:
        pos = read.find(node)
        if (pos != -1):
            hits.append((pos, node))

    hits = sorted(hits, key=lambda x : x[0])
    print("Read length {}".format(len(read)))
    return hits

def align_to_graph(hits):
    print(hits)
    hit_len = 0
    for i in range(len(hits) - 1):
        _, current = hits[i]
        _, nex = hits[i+1]
        # TODO: Incorporate mean distance between kmers in input graph to do some filtering here
        if current not in out_edges:
            return False
        edges = out_edges[current]
        if nex not in edges:
            return False
        hit_len += len(current)
    print("Matched {}".format(hit_len))
    return True

#read = "TTGGAGGAGTTTGTTATTACCCACCTTCTGAAGCCTACTTGTGTCAATTCNNNNTTTTGTTCCCTTGCTCGTGAGGAGTTGTGATCCTTTGGAGGAGAAGAGGCNNNNNTTTGTGTATCATTTTTTTGTTTTGAGATGGAGTCTTGCTCTTTTCGCACA"

parser = argparse.ArgumentParser()
parser.add_argument('--graph', required=True)
parser.add_argument('--reads', required=True)
args = parser.parse_args()

build_graph(args.graph)
with open(args.reads, "r") as reads:
    for read in reads.readlines():
        hits = build_read_sketch(read.strip())
        print(align_to_graph(hits))
