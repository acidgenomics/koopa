#!/usr/bin/env bash

# FIXME There's a CMake Python location issue on macOS:
# -- Found Python3: /opt/koopa/app/python3.10/3.10.8/libexec/Python.framework/Versions/3.10/bin/python3.10 (found version "3.10.8")
# [...]
# -- Found Python: /Library/Frameworks/Python.framework/Versions/3.10/bin/python3.10 (found version "3.10.8")

# FIXME Consider splitting this out into separate build steps.
# FIXME Use this later?
# > "-Dlibmamba_DIR=${dict['prefix']}/share/cmake/libmamba"

# FIXME We seem to be hitting issues related to spdlog...
# [100%] Linking CXX shared library libmamba.dylib
# Undefined symbols for architecture x86_64:
#   "spdlog::dump_backtrace()", referenced from:
#       mamba::mamba_error::mamba_error(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const&, mamba::mamba_error_code) in error_handling.cpp.o
#       mamba::mamba_error::mamba_error(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const&, mamba::mamba_error_code) in error_handling.cpp.o
#       mamba::mamba_error::mamba_error(char const*, mamba::mamba_error_code) in error_handling.cpp.o
#       mamba::mamba_error::mamba_error(char const*, mamba::mamba_error_code) in error_handling.cpp.o
#       mamba::mamba_error::mamba_error(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const&, mamba::mamba_error_code, std::__1::any&&) in error_handling.cpp.o
#       mamba::mamba_error::mamba_error(char const*, mamba::mamba_error_code, std::__1::any&&) in error_handling.cpp.o
#       mamba::make_unexpected(char const*, mamba::mamba_error_code) in error_handling.cpp.o
#       ...
#   "spdlog::register_logger(std::__1::shared_ptr<spdlog::logger>)", referenced from:
#       mamba::Context::Context() in context.cpp.o
#   "spdlog::enable_backtrace(unsigned long)", referenced from:
#       mamba::Configuration::load() in configuration.cpp.o
#   "spdlog::disable_backtrace()", referenced from:
#       mamba::Configuration::load() in configuration.cpp.o

# FIXME macOS failing at this build step with our GCC:
# > [83/106] Linking CXX shared library libmamba/libmamba.2.0.0.dylib
# > FAILED: libmamba/libmamba.2.0.0.dylib

