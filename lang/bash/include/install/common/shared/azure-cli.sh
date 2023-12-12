#!/usr/bin/env bash

main() {
    # """
    # Python 3.12 support status:
    # https://github.com/Azure/azure-cli/issues/27673
    # """
    koopa_install_python_package \
        --egg-name='azure_cli' \
        --python-version='3.11'
    return 0
}
