#!/usr/bin/env bash

main() {
    # """
    # Install OpenBLAS.
    # @note Updated 2022-11-09.
    #
    # Attempting to make in parallel can cause installer to crash.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     openblas.rb
    # - https://ports.macports.org/port/OpenBLAS/details/
    # - https://iq.opengenus.org/install-openblas-from-source/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'gcc'
    declare -A app=(
        ['gcc']="$(koopa_locate_gcc --realpath)"
        ['gfortran']="$(koopa_locate_gfortran --realpath)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['gcc']}" ]] || return 1
    [[ -x "${app['gfortran']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='OpenBLAS'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/xianyi/${dict['name']}/archive/\
${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # Ensure target OS build version is consistency.
    # > export MACOSX_DEPLOYMENT_TARGET='FIXME'
    # > export TARGET='FIXME'
    export DYNAMIC_ARCH=1
    # Force a large 'NUM_THREADS' to support larger Macs with more cores
    # available than our builder instance.
    export NUM_THREADS=56
    export USE_OPENMP=1
    koopa_print_env
    # NOTE Need to deparallelize here, otherwise build will fail on macOS.
    "${app['make']}" VERBOSE=1 --jobs=1 \
        "CC=${app['gcc']}" \
        "FC=${app['gfortran']}" \
        'libs' 'netlib' 'shared'
    "${app['make']}" "PREFIX=${dict['prefix']}" install
    (
        koopa_cd "${dict['prefix']}/lib"
        koopa_ln \
            "libopenblas.${dict['shared_ext']}" \
            "libblas.${dict['shared_ext']}"
        koopa_ln \
            "libopenblas.${dict['shared_ext']}" \
            "liblapack.${dict['shared_ext']}"
    )
    return 0
}
