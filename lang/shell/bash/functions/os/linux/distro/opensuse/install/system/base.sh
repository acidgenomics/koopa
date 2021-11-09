#!/usr/bin/env bash

koopa::opensuse_install_base() { # {{{1
    # """
    # Install openSUSE base system.
    # @note Updated 2021-10-31.
    #
    # zypper cheat sheet:
    # https://en.opensuse.org/images/1/17/Zypper-cheat-sheet-1.pdf
    # """
    local app dict name_fancy pkgs pos
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [zypper]="$(koopa::locate_zypper)"
    )
    declare -A dict=(
        [base]=1
        [dev]=1
        [extra]=0
        [recommended]=1
        [upgrade]=1
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--base-image')
                dict[base]=1
                dict[dev]=0
                dict[extra]=0
                dict[recommended]=0
                dict[upgrade]=0
                shift 1
                ;;
            '--default' | \
            '--recommended')
                shift 1
                ;;
            '--full')
                dict[base]=1
                dict[dev]=1
                dict[extra]=1
                dict[recommended]=1
                dict[upgrade]=1
                shift 1
                ;;
            '')
                shift 1
                ;;
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_args "$#"
    name_fancy='openSUSE base system'
    koopa::install_start "$name_fancy"
    pkgs=()
    "${app[sudo]}" "${app[zypper]}" refresh
    if [[ "${dict[upgrade]}" -eq 1 ]]
    then
        "${app[sudo]}" "${app[zypper]}" --non-interactive update
    fi
    if [[ "${dict[base]}" -eq 1 ]]
    then
        pkgs+=(
            'autoconf'
            'bc'
            'bzip2'
            'cmake'
            'curl'
            'gcc'
            'gcc-c++'
            'gcc-fortran'
            'gettext'
            'git'
            'glibc-i18ndata'
            'gzip'
            'make'
            'man'
            'procps'  # ps
            'sudo'
            'tar'
            'unzip'
            'wget'
            'which'
            'xz'
        )
    fi
    if [[ "${dict[recommended]}" -eq 1 ]]
    then
        pkgs+=(
            # > R-base
            # > R-base-devel
            # > texlive
            'texinfo'
            'tree'
            'zsh'
        )
    fi
    if [[ "${dict[dev]}" -eq 1 ]]
    then
        pkgs+=(
            'gettext-devel'
            'gmp-devel'
            'libbz2-devel'
            'libcurl-devel'
            'libevent-devel'
            'libffi-devel'
            'libxml2-devel'
            'lzma-devel'
            'mpc-devel'
            'mpfr-devel'
            'ncurses-devel'
            'openssl-devel'
            'pcre2-devel'
            'readline-devel'
            'zlib-devel'
        )
    fi
    "${app[sudo]}" "${app[zypper]}" install -y "${pkgs[@]}"
    "${app[sudo]}" "${app[zypper]}" clean
    koopa::install_success "$name_fancy"
    return 0
}

