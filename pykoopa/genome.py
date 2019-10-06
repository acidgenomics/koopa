#!/usr/bin/env python3

import subprocess

from pykoopa.sys import arg_string


# Updated 2019-10-06.
def _genome_version(name, *args):
    cmd = name + "-version"
    args = arg_string(*args)
    if not args is None:
        cmd = cmd + args
    x = subprocess.check_output(cmd, shell=True, universal_newlines=True)
    x = x.rstrip()
    return x


def ensembl_version():
    return _genome_version("ensembl")


def flybase_version():
    return _genome_version("flybase")


def gencode_version(organism):
    return _genome_version("gencode", organism)


def refseq_version():
    return _genome_version("refseq")


def wormbase_version():
    return _genome_version("wormbase")
