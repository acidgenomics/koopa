#!/usr/bin/env bash

koopa_julia_script_prefix() { # {{{1
    # """
    # Julia script prefix.
    # @note Updated 2021-06-14.
    # """
    koopa_print "$(koopa_koopa_prefix)/lang/julia/include"
    return 0
}

koopa_installers_prefix() { # {{{1
    # """
    # Koopa installers prefix.
    # @note Updated 2022-01-28.
    # """
    koopa_print "$(koopa_koopa_prefix)/lang/shell/bash/include/installers"
    return 0
}

koopa_man_prefix() { # {{{1
    # """
    # man documentation file prefix.
    # @note Updated 2022-02-15.
    # """
    koopa_print "$(koopa_koopa_prefix)/man"
    return 0
}

koopa_python_system_packages_prefix() { # {{{1
    # """
    # Python system site packages library prefix.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [python]="${1:-}"
    )
    [[ -z "${app[python]}" ]] && app[python]="$(koopa_locate_python)"
    koopa_assert_is_installed "${app[python]}"
    declare -A dict
    dict[prefix]="$( \
        "${app[python]}" -c 'import site; print(site.getsitepackages()[0])' \
    )"
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_print "${dict[prefix]}"
    return 0
}

koopa_r_prefix() { # {{{1
    # """
    # R prefix.
    # @note Updated 2022-01-31.
    #
    # We're suppressing errors here that can pop up if 'etc' isn't linked yet
    # after a clean install. Can warn about ldpaths missing.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    app[rscript]="${app[r]}script"
    koopa_assert_is_installed "${app[rscript]}"
    declare -A dict
    dict[prefix]="$( \
        "${app[rscript]}" \
            --vanilla \
            -e 'cat(normalizePath(Sys.getenv("R_HOME")))' \
        2>/dev/null \
    )"
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_print "${dict[prefix]}"
    return 0
}

koopa_r_library_prefix() { # {{{1
    # """
    # R default library prefix.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    app[rscript]="${app[r]}script"
    koopa_assert_is_installed "${app[rscript]}"
    declare -A dict
    dict[prefix]="$( \
        "${app[rscript]}" -e 'cat(normalizePath(.libPaths()[[1L]]))' \
    )"
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_print "${dict[prefix]}"
    return 0
}

koopa_r_system_library_prefix() { # {{{1
    # """
    # R system library prefix.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    app[rscript]="${app[r]}script"
    koopa_assert_is_installed "${app[rscript]}"
    declare -A dict
    dict[prefix]="$( \
        "${app[rscript]}" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_print "${dict[prefix]}"
    return 0
}

koopa_tests_prefix() { # {{{1
    # """
    # Unit tests prefix.
    # @note Updated 2022-02-17.
    # """
    koopa_print "$(koopa_koopa_prefix)/tests"
    return 0
}
