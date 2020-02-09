#!/usr/bin/env python3
"""
GENCODE genome utilities.
"""

from koopa.genome import _genome_version


def gencode_version(organism):
    """
    Current GENCODE release version.
    Updated 2019-10-07.
    """
    return _genome_version("gencode", ('"' + organism + '"'))
