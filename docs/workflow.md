Super Fast SV Graphs
-------------------

We're building a GPU-accelerated method for graph-reads comparison.
What does that mean?:

1. Given a set of structural variants in VCF and a reference genome, build
a graph (in GFA) with svaha2 [pre-done].  
  - Acquire public data (mock metagenome from Nick Loman; GIAB)
  - Build graph  
  - That's it.  
2. Build a GFA -> GPU reader  
3. Using the Clara Genomics Toolkit, produce alignments of short- and long-reads
to the graph.  
  - cumapper (minimap2 implementation for short and long reads)  
  - cualigner (partial-order aligner)  
  - output: PAF / CIGAR (CS tags)  
4. Based on the PAF, calculate a concordance metric between a reference and a query
  - Incorporate measures of soft-clipping, insert size discordance, and other SV-mismapping signatures
  (or long-read signals) to produce a single-number score
  - Allows direct comparison between mappings on linear references and graphs.

