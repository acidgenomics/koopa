#!/usr/bin/env bash

main() {
    # """
    # Install OpenBLAS.
    # @note Updated 2023-03-26.
    #
    # Attempting to make in parallel can cause installer to crash.
    #
    # @seealso
    # - https://github.com/conda-forge/openblas-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     openblas.rb
    # - https://github.com/macports/macports-ports/blob/master/math/
    #     OpenBLAS/Portfile
    # - https://iq.opengenus.org/install-openblas-from-source/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'gcc'
    local -A app=(
        ['cc']='/usr/bin/gcc'
        ['fc']="$(koopa_locate_gfortran --realpath)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['cc']}" ]] || exit 1
    [[ -x "${app['fc']}" ]] || exit 1
    [[ -x "${app['make']}" ]] || exit 1
    local -A dict=(
        ['name']='OpenBLAS'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    if koopa_is_macos
    then
        # clang doesn't support this currently.
        dict['use_openmp']=0
    else
        dict['use_openmp']=1
    fi
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/xianyi/${dict['name']}/archive/\
${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    read -r -d '' "dict[makefile_string]" << END || true
CC=${app['cc']}
FC=${app['fc']}
NUM_THREADS=56
USE_OPENMP=${dict['use_openmp']}
END
    koopa_append_string \
        --file='Makefile.rule' \
        --string="${dict['makefile_string']}"
    koopa_print_env
    "${app['make']}" VERBOSE=1 --jobs=1 \
        'libs' \
        'netlib' \
        'shared'
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
