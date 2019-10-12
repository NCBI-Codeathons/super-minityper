super-minityper: Day 1 (0-indexed)
---------------

```

                                             _       _ _                         
                                            (_)     (_) |                        
  ___ _   _ _ __   ___ _ __ ______ _ __ ___  _ _ __  _| |_ _   _ _ __   ___ _ __ 
 / __| | | | '_ \ / _ \ '__|______| '_ ` _ \| | '_ \| | __| | | | '_ \ / _ \ '__|
 \__ \ |_| | |_) |  __/ |         | | | | | | | | | | | |_| |_| | |_) |  __/ |   
 |___/\__,_| .__/ \___|_|         |_| |_| |_|_|_| |_|_|\__|\__, | .__/ \___|_|   
           | |                                              __/ | |              
           |_|                                             |___/|_|              


```


## Pivot!
We pivoted our goals a bit to focus more on using existing tools to
create workflows, rather than going down a development rabbithole.

New goals:  
1. Create a workflow for mapping (long) reads to SV graphs in DNAnexus  
2. Add tooling for constructing graphs from SV calls.  
3. Build parallel workflows for minimap2 -> seqwish graph induction:  
  - vanilla minimap2 :arrow_right: PFA filtering :arrow_right: seqwish = GFA
  - cudamapper :arrow_right: PFA filtering:arrow_right: seqwish = GFA. This requires modifying the output of
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
because there is a significant span between the last anchored ref position of the read
and position of the soft-clipped portion.  


Graphs can encode SVs explicitly and align directly to them:
```
Linear Ref         : -----------------------------------------------------------
Alt path in graph  :           ------------------------------------
Read               :    +++++++                                    +++
```

Because a path exists in the graph, the read can be mapped exactly to the variant path.
The soft-clipped portion now maps to the portion of the genome where it belongs.

This means that, given a graph of either known variants or long reads,
we can tell whether a new set of (long or short) reads contains that variant.
This allows us to answer useful questions such as "Does a new sample contain the SV in my graph?",
"Do both long and short reads from my sample support this SV?", etc.


Our workflows support the remapping of reads to graphs. These graphs can come from known SV calls,
or from the induction of aligned long-reads into graphs *de novo*. This second method is especially
useful if no reference genome is available.


## Workflow progress

### Read-to-graph alignment [**90% Complete**]

fast(a/q) + GFA :arrow_right: minigraph :arrow_right: GAF (graph alignments)

We integrated a new DNAnexus workflow for graph alignment (you're welcome, [@officialbenbusby](https://twitter.com/dcgenomics?lang=en)):


The WDL for this is in out [WDL directory](https://github.com/NCBI-Codeathons/super-minityper/tree/master/wdl).

We also compiled it to DNAnexus using dxWDL. The tool is called SuperMiniTyper.

**SuperMiniTyper**: Given a set of reads and a graph (possibly containing SV calls),
map those reads to the graph.

![DXSMTRUN](https://raw.githubusercontent.com/NCBI-Codeathons/super-minityper/edawson/docs/images/dnanexus_smt.png)

**But it's buggy!**, so we're fixing those (thanks, GFA1...).

**Eventual product**: graph mappings. you get **automated phasing** if you iterate over the GAF
and generate a mapping from node -> count of matching reads (O(n) phasing, hooray!).

### Fast graph construction from a reference genome + SV calls :fire::zap::cloud: [**90% Complete**]

VCF + fast(a/q) :arrow_right: :cloud: svaha2 :cloud: :arrow_right: GFA 


We downloaded the [GIAB Tier 1 SV calls](ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/AshkenazimTrio/analysis/NIST_SVs_Integration_v0.6/),
did some data munging,
and constructed a graph using [svaha2](https://github.com/edawson/svaha2) (after crushing some svaha2 bugs, *yikes*).
This is sitting in our DNAnexus project but we'd love to share it publicly!

We also pulled corresponding long-read data from GIAB, converted it to FASTQ, and we're preparing to run super-minityper on it.

**Last todo:** testing. `svaha2` itself is under unit testing but we haven't tested the applet. Also,
the output appears to be incompatible with minigraph.


### Graph construction from long reads [**<50% Complete**]

fast(a/q) :arrow_right: minimap2/cudamapper (PAF) :arrow_right: seqwish :arrow_right: graph (GFA)  

We benchmarked minimap2 performance for generating all-2-all mapping with alignment cigar strings (i.e. input to seqwish).
On a core i9 12 core machine, that takes about 15 mins for E Coli read set from ONT.

Our alternative approach to minimap2 is a CUDA accelerated mapper that does all-2-all mapping with compute moved to the GPU.
Currently we're integrating CUDA accelerated aligner into cudamapper, and will benchmark that against the CPU based minimap2 flow.

Known issues - the recall/precision numbers for overlaps generated by cudamapper are a little worse than those from minimap2, so
we need to validate the quality of the graph generated compared to minimap2.

In parallel we're building an applet for the minimap/cudamapper + seqwish flow to do de novo graph generation from long reads.

### Postprocessing and analysis of mappings [**In progress**]
We're still researching and designing our analysis pipeline,
but we found some exciting tools to try out.
pafR provides visualization of the Pairwise Alignment Format, and we think we can
hack it to make pretty plots of read-graph alignments in addition to read-reference alignments.
GFAKluge provides basic stats on GFA, and Bandage is a common package for drawing graphs in GFA.
We plan to also roll python scripts (if need) to print statistics on GAF files. All of this can
be integrated into and analysis applet that can plug in to our previously mentioned pipelines.

