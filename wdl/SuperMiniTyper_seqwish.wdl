task SuperMiniTyper_seqwish {
  File inputFASTQ
  File inputPAF
  Int diskGB
  Int threads = 8

  String outbase = basename(inputFASTQ)

  command{
    seqwish -s ${inputFASTQ} -p ${inputPAF} -b ${outbase}.graph -g ${outbase}.gfa
  }

  runtime {
    docker: "ncbicodeathons/superminityper:0.1-cpu"
    cpu : "${threads}"
    memory : "16 GB"
    disk : "local-disk " + diskGB + " HDD"
    preemptible : 4
  }

  output {
    File outputGFA = "${outbase}.gfa"
    File outputGRAPH = "${outbase}.graph"
  }
}
