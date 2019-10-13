task SuperMiniTyper_minimap2 {
  File inputFASTQ
  Int diskGB = 32
  Int threads = 8

  String outbase = basename(inputFASTQ)

  command {
    minimap2 -x ava-pb ${inputFASTQ} ${inputFASTQ} -t ${threads} -c -X > ${outbase}.paf
  }

  runtime {
    docker: "ncbicodeathons/superminityper:0.1-cpu"
    cpu : "${threads}"
    memory : "16 GB"
    disk : "local-disk " + diskGB + " HDD"
    preemptible : 4
  }

  output {
    File outputPAF = "${outbase}.paf"
  }
}
