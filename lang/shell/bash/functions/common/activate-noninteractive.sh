#!/usr/bin/env bash

koopa::activate_llvm() { # {{{1
    # """
    # Activate LLVM config.
    # @note Updated 2021-05-25.
    # """
    LLVM_CONFIG="$(koopa::locate_llvm_config)"
    export LLVM_CONFIG
    return 0
}
