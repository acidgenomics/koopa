#!/usr/bin/env bash

# These functions support flexible version lookups.

koopa_anaconda_version() { # {{{1
    # """
    # Anaconda verison.
    # @note Updated 2022-03-18.
    #
    # @examples
    # # Version-specific lookup:
    # > koopa_anaconda_version '/opt/koopa/app/anaconda/2021.05/bin/conda'
    # # 2021.05
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [conda]="${1:-}"
    )
    [[ -z "${app[conda]}" ]] && app[conda]="$(koopa_locate_anaconda)"
    koopa_is_anaconda "${app[conda]}" || return 1
    # shellcheck disable=SC2016
    str="$( \
        "${app[conda]}" list 'anaconda' \
            | koopa_grep \
                --pattern='^anaconda ' \
                --regex \
            | "${app[awk]}" '{print $2}' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_bpytop_version() { # {{{1
    # """
    # bpytop version.
    # @note Updated 2022-03-18.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [bpytop]="${1:-}"
    )
    [[ -z "${app[bpytop]}" ]] && app[bpytop]="$(koopa_locate_bpytop)"
    # shellcheck disable=SC2016
    str="$( \
        "${app[bpytop]}" --version \
            | koopa_grep --pattern='bpytop version:' \
            | "${app[awk]}" '{ print $NF }' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_lesspipe_version() { # {{{1
    # """
    # lesspipe.sh version.
    # @note Updated 2022-03-18.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
        [lesspipe]="${1:-}"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -z "${app[lesspipe]}" ]] && app[lesspipe]="$(koopa_locate_lesspipe)"
    str="$( \
        "${app[cat]}" "${app[lesspipe]}" \
            | "${app[sed]}" -n '2p' \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_man_version() { # {{{1
    # """
    # man-db version.
    # @note Updated 2022-03-27.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [grep]="$(koopa_locate_grep)"
        [man]="${1:-}"
    )
    [[ -z "${app[man]}" ]] && app[man]="$(koopa_locate_man)"
    str="$( \
        "${app[grep]}" \
            --extended-regexp \
            --only-matching \
            --text \
            'lib/man-db/libmandb-[.0-9]+\.dylib' \
            "${app[man]}" \
    )"
    [[ -n "$str" ]] || return 1
    koopa_extract_version "$str"
    return 0
}

koopa_openjdk_version() { # {{{1
    # """
    # Java (OpenJDK) version.
    # @note Updated 2022-03-25.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [java]="${1:-}"
    )
    [[ -z "${app[java]}" ]] && app[java]="$(koopa_locate_java)"
    str="$( \
        "${app[java]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_parallel_version() { # {{{1
    # """
    # GNU parallel version.
    # @note Updated 2022-03-21.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [parallel]="${1:-}"
    )
    [[ -z "${app[parallel]}" ]] && app[parallel]="$(koopa_locate_parallel)"
    str="$( \
        "${app[parallel]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '3' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_r_version() { # {{{1
    # """
    # R version.
    # @note Updated 2022-02-27.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [head]="$(koopa_locate_head)"
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    str="$( \
        "${app[r]}" --version 2>/dev/null \
        | "${app[head]}" -n 1 \
    )"
    if koopa_str_detect_fixed \
        --string="$str" \
        --pattern='R Under development (unstable)'
    then
        str='devel'
    else
        str="$(koopa_extract_version "$str")"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_ruby_api_version() { # {{{1
    # """
    # Ruby API version.
    # @note Updated 2022-03-18.
    #
    # @section Gem installation path:
    #
    # Used by Homebrew Ruby for default gem installation path.
    # See 'brew info ruby' for details.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [ruby]="${1:-}"
    )
    [[ -z "${app[ruby]}" ]] && app[ruby]="$(koopa_locate_ruby)"
    str="$("${app[ruby]}" -e 'print Gem.ruby_api_version')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_tex_version() { # {{{1
    # """
    # TeX version (release year).
    # @note Updated 2022-03-18.
    #
    # @section Release year parsing:
    #
    # We're checking the TeX Live release year here.
    # Here's what it looks like on Debian/Ubuntu:
    # TeX 3.14159265 (TeX Live 2017/Debian)
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [tex]="${1:-}"
    )
    [[ -z "${app[tex]}" ]] && app[tex]="$(koopa_locate_tex)"
    str="$( \
        "${app[tex]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d '(' -f '2' \
            | "${app[cut]}" -d ')' -f '1' \
            | "${app[cut]}" -d ' ' -f '3' \
            | "${app[cut]}" -d '/' -f '1' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_vim_version() { # {{{1
    # """
    # Vim version.
    # @note Updated 2022-03-18.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [vim]="${1:-}"
    )
    [[ -z "${app[vim]}" ]] && app[vim]="$(koopa_locate_vim)"
    declare -A dict=(
        [str]="$("${app[vim]}" --version 2>/dev/null)"
    )
    dict[maj_min]="$( \
        koopa_print "${dict[str]}" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '5' \
    )"
    dict[out]="${dict[maj_min]}"
    if koopa_str_detect_fixed \
        --string="${dict[str]}" \
        --pattern='Included patches:'
    then
        dict[patch]="$( \
            koopa_print "${dict[str]}" \
                | koopa_grep --pattern='Included patches:' \
                | "${app[cut]}" -d '-' -f '2' \
                | "${app[cut]}" -d ',' -f '1' \
        )"
        dict[out]="${dict[out]}.${dict[patch]}"
    fi
    koopa_print "${dict[out]}"
    return 0
}
