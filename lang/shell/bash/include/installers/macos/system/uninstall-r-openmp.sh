#!/usr/bin/env bash

main() {
    # """
    # Uninstall OpenMP library.
    # @note Updated 2022-04-13.
    # """
    koopa_assert_has_no_args "$#"
    koopa_rm --sudo \
        '/usr/local/include/omp-tools.h' \
        '/usr/local/include/omp.h' \
        '/usr/local/include/ompt.h' \
        '/usr/local/lib/libomp.dylib'
}
