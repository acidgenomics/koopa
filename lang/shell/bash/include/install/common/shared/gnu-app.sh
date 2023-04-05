#!/usr/bin/env bash

main() {
    # """
    # Build and install a GNU package from source.
    # @note Updated 2023-03-22.
    #
    # Positional arguments are passed to 'conf_args' array.
    # """
    local app conf_args dict
    local -A dict=(
        ['gnu_mirror']="$(koopa_gnu_mirror_url)"
        ['jobs']="$(koopa_cpu_count)"
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    local -A app
    case "${dict['name']}" in
        'make')
            app['make']="$(koopa_locate_make --allow-system)"
            ;;
        *)
            koopa_activate_app --build-only 'pkg-config'
            app['make']="$(koopa_locate_make)"
            ;;
    esac
    [[ -x "${app['make']}" ]] || exit 1
    dict['name2']="${dict['name']}"
    conf_args=("--prefix=${dict['prefix']}" "$@")
    # Alternative URLs:
    # - https://download.savannah.gnu.org/releases
    # - https://download.savannah.nongnu.org/releases
    case "${dict['name']}" in
        'attr' | \
        'freetype' | \
        'libpipeline' | \
        'lzip' | \
        'man-db')
            dict['gnu_mirror']='https://mirrors.sarata.com/non-gnu'
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
        'lzip' | \
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
        'ed')
            dict['suffix']='lz'
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
    # This is necessary to install some apps (e.g. tar) from root user. This
    # is very useful for Latch Pods configuration.
    export FORCE_UNSAFE_CONFIGURE=1
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    # Ensure we deparallize any problematic programs (e.g. binutils).
    case "${dict['name']}" in
        'binutils')
            koopa_is_linux && dict['jobs']=1
            ;;
    esac
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # > "${app['make']}" check || true
    "${app['make']}" install
    return 0
}
