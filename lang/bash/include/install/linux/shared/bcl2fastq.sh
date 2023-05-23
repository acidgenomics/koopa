#!/usr/bin/env bash

# FIXME Now we're hitting that installer isn't picking up gzip correctly.
#
#CMake Error at cmake/cxxConfigure.cmake:75 (message):
#   No support for gzip compression
# Call Stack (most recent call first):
#   cxx/CMakeLists.txt:33 (include)

main() {
    # """
    # Install bcl2fastq from source.
    # @note Updated 2023-05-23.
    #
    # ARM is not yet supported.
    #
    # @seealso
    # Conda approach:
    # - https://anaconda.org/dranew/bcl2fastq/files
    # - https://conda.io/projects/conda/en/latest/user-guide/tasks/
    #     manage-environments.html
    #
    # Docker image approaches:
    # - https://github.com/Zymo-Research/docker-bcl2fastq/
    # - https://hub.docker.com/r/umccr/bcl2fastq
    # - https://alexandria-scrna-data-library.readthedocs.io/en/latest/
    #     bcl2fastq.html
    #
    # Building from source (problematic with newer GCC / clang):
    # - https://gist.github.com/jblachly/f8dc0f328d66659d9ee005548a5a2d2e
    # - https://sarahpenir.github.io/linux/Installing-bcl2fastq/
    # - https://github.com/rossigng/easybuild-easyconfigs/blob/main/
    #     easybuild/easyconfigs/b/bcl2fastq2/
    # - https://github.com/perllb/ctg-wgs/blob/master/
    #     container/ngs-tools-builder
    # - https://github.com/AlexsLemonade/alsf-scpca/blob/main/images/
    #     cellranger/install-bcl2fastq.sh
    # - Potential method for disabling ICU in Boost build (if necessary):
    #   https://stackoverflow.com/questions/31138251/building-boost-without-icu
    # """
    local -A app dict
    local -a cmake_args conf_args
    koopa_assert_is_not_aarch64
    app['aws']="$(koopa_locate_aws --allow-system)"
    app['conda']="$(koopa_locate_conda --realpath)"
    app['sort']="$(koopa_locate_sort --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['installers_base']="$(koopa_private_installers_s3_uri)"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['gcc_version']='8.5.0'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['conda_file']='conda.yaml'
    read -r -d '' "dict[conda_string]" << END || true
name: bcl2fastq
dependencies:
    - bzip2
    - gcc==${dict['gcc_version']}
    - gfortran==${dict['gcc_version']}
    - gxx==${dict['gcc_version']}
    - gzip
    - make
    - zlib
END
    koopa_alert "Preparing conda environment in '${dict['libexec']}'."
    koopa_print "${dict['conda_string']}"
    koopa_write_string \
        --file="${dict['conda_file']}" \
        --string="${dict['conda_string']}"
    koopa_conda_create_env \
        --file="${dict['conda_file']}" \
        --prefix="${dict['libexec']}"
    app['conda_make']="${dict['libexec']}/bin/make"
    app['conda_cc']="${dict['libexec']}/bin/gcc"
    app['conda_cxx']="${dict['libexec']}/bin/g++"
    koopa_assert_is_executable "${app[@]}"
    dict['sysroot']="${dict['libexec']}/x86_64-conda-linux-gnu/sysroot"
    koopa_assert_is_dir \
        "${dict['sysroot']}" \
        "${dict['sysroot']}/usr/include"
    # The bcl2fastq installer looks for gmake, so make sure we symlink this.
    (
        koopa_cd "${dict['libexec']}/bin"
        koopa_ln 'make' 'gmake'
    )
    dict['url']="${dict['installers_base']}/bcl2fastq/src/\
${dict['version']}.tar.zip"
    "${app['aws']}" --profile='acidgenomics' s3 cp \
        "${dict['url']}" "$(koopa_basename "${dict['url']}")"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'unzip'
    koopa_extract 'unzip/'*'.tar.gz' 'bcl2fastq'
    koopa_cd 'bcl2fastq'
    koopa_mkdir 'build'
    koopa_cd 'build'
    koopa_conda_activate_env "${dict['libexec']}"
    # > export BOOST_ROOT="${dict['conda_boost']}"
    export CC="${app['conda_cc']}"
    export CPPFLAGS="-I${dict['libexec']}/include"
    export CXX="${app['conda_cxx']}"
    export C_INCLUDE_PATH="${dict['sysroot']}/usr/include"
    export LDFLAGS="-L${dict['libexec']}/lib"
    cmake_args=(
        "-DCMAKE_CXX_FLAGS=${CXXFLAGS:-} ${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-} ${CPPFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SYSROOT=${dict['sysroot']}"
    )
    conf_args=(
        '--build-type=Release'
        "--parallel=${dict['jobs']}"
        "--prefix=${dict['prefix']}"
        '--verbose'
        # > "--with-cmake=${app['conda_cmake']}"
        '--without-unit-tests'
        "CMAKE_OPTIONS=${cmake_args[*]}"
    )
    koopa_print_env
    ../src/configure --help || true
    ../src/configure "${conf_args[@]}"
    "${app['conda_make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['conda_make']}" install
    return 0
}
