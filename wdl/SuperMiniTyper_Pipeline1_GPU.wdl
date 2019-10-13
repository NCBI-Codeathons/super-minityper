task Pipeline1_GPU_cudamapper {
  File inputFASTQ
  Int diskGB = 32
  Int threads = 8

  Int kmerSize = 15
  Int windowSize = 15
  Int indexSize = 10000
  Int targetIndexSize = 10000

  Int dropLengthLower = 10000

  String outbase = basename(inputFASTQ)

  command {
    cudamapper -k ${kmerSize} -w ${windowSize} -i ${indexSize} -t ${targetIndexSize} ${inputFASTQ} ${inputFASTQ} | fpa drop -l ${dropLengthLower} > ${outbase}.paf
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


task Pipeline1_GPU_seqwish {
  File inputFASTQ
  File inputPAF
  Int diskGB = 32
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


workflow SuperMiniTyper_Pipeline1_GPU {
  File inputFASTQ
  Int diskGB = 32
  Int threads = 8

  call Pipeline1_GPU_cudamapper {
    input:
      inputFASTQ=inputFASTQ,
      diskGB=diskGB
  }

  call Pipeline1_GPU_seqwish {
    input:
        inputFASTQ=inputFASTQ,
        inputPAF=Pipeline1_GPU_cudamapper.outputPAF
  }
}
