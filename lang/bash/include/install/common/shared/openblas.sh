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
    _koopa_activate_app --build-only 'make' 'pkg-config'
    app['cc']="$(_koopa_locate_cc --only-system)"
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(_koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if _koopa_is_macos
    then
        # clang doesn't support this currently.
        bool['use_openmp']=0
    else
        bool['use_openmp']=1
    fi
    dict['url']="https://github.com/xianyi/OpenBLAS/archive/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    read -r -d '' "dict[makefile_string]" << END || true
CC=${app['cc']}
NOFORTRAN=1
NUM_THREADS=56
USE_OPENMP=${bool['use_openmp']}
END
    _koopa_append_string \
        --file='Makefile.rule' \
        --string="${dict['makefile_string']}"
    _koopa_print_env
    "${app['make']}" VERBOSE=1 --jobs=1 libs netlib shared
    "${app['make']}" "PREFIX=${dict['prefix']}" install
    (
        _koopa_cd "${dict['prefix']}/lib"
        # Manually delete static libraries.
        _koopa_rm ./*.a
        _koopa_ln \
            "libopenblas.${dict['shared_ext']}" \
            "libblas.${dict['shared_ext']}"
        # Only can add this when fortran is enabled.
        # > _koopa_ln \
        # >     "libopenblas.${dict['shared_ext']}" \
        # >     "liblapack.${dict['shared_ext']}"
    )
    return 0
}
