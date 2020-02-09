#!/usr/bin/env python3
"""
Genome utilities.
"""

import os
import subprocess

from koopa.sys import arg_string


def _genome_version(name, *args):
    """
    Internal shared genome version fetcher.
    Updated 2019-10-07.
    """
    cmd = name + "-version"
    args = arg_string(*args)
    if args is not None:
        cmd = cmd + args
    out = subprocess.check_output(cmd, shell=True, universal_newlines=True)
    out = out.rstrip()
    return out


def flybase_dmel_version():
    """
    Current Drosophila melanogaster genome version on FlyBase.
    Updated 2019-10-07.
    """
    return _genome_version("flybase", "--dmel")


def flybase_version():
    """
    Current FlyBase release version.
    Updated 2019-10-07.
    """
    return _genome_version("flybase")


def gencode_version(organism):
    """
    Current GENCODE release version.
    Updated 2019-10-07.
    """
    return _genome_version("gencode", ('"' + organism + '"'))


def refseq_version():
    """
    Current RefSeq release version.
    Updated 2019-10-07.
    """
    return _genome_version("refseq")


def tx2gene_from_fasta(source_name, output_dir):
    """
    Generate tx2gene.csv mapping file from transcriptome FASTA.

    Note that this function is currently called by genome download scripts, and
    assumes that output_dir has a specific structure, containing a
    "transcriptome" subdirectory with the FASTA.

    Updated 2019-10-24.
    """
    cmd = "tx2gene-from-" + source_name + "-fasta"
    transcriptome_dir = os.path.join(output_dir, "transcriptome")
    input_file = os.path.join(transcriptome_dir, "*.fa*.gz")
    output_file = os.path.join(transcriptome_dir, "tx2gene.csv")
    if os.path.isfile(output_file):
        print("File exists: '" + output_file + "'.")
        return output_file
    os.system(cmd + " " + input_file + " " + output_file)
    return output_file


def wormbase_version():
    """
    Current WormBase release version.
    Updated 2019-10-07.
    """
    return _genome_version("wormbase")
