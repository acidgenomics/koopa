#!/usr/bin/env bash

koopa::julia_script_prefix() { # {{{1
    # """
    # Julia script prefix.
    # @note Updated 2021-06-14.
    # """
    koopa::print "$(koopa::koopa_prefix)/lang/julia/include"
    return 0
}

koopa::installers_prefix() { # {{{1
    # """
    # Koopa installers prefix.
    # @note Updated 2022-01-28.
    # """
    koopa::print "$(koopa::koopa_prefix)/lang/shell/bash/include/installers"
    return 0
}

koopa::python_system_packages_prefix() { # {{{1
    # """
    # Python system site packages library prefix.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [python]="${1:-}"
    )
    [[ -z "${app[python]}" ]] && app[python]="$(koopa::locate_python)"
    koopa::assert_is_installed "${app[python]}"
    declare -A dict
    dict[prefix]="$( \
        "${app[python]}" -c 'import site; print(site.getsitepackages()[0])' \
    )"
    koopa::assert_is_dir "${dict[prefix]}"
    koopa::print "${dict[prefix]}"
    return 0
}

koopa::r_prefix() { # {{{1
    # """
    # R prefix.
    # @note Updated 2022-01-31.
    #
    # We're suppressing errors here that can pop up if 'etc' isn't linked yet
    # after a clean install. Can warn about ldpaths missing.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa::locate_r)"
    app[rscript]="${app[r]}script"
    koopa::assert_is_installed "${app[rscript]}"
    declare -A dict
    dict[prefix]="$( \
        "${app[rscript]}" \
            --vanilla \
            -e 'cat(normalizePath(Sys.getenv("R_HOME")))' \
        2>/dev/null \
    )"
    koopa::assert_is_dir "${dict[prefix]}"
    koopa::print "${dict[prefix]}"
    return 0
}

koopa::r_library_prefix() { # {{{1
    # """
    # R default library prefix.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa::locate_r)"
    app[rscript]="${app[r]}script"
    koopa::assert_is_installed "${app[rscript]}"
    declare -A dict
    dict[prefix]="$( \
        "${app[rscript]}" -e 'cat(normalizePath(.libPaths()[[1L]]))' \
    )"
    koopa::assert_is_dir "${dict[prefix]}"
    koopa::print "${dict[prefix]}"
    return 0
}

koopa::r_system_library_prefix() { # {{{1
    # """
    # R system library prefix.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa::locate_r)"
    app[rscript]="${app[r]}script"
    koopa::assert_is_installed "${app[rscript]}"
    declare -A dict
    dict[prefix]="$( \
        "${app[rscript]}" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    koopa::assert_is_dir "${dict[prefix]}"
    koopa::print "${dict[prefix]}"
    return 0
}
