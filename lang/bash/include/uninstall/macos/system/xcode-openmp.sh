#!/usr/bin/env bash

main() {
    # """
    # Uninstall OpenMP for Xcode library.
    # @note Updated 2023-04-11.
    # """
    koopa_rm --sudo \
        '/usr/local/include/omp-tools.h' \
        '/usr/local/include/omp.h' \
        '/usr/local/include/ompt.h' \
        '/usr/local/lib/libomp.dylib'
    return 0
}
