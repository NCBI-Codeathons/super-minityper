task seqwish{
    File inputFA
    File inputPAF
    Int diskGB
  
  String outbase = basename(basename(inputFA, "fa"), ".gz")
  
  command{
     seqwish -s ${inputFA} -p ${inputPAF} -b ${outbase}.graph -g ${outbase}.gfa
  }
  
  runtime{
     docker: "erictdawson/svaha2"
     cpu : 1
     memory : "24 GB"
     dx_instance_type: "mem2_ssd1_x16"
     preemptible : 2
     disks : "local-disk " + diskGB + " SSD"
  }

  output{
   File outputGFA = "${outbase}.gfa"
  }
}

task filterPAF{
    File inputPAF
    Int minOverlap = 10000

    String outbase = basename(inputPAF, "paf")

    command{
        fpa drop -l ${minOverlap} -o ${inputPAF} > ${outbase}.filtered.paf
    }

    runtime{

    }

    output{

    }
}

task minimap2Overlap{
    File inputFA
    String args = "-c -X"
    Int diskGB


    command{
        minimap2 ${args} ${inputFA} ${inputFA} > ${outbase}.paf
    }

    runtime{

    }
    output{

    }
}

workflow Svaha2ConstructGraph{
  File inputFA
  String seqwishArgs = "-c -X"

  Int diskGB = ceil(size(inputFA, "GB")) + 30

  call construct{
    input:
      inputFA=inputFA,
      diskGB=diskGB
  }	
}