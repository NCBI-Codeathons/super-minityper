task SuperMiniTyper_minimap2 {
  File inputFASTQ
  Int diskGB
  Int threads = 8

  String outbase = basename(inputFASTQ)

  command {
    minimap2 ${inputFASTQ} ${inputFASTQ} -c -X > ${outbase}.paf
  }

  runtime {
    docker: "gigony/super-minityper:0.1-cpu"
    cpu : "${threads}"
    memory : "16 GB"
    disk : "local-disk " + diskGB + " HDD"
    preemptible : 4
  }

  output {
    File outputPAF = "${outbase}.paf"
  }
}
