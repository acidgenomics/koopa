#!/usr/bin/env bash

# FIXME Need to parameterize.
koopa_github_latest_release() { # {{{1
    # """
    # Get the latest release version from GitHub.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_github_latest_release 'acidgenomics/koopa'
    # """
    local app repo str url
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [sed]="$(koopa_locate_sed)"
    )
    repo="${1:?}"
    url="https://api.github.com/repos/${repo}/releases/latest"
    str="$( \
        koopa_parse_url "$url" \
            | koopa_grep --pattern='"tag_name":' \
            | "${app[cut]}" --delimiter='"' --fields='4' \
            | "${app[sed]}" 's/^v//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

# FIXME Need to parameterize.
koopa_node_package_version() { # {{{1
    # """
    # Node (NPM) package version.
    # @note Updated 2022-03-15.
    #
    # @seealso
    # - https://stackoverflow.com/questions/10972176/
    #
    # @examples
    # > koopa_node_package_version 'gtop'
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [jq]="$(koopa_locate_jq)"
        [npm]="$(koopa_locate_npm)"
    )
    declare -A dict=(
        [pkg_name]="${1:?}"
    )
    dict[str]="$( \
        "${app[npm]}" --global --json list "${dict[pkg_name]}" \
        | "${app[jq]}" \
            --raw-output \
            ".dependencies.${dict[pkg_name]}.version" \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

# FIXME Need to parameterize.
koopa_perl_package_version() { # {{{1
    # """
    # Perl package version.
    # @note Updated 2022-03-18.
    #
    # @seealso
    # - https://www.perl.com/article/1/2013/3/24/3-quick-ways-to-find-out-the-
    #     version-number-of-an-installed-Perl-module-from-the-terminal/
    # - cpan -D <module_name>
    #
    # @examples
    # > koopa_perl_package_version 'File::Rename'
    # # 1.30
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    declare -A dict=(
        [pkg]="${1:?}"
    )
    # Note that there cannot be a space after '-M' here.
    dict[str]="$( \
        "${app[perl]}" \
            -M"${dict[pkg]}" \
            -e "print \$${dict[pkg]}::VERSION .\"\n\";" \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

# FIXME Need to parameterize.
koopa_python_package_version() { # {{{1
    # """
    # Python package version.
    # @note Updated 2022-03-18.
    #
    # @examples
    # > koopa_python_package_version 'pip'
    # # 22.0.4
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [python]="$(koopa_locate_python)"
    )
    declare -A dict=(
        [pkg]="${1:?}"
    )
    dict[str]="$( \
        "${app[python]}" -m pip show "${dict[pkg]}" \
            | koopa_grep --pattern='^Version:' --regex \
            | "${app[cut]}" --delimiter=' ' --fields='2' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

koopa_r_package_version() { # {{{1
    # """
    # R package version.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_r_package_version 'basejump'
    # """
    local app str vec
    koopa_assert_has_args "$#"
    declare -A app=(
        [rscript]="$(koopa_locate_rscript)"
    )
    pkgs=("$@")
    koopa_is_r_package_installed "${pkgs[@]}" || return 1
    vec="$(koopa_r_paste_to_vector "${pkgs[@]}")"
    str="$( \
        "${app[rscript]}" -e " \
            cat(vapply( \
                X = ${vec}, \
                FUN = function(x) { \
                    as.character(packageVersion(x)) \
                }, \
                FUN.VALUE = character(1L) \
            ), sep = '\n') \
        " \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
