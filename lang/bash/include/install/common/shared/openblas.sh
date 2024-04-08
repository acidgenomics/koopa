#!/usr/bin/env bash

main() {
    # """
    # Install OpenBLAS.
    # @note Updated 2024-04-05.
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
    # - https://github.com/OpenMathLib/OpenBLAS/issues/1628
    # """
    local -A app bool dict
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['cc']="$(koopa_locate_cc --only-system)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_macos
    then
        # clang doesn't support this currently.
        bool['use_openmp']=0
    else
        bool['use_openmp']=1
    fi
    dict['url']="https://github.com/xianyi/OpenBLAS/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    read -r -d '' "dict[makefile_string]" << END || true
CC=${app['cc']}
NOFORTRAN=1
NUM_THREADS=56
USE_OPENMP=${bool['use_openmp']}
END
    koopa_append_string \
        --file='Makefile.rule' \
        --string="${dict['makefile_string']}"
    koopa_print_env
    "${app['make']}" VERBOSE=1 --jobs=1 libs netlib shared
    "${app['make']}" "PREFIX=${dict['prefix']}" install
    (
        koopa_cd "${dict['prefix']}/lib"
        # Manually delete static libraries.
        koopa_rm ./*.a
        koopa_ln \
            "libopenblas.${dict['shared_ext']}" \
            "libblas.${dict['shared_ext']}"
        # Only can add this when fortran is enabled.
        # > koopa_ln \
        # >     "libopenblas.${dict['shared_ext']}" \
        # >     "liblapack.${dict['shared_ext']}"
    )
    return 0
}
