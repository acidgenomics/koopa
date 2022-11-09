#!/usr/bin/env bash

# FIXME This is now failing on macOS 13 with XCode 14.1...

main() {
    # """
    # Install OpenBLAS.
    # @note Updated 2022-08-16.
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
        # FIXME ['jobs']="$(koopa_cpu_count)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/xianyi/${dict['name']}/archive/\
${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # FIXME Need to optimize these...
    # The build log has many warnings of macOS build version mismatches.
    # > ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version
    # Setting `DYNAMIC_ARCH` is broken with binutils 2.38.
    # https://github.com/xianyi/OpenBLAS/issues/3708
    # https://sourceware.org/bugzilla/show_bug.cgi?id=29435
    # > ENV["DYNAMIC_ARCH"] = "1" if OS.mac?
    # > ENV["USE_OPENMP"] = "1"
    # Force a large NUM_THREADS to support larger Macs than the VMs that build the bottles
    # > ENV["NUM_THREADS"] = "56"
    # > ENV["TARGET"] = case Hardware.oldest_cpu
    koopa_print_env
    # FIXME Is parallelization problematic?
    # --jobs="${dict['jobs']}" \
    "${app['make']}" VERBOSE=1 --jobs=1 \
        "CC=${app['gcc']}" \
        "FC=${app['gfortran']}" \
        'libs' 'netlib' 'shared'
    "${app['make']}" "PREFIX=${dict['prefix']}" install
    # FIXME Need to add these steps:
    # > lib.install_symlink shared_library("libopenblas") => shared_library("libblas")
    # > lib.install_symlink shared_library("libopenblas") => shared_library("liblapack")
    return 0
}
