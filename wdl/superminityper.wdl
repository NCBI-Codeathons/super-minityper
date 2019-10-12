task minigraph{
  File inputFASTQ
  File inputGFA

  String preset = "lr"

  Int kmerSize = 15
  Int windowSize = 10
  Int threads = 8
  Int diskGB

  String outbase = basename(inputGFA, "GFA") + basename(inputFASTQ)

  command{
      minigraph -x lr ${inputGFA} ${inputFASTQ} > ${outbase}.gaf
  }
  
  runtime{
    docker: "erictdawson/minigraph"
    cpu : "${threads}"
    memory : "16 GB"
    disk : "local-disk " + diskGB + " HDD"
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

}
