super-minityper: Day 1 (0-indexed)
---------------

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

<div style="page-break-after: always;"></div>

## Workflow progress

### Read-to-graph alignment [**DONE**]
We integrated a new DNAnexus workflow for graph alignment (you're welcome, [@officialbenbusby](https://twitter.com/dcgenomics?lang=en)):

fast(a/q) + GFA &rarr; minigraph &rarr; GAF (graph alignments)

The WDL for this is in out [WDL directory](https://github.com/NCBI-Codeathons/super-minityper/tree/master/wdl).

We also compiled it to DNAnexus using dxWDL. The tool is called SuperMiniTyper.

### Graph construction from reference genome + SV calls [**70% Complete**]
We downloaded the [GIAB Tier 1 SV calls](ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/AshkenazimTrio/analysis/NIST_SVs_Integration_v0.6/),
did some data munging,
and constructed a graph using [svaha2](https://github.com/edawson/svaha2) (after crushing some svaha2 bugs, *yikes*).
This is sitting in our DNAnexus project but we'd love to share it publicly!

We also pulled corresponding long-read data from GIAB, converted it to FASTQ, and we're preparing to run super-minityper on it.

### Graph construction from long reads [**<50% Complete**]
