#!/bin/sh

_koopa_activate_bcbio_nextgen() {
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
    __kvar_prefix="$(_koopa_bcbio_nextgen_prefix)"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    _koopa_add_to_path_end "${__kvar_prefix}/tools/bin"
    unset -v __kvar_prefix
    return 0
}
