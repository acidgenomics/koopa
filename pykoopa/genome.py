#!/usr/bin/env python3

import subprocess



def _genome_version(name):
    cmd = (name + "-version")
    x = subprocess.check_output(
        cmd,
        shell=True,
        universal_newlines=True
    )
    x = x.rstrip()
    return(x)



def ensembl_version():
    return(_genome_version("ensembl"))



def flybase_version():
    return(_genome_version("flybase"))



def gencode_version():
    return(_genome_version("gencode"))



def refseq_version():
    return(_genome_version("refseq"))



def wormbase_version():
    return(_genome_version("wormbase"))
