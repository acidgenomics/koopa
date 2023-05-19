#!/bin/sh

_koopa_julia_packages_prefix() {
    # """
    # Julia packages (depot) library prefix.
    # @note Updated 2022-07-28.
    # """
    _koopa_print "${HOME:?}/.julia"
}
