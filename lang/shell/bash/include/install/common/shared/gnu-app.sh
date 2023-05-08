#!/usr/bin/env bash

# FIXME Rework this to use our 'make_build' function.

main() {
    # """
    # Build and install a GNU package from source.
    # @note Updated 2023-05-08.
    #
    # Positional arguments are passed to 'conf_args' array.
    # """
    local -A app dict
    local -a conf_args
    dict['gnu_mirror']="$(koopa_gnu_mirror_url)"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    case "${dict['name']}" in
        'make')
            app['make']="$(koopa_locate_make --only-system)"
            ;;
        *)
            koopa_activate_app --build-only 'make' 'pkg-config'
            app['make']="$(koopa_locate_make)"
            ;;
    esac
    koopa_assert_is_executable "${app[@]}"
    dict['name2']="${dict['name']}"
    conf_args=("--prefix=${dict['prefix']}")
    [[ "$#" -gt 0 ]] && conf_args+=("$@")
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
        'binutils')
            koopa_is_linux && dict['jobs']=1
            ;;
        'libidn')
            dict['name2']='libidn2'
            ;;
        'ncurses')
            dict['version']="$(koopa_major_minor_version "${dict['version']}")"
            ;;
    esac
    export FORCE_UNSAFE_CONFIGURE=1
    dict['url']="${dict['gnu_mirror']}/${dict['name']}/\
${dict['name2']}-${dict['version']}.tar.${dict['suffix']}"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
