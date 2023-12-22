#!/usr/bin/env bash

koopa_current_latch_version() {
    # """
    # Current latch package version at pypi.
    # @note Updated 2023-12-22.
    #
    # Our awk command removes empty lines with NF, trims whitespace, and then
    # prints the second column in the string, which contains the version.
    # """
    koopa_current_pypi_package_version 'latch'
    return 0
}
