#!/usr/bin/env bash

koopa_is_lmod_active() {
    # """
    # Is Lmod active with loaded modules?
    # @note Updated 2024-09-18.
    #
    # Other potential variables to check:
    # - _LMFILES_
    # - __LMOD_REF_COUNT_CPLUS_INCLUDE_PATH
    # - __LMOD_REF_COUNT_C_INCLUDE_PATH
    # - __LMOD_REF_COUNT_INCLUDE
    # - __LMOD_REF_COUNT_LD_LIBRARY_PATH
    # - __LMOD_REF_COUNT_LIBRARY_PATH
    # - __LMOD_REF_COUNT_MANPATH
    # - __LMOD_REF_COUNT_MODULEPATH
    # - __LMOD_REF_COUNT_PATH
    # """
    [[ -n "${LOADEDMODULES:-}" ]]
}
