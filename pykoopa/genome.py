#!/usr/bin/env python3

import subprocess



def ensembl_version():
    release = subprocess.check_output(
        "ensembl-version",
        shell=True,
        universal_newlines=True,
    )
    release = release.rstrip()
    return(release)
