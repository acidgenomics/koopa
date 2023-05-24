#!/usr/bin/env bash

# FIXME This currently requires system zlib on Linux.

# FIXME This older version of boost won't build with newer versions of GCC.
# Consider building only on an old instance of Fedora / CentOS (e.g. 6).

# FIXME Hitting cryptic error during boost bootstrapping on Ubuntu 22.
# ...failed updating 1 target...

# ./boost/regex/v4/regex_raw_buffer.hpp: In member function 'void* boost::re_detail::raw_storage::extend(boost::re_detail::raw_storage::size_type)':
# ./boost/regex/v4/regex_raw_buffer.hpp:132:24: warning: ISO C++17 does not allow 'register' storage class specifier [-Wregister]
#   132 |       register pointer result = end;
#       |                        ^~~~~~

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
    local -a conf_args deps
    koopa_assert_is_not_aarch64
    koopa_activate_app --build-only 'cmake' 'make'
    deps=('bzip2' 'icu4c' 'xz' 'zlib' 'zstd')
    koopa_activate_app "${deps[@]}"
    app['aws']="$(koopa_locate_aws --allow-system)"
    app['cmake']="$(koopa_locate_cmake)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['icu4c']="$(koopa_app_prefix 'icu4c')"
    dict['installers_base']="$(koopa_private_installers_s3_uri)"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_linux
    then
        dict['arch']="$(koopa_arch)"
        dict['c_include_path']="/usr/include/${dict['arch']}-linux-gnu"
        koopa_assert_is_dir "${dict['c_include_path']}"
        dict['toolset']='gcc'
    elif koopa_is_macos
    then
        dict['toolset']='clang'
    fi
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
    readarray -t cmake_args <<< "$( \
        koopa_cmake_std_args --prefix="${dict['prefix']}"
    )"
    export BOOST_ROOT="${dict['libexec']}/boost"
    export CMAKE_OPTIONS="${cmake_args[*]}"
    if koopa_is_linux
    then
        export C_INCLUDE_PATH="${dict['c_include_path']}"
    fi
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
    koopa_rm "${dict['prefix']}/bin/test"
    return 0
}
