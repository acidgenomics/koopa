#!/usr/bin/env python3
"""
Example tests.
"""

import os

# FIXME Need to support output-dir for Python functions.

d = tmp_path / "sub"
d.mkdir()


def test_download_ensembl_genome():
    """
    Download Ensembl genome.
    """
    # FIXME Need to convert to system command.
    download-ensembl-genome \
            --organism="Homo sapiens" \
            --build="GRCh38" \
            --type="all" \
            --annotation="all" \
            --decompress
    # assert func(3) == 5
