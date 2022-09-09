#!/usr/bin/env bash

# FIXME Need to resolve 'Python.h' linkage issues when enabling Python
# for LLDB. How do we get the installer to pick up Python 'include' dir?
# Is CPATH the answer?

main() {
    # """
    # Install LLVM (clang).
    # @note Updated 2022-09-08.
    #
    # @seealso
    # - https://llvm.org/docs/GettingStarted.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/llvm.rb
    # - https://github.com/llvm/llvm-project/blob/main/clang/CMakeLists.txt
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
    # """
    local app build_deps cmake_args dict deps projects
    build_deps=(
        'cmake'
        'git'
        'ninja'
        'perl'
        'pkg-config'
    )
    koopa_activate_build_opt_prefix "${build_deps[@]}"
    deps=(
        'zlib'
        'libedit'
        'libffi'
        'libxml2'
        'ncurses'
        # > 'python'
        # > 'swig'
    )
    if koopa_is_linux
    then
        deps+=(
            # Needed for 'gold'.
            'binutils'
            # > 'zstd' # may be required for elfutils
            # OpenMP requires 'gelf.h'.
            'elfutils'
        )
    fi
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['git']="$(koopa_locate_git --realpath)"
        ['ninja']="$(koopa_locate_ninja)"
        ['perl']="$(koopa_locate_perl --realpath)"
        ['pkg_config']="$(koopa_locate_pkg_config --realpath)"
        ['python']="$(koopa_locate_python --realpath)"
        # > ['swig']="$(koopa_locate_swig --realpath)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['ninja']}" ]] || return 1
    [[ -x "${app['perl']}" ]] || return 1
    [[ -x "${app['pkg_config']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    # > [[ -x "${app['swig']}" ]] || return 1
    declare -A dict=(
        ['libedit']="$(koopa_app_prefix 'libedit')"
        ['libffi']="$(koopa_app_prefix 'libffi')"
        ['libxml2']="$(koopa_app_prefix 'libxml2')"
        ['name']='llvm-project'
        ['ncurses']="$(koopa_app_prefix 'ncurses')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        # > ['python']="$(koopa_app_prefix 'python')"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    koopa_assert_is_dir \
        "${dict['libedit']}" \
        "${dict['libffi']}" \
        "${dict['libxml2']}" \
        "${dict['ncurses']}" \
        "${dict['zlib']}"
    if koopa_is_linux
    then
        dict['binutils']="$(koopa_app_prefix 'binutils')"
        dict['elfutils']="$(koopa_app_prefix 'elfutils')"
        koopa_assert_is_dir \
            "${dict['binutils']}" \
            "${dict['elfutils']}"
    fi
    # > dict['py_ver']="$(koopa_get_version "${app['python']}")"
    # > dict['py_maj_min_ver']="$(koopa_major_minor_version "${dict['py_ver']}")"
    projects=(
        # > 'bolt'
        # > 'cross-project-tests'
        # > 'pstl'
        'clang'
        'clang-tools-extra'
        'flang'
        'lld'
        'lldb'
        'mlir'
        'openmp'
        'polly'
    )
    runtimes=(
        # > 'compiler-rt'
        # > 'libc'
        # > 'libclc'
        'libcxx'
        'libcxxabi'
        'libunwind'
    )
    # This is used in the Homebrew LLVM 14 recipe.
    # > if koopa_is_macos
    # > then
    # >     runtimes+=('openmp')
    # > else
    # >     projects+=('openmp')
    # > fi
    dict['projects']="$(printf '%s;' "${projects[@]}")"
    dict['runtimes']="$(printf '%s;' "${runtimes[@]}")"
    cmake_args=(
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        '-DLLDB_ENABLE_CURSES=ON'
        '-DLLDB_ENABLE_LUA=OFF'
        '-DLLDB_ENABLE_LZMA=OFF'
        '-DLLDB_ENABLE_PYTHON=OFF'
        '-DLLDB_USE_SYSTEM_DEBUGSERVER=ON'
        '-DLIBOMP_INSTALL_ALIASES=OFF'
        '-DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON'
        '-DLLVM_ENABLE_ASSERTIONS=OFF'
        '-DLLVM_ENABLE_EH=ON'
        '-DLLVM_ENABLE_FFI=ON'
        '-DLLVM_ENABLE_LIBEDIT=ON'
        '-DLLVM_ENABLE_LIBXML2=ON'
        "-DLLVM_ENABLE_PROJECTS=${dict['projects']}"
        '-DLLVM_ENABLE_RTTI=ON'
        "-DLLVM_ENABLE_RUNTIMES=${dict['runtimes']}"
        '-DLLVM_ENABLE_TERMINFO=ON'
        '-DLLVM_ENABLE_Z3_SOLVER=OFF'
        '-DLLVM_INCLUDE_DOCS=OFF'
        '-DLLVM_INCLUDE_TESTS=OFF'
        '-DLLVM_INSTALL_UTILS=ON'
        '-DLLVM_OPTIMIZED_TABLEGEN=ON'
        '-DLLVM_POLLY_LINK_INTO_TOOLS=ON'
        '-DLLVM_TARGETS_TO_BUILD=all'
    )
    # Link external dependencies.
    cmake_args+=(
        "-DCURSES_INCLUDE_DIRS=${dict['ncurses']}/include"
        "-DCURSES_LIBRARIES=${dict['ncurses']}/lib/\
libncursesw.${dict['shared_ext']}"
        "-DFFI_INCLUDE_DIR=${dict['libffi']}/include"
        "-DFFI_LIBRARY_DIR=${dict['libffi']}/lib"
        "-DGIT_EXECUTABLE=${app['git']}"
        "-DLibEdit_INCLUDE_DIRS=${dict['libedit']}/include"
        "-DLibEdit_LIBRARIES=${dict['libedit']}/lib/\
libedit.${dict['shared_ext']}"
        # FIXME Do these work on macOS but not Linux?
        "-DLIBXML2_INCLUDE_DIRS=${dict['libxml2']}/include"
        "-DLIBXML2_LIBRARIES=${dict['libxml2']}/lib/\
libxml2.${dict['shared_ext']}"
        # FIXME Need to use these on Linux:
        "-DLIBXML2_INCLUDE_DIR=${dict['libxml2']}/include"
        "-DLIBXML2_LIBRARY=${dict['libxml2']}/lib/\
libxml2.${dict['shared_ext']}"
        "-DPANEL_LIBRARIES=${dict['ncurses']}/lib/\
libpanelw.${dict['shared_ext']}"
        "-DPERL_EXECUTABLE=${app['perl']}"
        "-DPKG_CONFIG_EXECUTABLE=${app['pkg_config']}"
        "-DPython3_EXECUTABLE=${app['python']}"
        # > "-DPython3_INCLUDE_DIRS=${dict['python']}/include"
        # > "-DPython3_LIBRARIES=${dict['python']}/lib/libpython${dict['py_maj_min_ver']}.${dict['shared_ext']}"
        # > "-DPython3_ROOT_DIR=${dict['python']}"
        # > "-DSWIG_EXECUTABLE=${app['swig']}"
        "-DTerminfo_LIBRARIES=${dict['ncurses']}/lib/\
libncursesw.${dict['shared_ext']}"
        "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    )
# > # Additional Python binding fixes.
# > cmake_args+=(
# >     "-DCLANG_PYTHON_BINDINGS_VERSIONS=${dict['py_maj_min_ver']}"
# >     "-DLLDB_PYTHON_EXE_RELATIVE_PATH=../../python/${dict['py_ver']}/bin/python${dict['py_maj_min_ver']}"
# >     "-DLLDB_PYTHON_RELATIVE_PATH=libexec/python${dict['py_maj_min_ver']}/site-packages"
# > )
    if koopa_is_linux
    then
        # FIXME Alternatively may be able to set LIBELF location in CPATH
        # environment variable.
        cmake_args+=(
            # Ensure OpenMP picks up ELF.
            "-DLIBOMPTARGET_DEP_LIBELF_INCLUDE_DIR=${dict['elfutils']}/include"
            "-DLIBOMPTARGET_DEP_LIBELF_LIBRARIES=${dict['elfutils']}/lib/libelf.${dict['shared_ext']}"
            # Enable llvm gold plugin for LTO.
            "-DLLVM_BINUTILS_INCDIR=${dict['binutils']}/include"
        )
    elif koopa_is_macos
    then
        dict['sysroot']="$(koopa_macos_sdk_prefix)"
        koopa_assert_is_dir "${dict['sysroot']}"
        cmake_args+=(
            "-DDEFAULT_SYSROOT=${dict['sysroot']}"
            '-DLLVM_BUILD_LLVM_C_DYLIB=ON'
            '-DLLVM_CREATE_XCODE_TOOLCHAIN=OFF'
            '-DLLVM_ENABLE_LIBCXX=ON'
            '-DLLVM_LINK_LLVM_DYLIB=ON'
        )
    fi
    dict['file']="${dict['name']}-${dict['version']}.src.tar.xz"
    dict['url']="https://github.com/llvm/${dict['name']}/releases/download/\
llvmorg-${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}.src"
    koopa_mkdir 'build'
    koopa_cd 'build'
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -G 'Ninja' "${cmake_args[@]}" ../llvm
    "${app['cmake']}" --build .
    return 0
}
