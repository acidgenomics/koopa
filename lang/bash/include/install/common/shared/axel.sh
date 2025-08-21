#!/usr/bin/env bash

# NOTE Hitting build errors with 2.17.12 on macOS:
#
# 1 error generated.
# gmake[2]: *** [Makefile:767: src/axel-random.o] Error 1
# gmake[2]: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/tmp.ikHlYXZ9jB/src'
# gmake[1]: *** [Makefile:914: all-recursive] Error 1
# gmake[1]: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/tmp.ikHlYXZ9jB/src'
# gmake: *** [Makefile:464: all] Error 2

main() {
    # """
    # Install axel.
    # @note Updated 2024-01-30.
    #
    # @seealso
    # - https://github.com/axel-download-accelerator/axel
    # - https://formulae.brew.sh/formula/axel
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps+=('gawk' 'pkg-config')
    deps+=('gettext' 'openssl')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args+=(
        '--disable-silent-rules'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/axel-download-accelerator/axel/releases/\
download/v${dict['version']}/axel-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
