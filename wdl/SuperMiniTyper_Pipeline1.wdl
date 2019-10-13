task Pipeline1_minimap2 {
  File inputFASTQ
  Int dropLengthLower = 10000
  Int diskGB
  Int threads = 8

  String outbase = basename(inputFASTQ)

  command {
    minimap2 ${inputFASTQ} ${inputFASTQ} -t ${threads} -c -X | fpa drop -l ${dropLengthLower} > ${outbase}.paf
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


task Pipeline1_seqwish {
  File inputFASTQ
  File inputPAF
  Int diskGB
  Int threads = 8

  String outbase = basename(inputFASTQ)

  command {
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


workflow SuperMiniTyper_Pipeline1 {
  File inputFASTQ
  Int diskGB
  Int threads = 8

  call Pipeline1_minimap2 {
    input:
      inputFASTQ=inputFASTQ,
      diskGB=diskGB
  }

  call Pipeline1_seqwish {
    input:
        inputFASTQ=inputFASTQ,
        inputPAF=Pipeline1_minimap2.outputPAF
  }
}
