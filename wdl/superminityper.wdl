task minigraph{
  File inputFASTQ
  File inputGFA

  String outbase = basename(inputGFA, "GFA") + basename(inputFASTQ)

  command{
      minigraph -x lr ${inputGFA} ${inputFASTQ} > ${outbase}.gaf
  }
  
  runtime{
    docker: "erictdawson/minigraph"
    cpu : 12
    memory : "16 GB"
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
