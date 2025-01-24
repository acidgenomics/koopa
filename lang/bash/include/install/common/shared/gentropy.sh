#!/usr/bin/env bash

# FIXME Saw error message about man1 linkage on EC2, look into debugging.
# This may only be an issue with Bash 4.2 due to empty array handling?

main() {
    koopa_install_python_package \
        --python-version='3.10'
    return 0
}
