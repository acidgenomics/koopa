#!/usr/bin/env python3
"""
RefSeq genome utilities.
"""

from koopa.genome import _genome_version


def refseq_version():
    """
    Current RefSeq release version.
    Updated 2019-10-07.
    """
    return _genome_version("refseq")
