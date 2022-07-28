#!/bin/sh

koopa_julia_packages_prefix() {
    # """
    # Julia packages (depot) library prefix.
    # @note Updated 2022-07-28.
    # """
    koopa_print "${HOME:?}/.julia"
}
