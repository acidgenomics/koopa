#!/usr/bin/env bash

# FIXME Saw error message about man1 linkage on EC2, look into debugging.

main() {
    koopa_install_python_package \
        --python-version='3.10'
    return 0
}
