#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_gnu_app() { # {{{1
    # """
    # Build and install a GNU package from source.
    # @note Updated 2021-05-05.
    # """
    koopa::assert_has_args "$#"
    koopa::install_app --installer='gnu-app' "$@"
    return 0
}

koopa:::install_gnu_app() { # {{{1
    # """
    # Install GNU package.
    # @note Updated 2021-05-26.
    #
    # Positional arguments are passed to 'conf_args' array.
    # """
    local conf_args file gnu_mirror jobs make name prefix suffix url version
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    gnu_mirror="$(koopa::gnu_mirror_url)"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    case "$name" in
        groff|gsl|make|ncurses|patch|tar|wget)
            suffix='gz'
            ;;
        parallel)
            suffix='bz2'
            ;;
        *)
            suffix='xz'
            ;;
    esac
    file="${name}-${version}.tar.${suffix}"
    url="${gnu_mirror}/${name}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    conf_args=("--prefix=${prefix}" "$@")
    ./configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    # > "$make" check
    "$make" install
    return 0
}

koopa::install_autoconf() { # {{{1
    local conf_args
    conf_args=(
        '--name=autoconf'
    )
    # m4 is required for automake to build.
    if koopa::is_macos
    then
        conf_args+=(
            '--homebrew-opt=m4'
        )
    fi
    koopa::install_gnu_app "${conf_args[@]}" "$@"
}

koopa::install_automake() { # {{{1
    local conf_args
    conf_args=(
        '--name=automake'
        '--opt=autoconf'
    )
    koopa::install_gnu_app "${conf_args[@]}" "$@"
}

koopa::install_binutils() { # {{{1
    koopa::install_gnu_app \
        --name='binutils' \
        "$@"
}

koopa::install_coreutils() { # {{{1
    koopa::install_gnu_app \
        --name='coreutils' \
        "$@"
}

koopa::install_findutils() { # {{{1
    if koopa::is_macos
    then
        # Workaround for build failures in 4.8.0.
        # See also:
        # - https://github.com/Homebrew/homebrew-core/blob/master/
        #     Formula/findutils.rb
        # - https://lists.gnu.org/archive/html/bug-findutils/2021-01/
        #     msg00050.html
        # - https://lists.gnu.org/archive/html/bug-findutils/2021-01/
        #     msg00051.html
        export CFLAGS='-D__nonnull\(params\)='
    fi
    koopa::install_gnu_app \
        --name='findutils' \
        "$@"
}

koopa::install_gawk() { # {{{1
    koopa::install_gnu_app \
        --name='gawk' \
        "$@"
}

# NOTE Consider adding support for pcre here.
koopa::install_grep() { # {{{1
    koopa::install_gnu_app \
        --name='grep' \
        "$@"
}

koopa::install_groff() { # {{{1
    koopa::install_gnu_app \
        --name='groff' \
        "$@"
}

koopa::install_gsl() { # {{{1
    koopa::install_gnu_app \
        --name='gsl' \
        --name-fancy='GSL' \
        "$@"
}

koopa::install_libtool() { # {{{1
    koopa::install_gnu_app \
        --name='libtool' \
        "$@"
}

koopa::install_make() { # {{{1
    koopa::install_gnu_app \
        --name='make' \
        "$@"
}

koopa::install_ncurses() { # {{{1
    koopa::install_gnu_app \
        --name='ncurses' \
        "$@"
}

koopa::install_parallel() { # {{{1
    koopa::install_gnu_app \
        --name='parallel' \
        "$@"
}

koopa::install_patch() { # {{{1
    koopa::install_gnu_app \
        --name='patch' \
        "$@"
}

koopa::install_sed() { # {{{1
    koopa::install_gnu_app \
        --name='sed' \
        "$@"
}

koopa::install_tar() { # {{{1
    koopa::install_gnu_app \
        --name='tar' \
        "$@"
}

koopa::install_texinfo() { # {{{1
    koopa::install_gnu_app \
        --name='texinfo' \
        "$@"
}
