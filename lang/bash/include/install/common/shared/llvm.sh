#!/usr/bin/env bash

# NOTE Rework this using a cmake dict.
# NOTE Check that files and dirs exist, where relevant.

# FIXME Build with ninja.
# FIXME Need to debug build failure on Ubuntu.
# FIXME Do we need to include swig for build?

main() {
    # """
    # Install LLVM (clang).
    # @note Updated 2024-07-06.
    #
    # @seealso
    # - https://llvm.org/docs/GettingStarted.html
    # - https://llvm.org/docs/CMake.html
    # - https://github.com/conda-forge/llvmdev-feedstock
    # - https://formulae.brew.sh/formula/llvm
    # - https://github.com/llvm/llvm-project/blob/main/clang/CMakeLists.txt
    #
    # Additional configuration:
    # - https://github.com/llvm/llvm-project/blob/main/cmake/
    #     Modules/FindLibEdit.cmake
    # - https://github.com/llvm/llvm-project/blob/main/llvm/cmake/
    #     modules/FindTerminfo.cmake
    # - https://github.com/llvm/llvm-project/blob/main/lldb/cmake/
    #     modules/FindPythonAndSwig.cmake
    # - https://github.com/llvm/llvm-project/blob/main/llvm/cmake/\
    #     modules/FindFFI.cmake
    # - https://github.com/llvm/llvm-project/blob/main/lldb/CMakeLists.txt
    # - https://github.com/llvm-mirror/openmp/blob/master/libomptarget/cmake/
    #     Modules/LibomptargetGetDependencies.cmake
    # - https://stackoverflow.com/questions/6077414/
    # - https://wiki.dlang.org/Building_LDC_from_source
    # """
    local -A app dict
    local -a build_deps cmake_args deps projects runtimes
    build_deps=(
        'git'
        'perl'
        'pkg-config'
        # > 'ninja' FIXME
        'swig'
    )
    # > koopa_is_linux && build_deps+=('gcc')
    deps=(
        'xz' # lzma
        'zlib'
        'libedit'
        'libffi'
        'ncurses'
        'python3.12'
    )
    if koopa_is_linux
    then
        deps+=(
            # Needed for 'gold'.
            'binutils'
            'zstd' # elfutils
            # OpenMP requires 'gelf.h'.
            'elfutils'
        )
    fi
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['cmake']="$(koopa_locate_cmake)"
    app['git']="$(koopa_locate_git --realpath)"
    app['perl']="$(koopa_locate_perl --realpath)"
    app['pkg_config']="$(koopa_locate_pkg_config --realpath)"
    app['python']="$(koopa_locate_python312 --realpath)"
    app['swig']="$(koopa_locate_swig --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['libedit']="$(koopa_app_prefix 'libedit')"
    dict['libffi']="$(koopa_app_prefix 'libffi')"
    dict['ncurses']="$(koopa_app_prefix 'ncurses')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['python']="$(koopa_app_prefix 'python3.12')"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['xz']="$(koopa_app_prefix 'xz')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    koopa_assert_is_dir \
        "${dict['libedit']}" \
        "${dict['libffi']}" \
        "${dict['ncurses']}" \
        "${dict['python']}" \
        "${dict['xz']}" \
        "${dict['zlib']}"
    if koopa_is_linux
    then
        dict['binutils']="$(koopa_app_prefix 'binutils')"
        dict['elfutils']="$(koopa_app_prefix 'elfutils')"
        koopa_assert_is_dir \
            "${dict['binutils']}" \
            "${dict['elfutils']}"
        # FIXME Consider requiring build with latest GCC.
        # > app['cc']="$(koopa_locate_gcc)"
        # > app['cxx']="$(koopa_locate_gcxx)"
        # > koopa_assert_is_executable "${app['cc']}" "${app['cxx']}"
    fi
    dict['py_ver']="$(koopa_get_version "${app['python']}")"
    dict['py_maj_min_ver']="$(koopa_major_minor_version "${dict['py_ver']}")"
    projects=(
        'clang'
        'clang-tools-extra'
        'lld'
        'lldb'
        'mlir'
        'polly'
    )
    koopa_is_macos && projects+=('flang')
    runtimes=(
        # > 'compiler-rt'
        'libcxx'
        'libcxxabi'
        'libunwind'
    )
    if koopa_is_macos
    then
        runtimes+=('openmp')
    else
        projects+=('openmp')
    fi
    dict['projects']="$(koopa_paste --sep=';' "${projects[@]}")"
    dict['runtimes']="$(koopa_paste --sep=';' "${runtimes[@]}")"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DLIBCXX_INSTALL_MODULES=ON'
        '-DLIBOMP_INSTALL_ALIASES=OFF'
        '-DLLDB_ENABLE_CURSES=ON'
        '-DLLDB_ENABLE_LUA=OFF'
        '-DLLDB_ENABLE_LZMA=ON'
        '-DLLDB_ENABLE_PYTHON=ON'
        '-DLLDB_USE_SYSTEM_DEBUGSERVER=ON'
        '-DLLVM_ENABLE_ASSERTIONS=OFF'
        '-DLLVM_ENABLE_EH=ON'
        '-DLLVM_ENABLE_FFI=ON'
        '-DLLVM_ENABLE_LIBEDIT=ON'
        '-DLLVM_ENABLE_LIBXML2=OFF'
        "-DLLVM_ENABLE_PROJECTS=${dict['projects']}"
        '-DLLVM_ENABLE_RTTI=ON'
        "-DLLVM_ENABLE_RUNTIMES=${dict['runtimes']}"
        '-DLLVM_ENABLE_TERMINFO=ON'
        '-DLLVM_ENABLE_Z3_SOLVER=OFF'
        '-DLLVM_INCLUDE_BENCHMARKS=OFF'
        '-DLLVM_INCLUDE_DOCS=OFF'
        '-DLLVM_INCLUDE_TESTS=OFF'
        '-DLLVM_INSTALL_UTILS=ON'
        '-DLLVM_LINK_LLVM_DYLIB=ON'
        '-DLLVM_OPTIMIZED_TABLEGEN=ON'
        '-DLLVM_POLLY_LINK_INTO_TOOLS=ON'
        '-DLLVM_TARGETS_TO_BUILD=all' # FIXME
        # External dependencies ------------------------------------------------
        "-DCURSES_INCLUDE_DIRS=${dict['ncurses']}/include"
        "-DCURSES_LIBRARIES=${dict['ncurses']}/lib/\
libncursesw.${dict['shared_ext']}"
        "-DFFI_INCLUDE_DIR=${dict['libffi']}/include"
        "-DFFI_LIBRARY_DIR=${dict['libffi']}/lib"
        "-DGIT_EXECUTABLE=${app['git']}"
        "-DLIBLZMA_INCLUDE_DIR=${dict['xz']}/include"
        "-DLIBLZMA_LIBRARY=${dict['xz']}/lib/liblzma.${dict['shared_ext']}"
        "-DLibEdit_INCLUDE_DIRS=${dict['libedit']}/include"
        "-DLibEdit_LIBRARIES=${dict['libedit']}/lib/\
libedit.${dict['shared_ext']}"
        "-DPANEL_LIBRARIES=${dict['ncurses']}/lib/\
libpanelw.${dict['shared_ext']}"
        "-DPERL_EXECUTABLE=${app['perl']}"
        "-DPKG_CONFIG_EXECUTABLE=${app['pkg_config']}"
        "-DPython3_EXECUTABLE=${app['python']}"
        "-DPython3_INCLUDE_DIRS=${dict['python']}/include"
        "-DPython3_LIBRARIES=${dict['python']}/lib/\
libpython${dict['py_maj_min_ver']}.${dict['shared_ext']}"
        "-DPython3_ROOT_DIR=${dict['python']}"
        "-DSWIG_EXECUTABLE=${app['swig']}"
        "-DTerminfo_LIBRARIES=${dict['ncurses']}/lib/\
libncursesw.${dict['shared_ext']}"
        "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
        # Additional Python binding fixes --------------------------------------
# FIXME Are these safe to take out?
# >         "-DCLANG_PYTHON_BINDINGS_VERSIONS=${dict['py_maj_min_ver']}"
# >         "-DLLDB_PYTHON_EXE_RELATIVE_PATH=../../python/${dict['py_ver']}/\
# > bin/python${dict['py_maj_min_ver']}"
# >         "-DLLDB_PYTHON_RELATIVE_PATH=libexec/python${dict['py_maj_min_ver']}/\
# > site-packages"
    )
    if koopa_is_linux
    then
        # FIXME Consider addining '-DLLVM_USE_INTEL_JITEVENTS=ON' for Linux x86.
        # This is currently used in conda-forge recipe.
        cmake_args+=(
            '-DCLANG_DEFAULT_CXX_STDLIB=libstdc++'
            # FIXME Use our GCC instead of relying on system?
            # > "-DCMAKE_C_COMPILER=${app['cc']}"
            # > "-DCMAKE_CXX_COMPILER=${app['cxx']}"
            # Parts of Polly fail to correctly build with PIC.
            '-DCMAKE_POSITION_INDEPENDENT_CODE=ON'
            # Ensure OpenMP picks up ELF.
            "-DLIBOMPTARGET_DEP_LIBELF_INCLUDE_DIR=${dict['elfutils']}/include"
            "-DLIBOMPTARGET_DEP_LIBELF_LIBRARIES=${dict['elfutils']}/lib/\
libelf.${dict['shared_ext']}"
            # Enable llvm gold plugin for LTO.
            "-DLLVM_BINUTILS_INCDIR=${dict['binutils']}/include"
            '-DLLVM_ENABLE_LIBCXX=OFF'
        )
    elif koopa_is_macos
    then
        dict['sysroot']="$(koopa_macos_sdk_prefix)"
        koopa_assert_is_dir "${dict['sysroot']}"
        cmake_args+=(
            "-DDEFAULT_SYSROOT=${dict['sysroot']}"
            '-DLIBCXX_PSTL_CPU_BACKEND=libdispatch'
            '-DLLVM_BUILD_LLVM_C_DYLIB=ON'
            '-DLLVM_CREATE_XCODE_TOOLCHAIN=OFF'
            '-DLLVM_ENABLE_LIBCXX=ON'
            '-DLLVM_LINK_LLVM_DYLIB=ON'
        )
    fi
    dict['url']="https://github.com/llvm/llvm-project/releases/download/\
llvmorg-${dict['version']}/llvm-project-${dict['version']}.src.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/llvm'
    # FIXME Can try building with '--ninja' here.
    koopa_cmake_build \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
