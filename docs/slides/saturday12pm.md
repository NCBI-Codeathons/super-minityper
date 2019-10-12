super-minityper: Day 1 (0-indexed)
---------------
Team 3


## Pivot!
We pivoted our goals a bit to focus more on using existing tools to
create workflows, rather than going down a development rabbithole.

New goals:  
1. Create a workflow for mapping (long) reads to SV graphs in DNAnexus  
2. Add tooling for constructing graphs from SV calls.  
3. Build parallel workflows for minimap2 -> seqwish graph induction:  
  - vanilla minimap2 &rarr; PFA filtering &rarr; seqwish = GFA
  - cudamapper &rarr; PFA filtering&rarr; seqwish = GFA. This requires modifying the output of
  cudamapper to output cigar strings.
4. Do some basic viz/stats in GFA/GAF  
  - [PAF Viz](https://github.com/dwinter/pafr) (GAF is a superset of PAF)  
  - [Bandage](https://github.com/rrwick/bandage) (Visualizes GFA files)  
  - [GFAKluge](https://github.com/edawson/gfakluge) (Basic GFA statistics)  
  - Python scripts : for counting alignments

<div style="page-break-after: always;"></div>

## Why?
The critical advantage of graphs over linear references is that
they allow mapping directly to variants.

The reason this is so useful in structural variant (re)discovery is that short reads often
don't map well to large variants. An example is shown below:
```
Linear Ref         : -----------------------------------------------------------
Read               :    +++++++
Softclipped portion:           ---
Real location of SC:                                               ===
```

Here, a read which spans an SV is soft-clipped, meaning
the aligner chose not to produce a global alignment between the read and reference
because there is a significant span between the last anchored refposition of the read
and position of the soft-clipped portion.  


Graphs can encode SVs explicitly and align directly to them:
```
Linear Ref         : -----------------------------------------------------------
Read               :    +++++++
Graph mapped SC bit:                                               +++ 
Path in graph      :           ------------------------------------
```

Because a path exists in the graph, the read can be mapped exactly to the variant path.
the soft-clipped portion now maps to the portion of the genome where it belongs.

This means that, given a graph of either known variants or long reads,
we can tell whether a new set of (long or short) reads contains that variant.
This allows us to answer useful questions such as "Does a new sample contain the SV in my graph?",
"Do both long and short reads from my sample support this SV?", etc.


Our workflows support the remapping of reads to graphs. These graphs can come from known SV calls,
or from the induction of aligned long-reads into graphs *de novo*. This second method is especially
useful if no reference genome is available.


## Workflow progress

### Read-to-graph alignment [**DONE**]
We integrated a new DNAnexus workflow for graph alignment (you're welcome, [@officialbenbusby](https://twitter.com/dcgenomics?lang=en)):

fast(a/q) + GFA &rarr; minigraph &rarr; GAF (graph alignments)

The WDL for this is in out [WDL directory](https://github.com/NCBI-Codeathons/super-minityper/tree/master/wdl).

We also compiled it to DNAnexus using dxWDL. The tool is called SuperMiniTyper.

**SuperMiniTyper**: Given a set of reads and a graph (possibly containing SV calls),
map those reads to the graph.

### Graph construction from reference genome + SV calls [**70% Complete**]
We downloaded the [GIAB Tier 1 SV calls](ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/AshkenazimTrio/analysis/NIST_SVs_Integration_v0.6/),
did some data munging,
and constructed a graph using [svaha2](https://github.com/edawson/svaha2) (after crushing some svaha2 bugs, *yikes*).
This is sitting in our DNAnexus project but we'd love to share it publicly!

We also pulled corresponding long-read data from GIAB, converted it to FASTQ, and we're preparing to run super-minityper on it.

**Final goal**: A DNAnexus applet for *fast* graph construction from known SV calls
and reference genomes.

##h# Graph construction from long reads [**<50% Complete**]