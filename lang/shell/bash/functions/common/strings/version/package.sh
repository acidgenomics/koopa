#!/usr/bin/env bash

koopa_github_latest_release() { # {{{1
    # """
    # Get the latest release version from GitHub.
    # @note Updated 2022-03-21.
    #
    # @examples
    # > koopa_github_latest_release 'acidgenomics/koopa'
    # """
    local app repo
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [sed]="$(koopa_locate_sed)"
    )
    for repo in "$@"
    do
        local dict
        declare -A dict
        dict[repo]="$repo"
        dict[url]="https://api.github.com/repos/${dict[repo]}/releases/latest"
        dict[str]="$( \
            koopa_parse_url "${dict[url]}" \
                | koopa_grep --pattern='"tag_name":' \
                | "${app[cut]}" -d '"' -f '4' \
                | "${app[sed]}" 's/^v//' \
        )"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
}

koopa_node_package_version() { # {{{1
    # """
    # Node (NPM) package version.
    # @note Updated 2022-03-21.
    #
    # @seealso
    # - https://stackoverflow.com/questions/10972176/
    #
    # @examples
    # > koopa_node_package_version 'npm'
    # """
    local app pkg
    koopa_assert_has_args "$#"
    declare -A app=(
        [jq]="$(koopa_locate_jq)"
        [npm]="$(koopa_locate_npm)"
    )
    for pkg in "$@"
    do
        local dict
        declare -A dict
        dict[pkg]="$pkg"
        dict[str]="$( \
            "${app[npm]}" --global --json list "${dict[pkg]}" \
            | "${app[jq]}" \
                --raw-output \
                ".dependencies.${dict[pkg]}.version" \
        )"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
}

koopa_perl_package_version() { # {{{1
    # """
    # Perl package version.
    # @note Updated 2022-03-21.
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
    local app pkg
    koopa_assert_has_args "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    for pkg in "$@"
    do
        local dict
        declare -A dict
        dict[pkg]="$pkg"
        # Note that there cannot be a space after '-M' here.
        dict[str]="$( \
            "${app[perl]}" \
                -M"${dict[pkg]}" \
                -e "print \$${dict[pkg]}::VERSION .\"\n\";" \
        )"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
}

# > koopa_python_package_version() { # {{{1
# >     # """
# >     # Python package version.
# >     # @note Updated 2022-03-21.
# >     #
# >     # @examples
# >     # > koopa_python_package_version 'pip'
# >     # # 22.0.4
# >     # """
# >     local app pkg
# >     koopa_assert_has_args "$#"
# >     declare -A app=(
# >         [cut]="$(koopa_locate_cut)"
# >         [python]="$(koopa_locate_python)"
# >     )
# >     for pkg in "$@"
# >     do
# >         local dict
# >         declare -A dict
# >         dict[pkg]="$pkg"
# >         dict[str]="$( \
# >             "${app[python]}" -m pip show "${dict[pkg]}" \
# >             | koopa_grep --pattern='^Version:' --regex \
# >             | "${app[cut]}" -d ' ' -f '2' \
# >         )"
# >         [[ -n "${dict[str]}" ]] || return 1
# >         koopa_print "${dict[str]}"
# >     done
# >     return 0
# > }

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
