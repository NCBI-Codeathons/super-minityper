task minigraph{
  File inputFASTQ
  File inputGFA
  Int diskGB = 32

  String preset = "lr"

  Int kmerSize = 15
  Int windowSize = 10
  Int threads = 8

  String outbase = basename(inputGFA, "GFA") + basename(inputFASTQ)

  command{
      minigraph -x ${preset} -t ${threads} -w ${windowSize} -k ${kmerSize} ${inputGFA} ${inputFASTQ} > ${outbase}.gaf
  }

  runtime{
    docker: "erictdawson/minigraph"
    cpu : "${threads}"
    memory : "16 GB"
    disk : "local-disk " + diskGB + " HDD"
    dx_instance_type: "mem1_ssd1_x16"
    preemptible : 4
  }

  output{
    File outputGAF = "${outbase}.gaf"
  }

}

task analysis{
  File inputGAF

  command{

  }

  runtime{

  }

  output{

  }
}

workflow SuperMiniTyper{
  File inputFASTQ
  File inputGFA

  Int diskGB = ceil(size(inputFASTQ, "GB")+ size(inputGFA, "GB")) + 100

  call minigraph{
    input:
      inputFASTQ=inputFASTQ,
      inputGFA=inputGFA,
      diskGB=diskGB
  }

}
