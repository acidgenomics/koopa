#!/usr/bin/env bash

main() {
    # """
    # Install Apache Portable Runtime (APR) library.
    # @note Updated 2022-09-01.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/apr.rb
    # - macOS build issue:
    #  https://bz.apache.org/bugzilla/show_bug.cgi?id=64753
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    if koopa_is_macos
    then
        koopa_activate_app --build-only 'autoconf' 'automake' 'libtool'
    fi
    koopa_activate_app 'sqlite'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    if koopa_is_macos
    then
        app['autoreconf']="$(koopa_locate_autoreconf)"
        app['patch']="$(koopa_locate_patch)"
        [[ -x "${app['autoreconf']}" ]] || return 1
        [[ -x "${app['patch']}" ]] || return 1
    fi
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='apr'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://archive.apache.org/dist/\
${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
    )
    if koopa_is_macos
    then
        # Apply r1871981 which fixes a compile error on macOS 11.0.
        koopa_cd "${dict['name']}-${dict['version']}"
        koopa_download \
            "https://raw.githubusercontent.com/Homebrew/\
formula-patches/7e2246542543bbd3111a4ec29f801e6e4d538f88/\
apr/r1871981-macos11.patch" \
            'patch1.patch'
        "${app['patch']}" \
            --input='patch1.patch' \
            --strip=0 \
            --verbose
        # Apply r1882980+1882981 to fix implicit exit() declaration
        # Remove with the next release, along with autoconf dependency.
        koopa_cd ..
        koopa_download \
            "https://raw.githubusercontent.com/Homebrew/\
formula-patches/fa29e2e398c638ece1a72e7a4764de108bd09617/apr/\
r1882980%2B1882981-configure.patch" \
            'patch2.patch'
        "${app['patch']}" \
            --input='patch2.patch' \
            --strip=0 \
            --verbose
        koopa_cd "${dict['name']}-${dict['version']}"
        koopa_rm 'configure'
        # This step requires autoconf, automake, and libtool.
        "${app['autoreconf']}" --install
        koopa_cd ..
    fi
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