main() {
    # """
    # Install micromamba.
    # @note Updated 2022-12-06.
    #
    # Consider setting 'CMAKE_PREFIX_PATH' here to include yaml-cpp.
    #
    # @seealso
    # - https://mamba.readthedocs.io/en/latest/developer_zone/build_locally.html
    # - https://mamba.readthedocs.io/en/latest/installation.html
    # - https://github.com/mamba-org/mamba/blob/main/libmamba/CMakeLists.txt
    # - https://github.com/mamba-org/mamba/blob/main/libmamba/
    #     environment-dev.yml
    # - https://man.archlinux.org/man/extra/cmake/cmake-env-variables.7.en
    # - https://github.com/conda-forge/libmamba-feedstock/
    # - https://github.com/conda-forge/conda-libmamba-solver-feedstock/
    # - https://github.com/Homebrew/brew/blob/3.6.14/Library/
    #     Homebrew/formula.rb#L1539
    # """
    local app build_deps deps dict shared_cmake_args
    build_deps=(
        # > 'gcc'
        'ninja'
    )
    deps=(
        'cli11'
        'curl'
        'fmt'
        # > 'googletest'
        'libarchive'
        'libsolv'
        'nlohmann-json'
        'openssl3'
        'pybind11'
        'python'
        'reproc'
        'spdlog'
        'termcolor'
        'tl-expected'
        'yaml-cpp'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        # > ['gcc']="$(koopa_locate_gcc)"
        ['python']="$(koopa_locate_python --realpath)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    # > [[ -x "${app['gcc']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        ['curl']="$(koopa_app_prefix 'curl')"
        ['fmt']="$(koopa_app_prefix 'fmt')"
        # > ['googletest']="$(koopa_app_prefix 'googletest')"
        ['jobs']="$(koopa_cpu_count)"
        ['libarchive']="$(koopa_app_prefix 'libarchive')"
        ['libsolv']="$(koopa_app_prefix 'libsolv')"
        ['name']='mamba'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['pybind11']="$(koopa_app_prefix 'pybind11')"
        ['reproc']="$(koopa_app_prefix 'reproc')"
        ['shared_ext']="$(koopa_shared_ext)"
        ['spdlog']="$(koopa_app_prefix 'spdlog')"
        ['tl-expected']="$(koopa_app_prefix 'tl-expected')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['yaml-cpp']="$(koopa_app_prefix 'yaml-cpp')"
    )
    koopa_assert_is_dir \
        "${dict['curl']}" \
        "${dict['fmt']}" \
        "${dict['libarchive']}" \
        "${dict['libsolv']}" \
        "${dict['openssl']}" \
        "${dict['pybind11']}" \
        "${dict['reproc']}" \
        "${dict['spdlog']}" \
        "${dict['tl-expected']}" \
        "${dict['yaml-cpp']}"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/mamba-org/mamba/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # > export CC="${app['gcc']}"
    shared_cmake_args=(
        # FIXME Does this help?
        "-DCMAKE_PREFIX_PATH=${dict['spdlog']}/lib/cmake/spdlog"

        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        # > '-G' 'Ninja'
    )
#    cmake_args=(
#        # Mamba build settings -------------------------------------------------
#        '-DBUILD_SHARED=ON'
#        '-DBUILD_LIBMAMBA=ON'
#        '-DBUILD_LIBMAMBAPY=ON'
#        '-DBUILD_LIBMAMBA_TESTS=OFF'
#        '-DBUILD_MAMBA_PACKAGE=ON'
#        '-DBUILD_MICROMAMBA=ON'
#        '-DMICROMAMBA_LINKAGE=DYNAMIC'
#        # Required dependencies ------------------------------------------------
#        # > "-DGTest_DIR=${dict['googletest']}/lib/cmake/GTest"
#        # Needed for 'libmamba/CMakeLists.txt'.
#        # Needed for 'libmambapy/CMakeLists.txt'.
#        "-DPython_EXECUTABLE=${app['python']}"
#        "-Dpybind11_DIR=${dict['pybind11']}/share/cmake/pybind11"
#    )
    koopa_print_env
    koopa_dl 'Shared CMake args' "${shared_cmake_args[*]}"
    # Step 1: build libmamba.
    # FIXME Our spdlog build from source here is erroring, where as the
    # homebrew spdlog works correctly....argh.
    "${app['cmake']}" -LH \
        -S . \
        -B 'build-libmamba' \
        "${shared_cmake_args[@]}" \
        -DBUILD_LIBMAMBA='ON' \
        -DBUILD_SHARED='ON' \
        -DCURL_INCLUDE_DIR="${dict['curl']}/include" \
        -DCURL_LIBRARY="${dict['curl']}/lib/libcurl.${dict['shared_ext']}" \
        -DLibArchive_INCLUDE_DIR="${dict['libarchive']}/include" \
        -DLibArchive_LIBRARY="${dict['libarchive']}/lib/\
libarchive.${dict['shared_ext']}" \
        -DLIBSOLVEXT_LIBRARIES="${dict['libsolv']}/lib/\
libsolvext.${dict['shared_ext']}" \
        -DLIBSOLV_LIBRARIES="${dict['libsolv']}/lib/\
libsolv.${dict['shared_ext']}" \
        -DOPENSSL_ROOT_DIR="${dict['openssl']}" \
        -DPython3_EXECUTABLE="${app['python']}" \
        -Dfmt_DIR="${dict['fmt']}/lib/cmake/fmt" \
        -Dreproc++_DIR="${dict['reproc']}/lib/cmake/reproc++" \
        -Dreproc_DIR="${dict['reproc']}/lib/cmake/reproc" \
        -Dspdlog_DIR="${dict['spdlog']}/lib/cmake/spdlog" \
        -Dtl-expected_DIR="${dict['tl-expected']}/share/cmake/tl-expected" \
        -Dyaml-cpp_DIR="${dict['yaml-cpp']}/share/cmake/yaml-cpp"
    "${app['cmake']}" \
        --build 'build-libmamba' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'build-libmamba'
    return 0
}
