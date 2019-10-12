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

\pagebreak

## Workflow progress

We integrated a new DNAnexus workflow for graph alignment (you're welcome, @benbusby):

fast(a/q) + GFA &rarr; minigraph &rarr; GAF (graph alignments)

The WDL for this is in out [WDL directory](https://github.com/NCBI-Codeathons/super-minityper/tree/master/wdl).

We also compiled it to DNAnexus using dxWDL. The tool is called SuperMiniTyper.
