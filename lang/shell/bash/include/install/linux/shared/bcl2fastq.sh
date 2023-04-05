#!/usr/bin/env bash

# FIXME This is currently failing to build on Ubuntu 20.
# NOTE May need to compile against a much older GCC (e.g. 4.8.2).

main() {
    # """
    # Install bcl2fastq from source.
    # @note Updated 2022-03-27.
    #
    # This uses CMake to install.
    # ARM is not yet supported for this.
    #
    # @seealso
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
    local app conf_args deps dict
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_not_aarch64
    koopa_activate_app --build-only 'make'
    deps=(
        'bzip2'
        'icu4c'
        'xz'
        'zlib'
        'zstd'
    )
    koopa_activate_app "${deps[@]}"
    app['aws']="$(koopa_locate_aws --allow-system)"
    app['cmake']="$(koopa_locate_cmake --realpath)"
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['aws']}" ]] || exit 1
    [[ -x "${app['cmake']}" ]] || exit 1
    [[ -x "${app['make']}" ]] || exit 1
    dict['arch']="$(koopa_arch)"
    dict['icu4c']="$(koopa_app_prefix 'icu4c')"
    dict['installers_base']="$(koopa_private_installers_s3_uri)"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='bcl2fastq'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_macos
    then
        dict['toolset']='clang'
    else
        dict['toolset']='gcc'
    fi
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['c_include_path']="/usr/include/${dict['arch']}-linux-gnu"
    koopa_assert_is_dir "${dict['c_include_path']}"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['file']="${dict['version']}.tar.zip"
    dict['url']="${dict['installers_base']}/${dict['name']}/src/${dict['file']}"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_extract "${dict['name']}${dict['maj_ver']}-"*"-Source.tar.gz"
    # Install Boost 1.54.0 from 'redist'.
    # Refer to 'src/cmake/bootstrap/installBoost.sh'.
    (
        local b2_args bootstrap_args
        bootstrap_args=(
            "--prefix=${dict['libexec']}/boost"
            "--libdir=${dict['libexec']}/boost/lib"
            "--with-toolset=${dict['toolset']}"
            "--with-icu=${dict['icu4c']}"
            '--without-libraries=log,mpi,python'
        )
        b2_args=(
            '-q'
            # Show commands as they are executed.
            '-d+2'
            "-j${dict['jobs']}"
            "--prefix=${dict['prefix']}"
            "--libdir=${dict['prefix']}/lib"
            "toolset=${dict['toolset']}"
            'variant=release'
            'link=shared,static'
            'threading=multi'
            'runtime-link=shared'
            # This is 'koopa_activate_app' 'pkg-config --cflags' return.
            # NOTE We should consider renaming this variable during
            # installation, to avoid confusing between CPPFLAGS and CXXFLAGS.
            "cxxflags=${CPPFLAGS:?}"
            # This is 'koopa_activate_app' 'pkg-config --libs-only-L' return.
            "linkflags=${LDFLAGS:?}"
            'install'
        )
        koopa_cp \
            'bcl2fastq/redist/boost_1_54_0.tar.bz2' \
            'boost_1_54_0.tar.bz2'
        koopa_extract 'boost_1_54_0.tar.bz2'
        koopa_cd 'boost_1_54_0'
        ./bootstrap.sh --help
        ./bootstrap.sh "${bootstrap_args[@]}"
        ./b2 --help
        ./b2 "${b2_args[@]}"
        return 0
    )
    koopa_cd "${dict['name']}"
    koopa_mkdir "${dict['name']}-build"
    koopa_cd "${dict['name']}-build"
    export C_INCLUDE_PATH="${dict['c_include_path']}"
    koopa_print_env
    conf_args=(
        '--build-type=Release'
        "--parallel=${dict['jobs']}"
        "--prefix=${dict['prefix']}"
        '--verbose'
        "--with-cmake=${app['cmake']}"
        '--without-unit-tests'
        "BOOST_ROOT=${dict['libexec']}/boost"
    )
    ../src/configure --help
    ../src/configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    koopa_rm "${dict['prefix']}/bin/test"
    return 0
}
