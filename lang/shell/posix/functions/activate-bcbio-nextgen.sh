#!/bin/sh

koopa_activate_bcbio_nextgen() { # {{{1
    # """
    # Activate bcbio-nextgen tool binaries.
    # @note Updated 2022-05-12.
    #
    # Attempt to locate bcbio installation automatically on supported platforms.
    #
    # Exporting at the end of PATH so we don't mask gcc or R.
    # This is particularly important to avoid unexpected compilation issues
    # due to compilers in conda masking the system versions.
    #
    # @seealso
    # - https://bcbio-nextgen.readthedocs.io/en/latest/contents/
    #     installation.html
    # """
    local prefix
    prefix="$(koopa_bcbio_nextgen_prefix)"
    [ -d "$prefix" ] || return 0
    # Only enable this when debugging.
    # > koopa_add_to_path_end "${prefix}/install/anaconda/bin"
    koopa_add_to_path_end "${prefix}/tools/bin"
    return 0
}
