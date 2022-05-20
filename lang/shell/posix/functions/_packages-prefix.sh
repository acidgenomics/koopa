#!/bin/sh

__koopa_packages_prefix() {
    # """
    # Packages prefix for a specific language.
    # @note Updated 2022-02-25.
    #
    # @usage __koopa_packages_prefix NAME [VERSION]
    # """
    local name str version
    name="${1:?}-packages"
    version="${2:-}"
    if [ -n "$version" ]
    then
        version="$(koopa_major_minor_version "$version")"
        str="$(koopa_app_prefix)/${name}/${version}"
    else
        str="$(koopa_opt_prefix)/${name}"
    fi
    koopa_print "$str"
    return 0
}
