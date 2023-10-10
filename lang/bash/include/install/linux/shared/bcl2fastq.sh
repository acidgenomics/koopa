#!/usr/bin/env bash

main() {
    # """
    # Install bcl2fastq from source.
    # @note Updated 2023-05-24.
    #
    # ARM is not yet supported for this.
    #
    # @section Conda approach:
    #
    # - https://anaconda.org/dranew/bcl2fastq/files
    # - https://conda.io/projects/conda/en/latest/user-guide/tasks/
    #     manage-environments.html
    #
    # @section Docker image approaches:
    #
    # - https://github.com/Zymo-Research/docker-bcl2fastq/
    # - https://hub.docker.com/r/umccr/bcl2fastq
    # - https://alexandria-scrna-data-library.readthedocs.io/en/latest/
    #     bcl2fastq.html
    #
    # @section Building from source:
    #
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
    # - Notes about gzip error:
    #   https://www.seqanswers.com/forum/bioinformatics/bioinformatics-aa/
    #     22850-bcl2fastq-1-8-3-install-error-on-ubuntu-12-04lts-no-support-
    #     for-bzip2-compression
    # - https://stackoverflow.com/questions/36195791/
    # - https://bear-apps.bham.ac.uk/applications/2022a/bcl2fastq2/
    #     2.20.0-GCC-11.3.0/
    # """
    local -A app dict
    local -a build_deps cmake_args cmake_std_args conf_args deps
    if [[ ! -f '/usr/include/zlib.h' ]]
    then
        koopa_stop 'System zlib is required.'
    fi
    koopa_assert_is_not_aarch64
    build_deps=('cmake' 'make')
    ! koopa_is_macos && deps+=('bzip2')
    deps+=('icu4c' 'xz' 'zlib' 'zstd')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['aws']="$(koopa_locate_aws --allow-system)"
    app['cmake']="$(koopa_locate_cmake)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch)"
    dict['icu4c']="$(koopa_app_prefix 'icu4c')"
    dict['installers_base']="$(koopa_private_installers_s3_uri)"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['c_include_path']="/usr/include/${dict['arch']}-linux-gnu"
    koopa_assert_is_dir "${dict['c_include_path']}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['url']="${dict['installers_base']}/bcl2fastq/src/\
${dict['version']}.tar.zip"
    "${app['aws']}" --profile='acidgenomics' s3 cp \
        "${dict['url']}" "$(koopa_basename "${dict['url']}")"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'unzip'
    koopa_extract 'unzip/'*'.tar.gz' 'src'
    koopa_rm 'unzip'
    koopa_cd 'src'
    koopa_mkdir 'build'
    koopa_cd 'build'
    readarray -t cmake_std_args <<< "$( \
        koopa_cmake_std_args --prefix="${dict['prefix']}"
    )"
    for arg in "${cmake_std_args[@]}"
    do
        # Exclude these arguments.
        case "$arg" in
            '-DCMAKE_BUILD_TYPE='* | \
            '-DCMAKE_INSTALL_PREFIX='* | \
            '-DCMAKE_PARALLEL='* | \
            '-DCMAKE_VERBOSE_MAKEFILE='*)
                continue
                ;;
        esac
        # Ensure that values are enclosed in single quotes.
        arg="${arg//=/=\'}'"
        cmake_args+=("$arg")
    done
    export BOOST_ROOT="${dict['libexec']}/boost"
    export CMAKE_OPTIONS="${cmake_args[*]}"
    export C_INCLUDE_PATH="${dict['c_include_path']}"
    koopa_print_env
    conf_args=(
        '--build-type=Release'
        "--parallel=${dict['jobs']}"
        "--prefix=${dict['prefix']}"
        '--verbose'
        "--with-cmake=${app['cmake']}"
        '--without-unit-tests'
    )
    ../src/configure --help || true
    ../src/configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
