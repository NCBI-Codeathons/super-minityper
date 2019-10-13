task SuperMiniTyper_cudamapper {
  File inputFASTQ
  Int diskGB = 32
  Int threads = 8

  Int kmerSize = 15
  Int windowSize = 15
  Int indexSize = 10000
  Int targetIndexSize = 10000

  String outbase = basename(inputFASTQ)

  command {
    cudamapper -k ${kmerSize} -w ${windowSize} -i ${indexSize} -t ${targetIndexSize} ${inputFASTQ} ${inputFASTQ} > ${outbase}.paf
  }

  runtime {
    docker: "ncbicodeathons/superminityper:0.1"
    cpu : "${threads}"
    memory : "16 GB"
    disk : "local-disk " + diskGB + " HDD"
    preemptible : 4
  }

  output {
    File outputPAF = "${outbase}.paf"
  }
}
