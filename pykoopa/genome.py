#!/usr/bin/env python3
"""
Genome utilities.
"""

import subprocess

from pykoopa.sys import arg_string


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


def ensembl_version():
    """
    Current Ensembl release version.
    Updated 2019-10-07.
    """
    return _genome_version("ensembl")


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


def wormbase_version():
    """
    Current WormBase release version.
    Updated 2019-10-07.
    """
    return _genome_version("wormbase")
