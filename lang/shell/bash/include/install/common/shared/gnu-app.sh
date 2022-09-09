#!/usr/bin/env bash

main() {
    # """
    # Build and install a GNU package from source.
    # @note Updated 2022-09-08.
    #
    # Positional arguments are passed to 'conf_args' array.
    # """
    local app conf_args dict
    koopa_activate_build_opt_prefix 'pkg-config'
    declare -A dict=(
        ['gnu_mirror']="$(koopa_gnu_mirror_url)"
        ['jobs']="$(koopa_cpu_count)"
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    declare -A app
    case "${dict['name']}" in
        'make')
            app['make']="$(koopa_locate_make --allow-system)"
            ;;
        *)
            app['make']="$(koopa_locate_make)"
            ;;
    esac
    [[ -x "${app['make']}" ]] || return 1
    dict['name2']="${dict['name']}"
    conf_args=("--prefix=${dict['prefix']}" "$@")
    case "${dict['name']}" in
        'freetype' | \
        'man-db')
            dict['gnu_mirror']='https://download.savannah.gnu.org/releases'
            ;;
        'attr' | \
        'libpipeline')
            dict['gnu_mirror']='https://download.savannah.nongnu.org/releases'
            ;;
    esac
    case "${dict['name']}" in
        'aspell' | \
        'attr' | \
        'bc' | \
        'gdbm' | \
        'gperf' | \
        'groff' | \
        'gsl' | \
        'gzip' | \
        'less' | \
        'libiconv' | \
        'libidn' | \
        'libpipeline' | \
        'libtasn1' | \
        'libunistring' | \
        'make' | \
        'mpc' | \
        'ncurses' | \
        'nettle' | \
        'patch' | \
        'pth' | \
        'readline' | \
        'stow' | \
        'tar' | \
        'units' | \
        'wget' | \
        'which')
            dict['suffix']='gz'
            ;;
        'parallel')
            dict['suffix']='bz2'
            ;;
        *)
            dict['suffix']='xz'
            ;;
    esac
    case "${dict['name']}" in
        'libidn')
            dict['name2']='libidn2'
            ;;
        'ncurses')
            dict['version']="$(koopa_major_minor_version "${dict['version']}")"
            ;;
    esac
    dict['file']="${dict['name2']}-${dict['version']}.tar.${dict['suffix']}"
    dict['url']="${dict['gnu_mirror']}/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name2']}-${dict['version']}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # > "${app['make']}" check || true
    "${app['make']}" install
    return 0
}
