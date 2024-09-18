#!/usr/bin/env bash

koopa_is_compiler_supported() {
    # """
    # Is the current compiler supported?
    # @note Updated 2024-09-18.
    #
    # This check helps avoid compilation issues on very old HPC systems.
    # """
    # FIXME Require at least GCC 5.
    # FIXME Check against conda compiler and explicitly don't allow.
    # FIXME Require at least clang XXXX on macOS.
    return 0
}
