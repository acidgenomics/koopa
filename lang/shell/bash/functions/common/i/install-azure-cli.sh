#!/usr/bin/env bash

# FIXME Seeing this issue on Linux:
#   Downloading antlr4-python3-runtime-4.9.3.tar.gz (117 kB)
#      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 117.0/117.0 KB 20.8 MB/s eta 0:00:00
#   Preparing metadata (setup.py): started
#   Preparing metadata (setup.py): finished with status 'error'
#   error: subprocess-exited-with-error
#
#   × python setup.py egg_info did not run successfully.
#   │ exit code: 1
#   ╰─> [1 lines of output]
#       ERROR: Can not execute `setup.py` since setuptools is not available in the build environment.
#       [end of output]
#
#   note: This error originates from a subprocess, and is likely not a problem with pip.
# error: metadata-generation-failed
#
# × Encountered error while generating package metadata.
# ╰─> See above for output.

koopa_install_azure_cli() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/az' \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        "$@"
}
