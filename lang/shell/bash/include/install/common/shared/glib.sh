#!/usr/bin/env bash

# FIXME This now has a cryptic build error on Ubuntu 22.
# This seems related to gettext.

# FIXME Need to rework using CMake-based build config.
# Now hitting this issue with package trying to install pcre2...
#
# r "sys/syscall.h" has symbol "SYS_sched_getattr" : NO
# Checking if "pthread_setname_np(const char*)" with dependency threads: links: YES
# Checking if "stack grows check" runs: NO (1)
# Run-time dependency iconv found: YES
# Found pkg-config: /opt/koopa/app/pkg-config/0.29.2/bin/pkg-config (0.29.2)
# Did not find CMake 'cmake'
# Found CMake: NO
# Run-time dependency libpcre2-8 found: NO (tried pkgconfig, framework and cmake)
# Run-time dependency libpcre2-8 found: NO (tried pkgconfig, framework and cmake)
# Looking for a fallback subproject for the dependency libpcre2-8
# Downloading pcre2 source from https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.bz2
# <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:997)>
# WARNING: failed to download with error: could not get https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.bz2 is the internet available?. Trying after a delay...
# <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:997)>
# WARNING: failed to download with error: could not get https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.bz2 is the internet available?. Trying after a delay...
# <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:997)>
# WARNING: failed to download with error: could not get https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.bz2 is the internet available?. Trying after a delay...
# <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:997)>
# WARNING: failed to download with error: could not get https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.bz2 is the internet available?. Trying after a delay...
# <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:997)>
# WARNING: failed to download with error: could not get https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.bz2 is the internet available?. Trying after a delay...
# <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:997)>

main() {
    # """
    # Install glib.
    # @note Updated 2022-09-28.
    #
    # @seealso
    # - https://developer.gnome.org/glib/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/glib.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html
    # """
    local app build_deps deps meson_args dict
    build_deps=('meson' 'ninja' 'pkg-config' 'python')
    deps=('zlib')
    koopa_is_macos && deps+=('gettext')
    deps+=('libffi' 'pcre')
    koopa_activate_build_opt_prefix "${build_deps[@]}"
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['meson']="$(koopa_locate_meson)"
        ['ninja']="$(koopa_locate_ninja)"
    )
    [[ -x "${app['meson']}" ]] || return 1
    [[ -x "${app['ninja']}" ]] || return 1
    declare -A dict=(
        ['name']='glib'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://download.gnome.org/sources/${dict['name']}/\
${dict['maj_min_ver']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    koopa_print_env
    meson_args=(
        "--prefix=${dict['prefix']}"
        '--buildtype=release'
        # > '-Dgtk_doc=true'
        # > '-Dman=true'
    )
    "${app['meson']}" "${meson_args[@]}" ..
    "${app['ninja']}" -v
    "${app['ninja']}" install -v
    return 0
}
