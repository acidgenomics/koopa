#!/usr/bin/env bash

install_from_conda() {
    # """
    # Install STAR from bioconda.
    # @note Updated 2025-03-01.
    # """
    local -A app dict
    app['patch']="$(_koopa_locate_patch)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    _koopa_install_conda_package
    if _koopa_is_linux
    then
        dict['patch_file']='patch-script-dir.patch'
        read -r -d '' "dict[patch_string]" << END || true
--- STAR
+++ STAR-1
@@ -1,6 +1,6 @@
 #!/bin/bash

-SCRIPT_DIR=\$( cd -- "\$( dirname -- "\${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
+SCRIPT_DIR=${dict['prefix']}/bin
 DIR=\$SCRIPT_DIR
 BASE=\${DIR}/\$(basename "\$0")
 CMDARGS="\$@"
END
        _koopa_write_string \
            --file="${dict['patch_file']}" \
            --string="${dict['patch_string']}"
        "${app['patch']}" \
            --unified \
            --verbose \
            "${dict['prefix']}/libexec/bin/STAR" \
            "${dict['patch_file']}"
        "${app['patch']}" \
            --unified \
            --verbose \
            "${dict['prefix']}/libexec/bin/STARlong" \
            "${dict['patch_file']}"
    fi
    "${dict['prefix']}/bin/STAR" -h
    return 0
}

install_from_source() {
    # """
    # Install STAR from source.
    # @note Updated 2024-07-15.
    #
    # Pull request to use 'SYSTEM_HTSLIB=1' to unbundle htslib:
    # https://github.com/alexdobin/STAR/pull/1586
    #
    # @seealso
    # - https://github.com/alexdobin/STAR/
    # - https://bioconda.github.io/recipes/star/README.html
    # - How to compile without system zlib?
    #   https://github.com/alexdobin/STAR/issues/1932
    # - Unbundle htslib pull request:
    #   https://github.com/alexdobin/STAR/pull/1586
    # """
    local -A app
    local -a build_deps deps make_args
    build_deps=('coreutils' 'make' 'pkg-config')
    ! _koopa_is_macos && deps+=('bzip2')
    deps+=('xz' 'zlib' 'htslib')
    _koopa_is_macos && deps+=('llvm')
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    if _koopa_is_macos
    then
        app['cxx']="$(_koopa_locate_clangxx)"
    else
        app['cxx']="$(_koopa_locate_cxx --only-system)"
    fi
    app['date']="$(_koopa_locate_date)"
    app['make']="$(_koopa_locate_make)"
    app['patch']="$(_koopa_locate_patch)"
    app['pkg_config']="$(_koopa_locate_pkg_config)"
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['patch_prefix']="$(_koopa_patch_prefix)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/alexdobin/STAR/archive/\
${dict['version']}.tar.gz"
    # > if _koopa_is_macos
    # > then
    # >     dict['clt_ver']="$(_koopa_macos_xcode_clt_version)"
    # >     dict['clt_maj_ver']="$(_koopa_major_version "${dict['clt_ver']}")"
    # >     if [[ "${dict['clt_maj_ver']}" -ge 15 ]]
    # >     then
    # >         _koopa_append_ldflags '-Wl,-ld_classic'
    # >     fi
    # > fi
    make_args+=(
        "--jobs=${dict['jobs']}"
        "CPPFLAGS=${CPPFLAGS:?}"
        "CXX=${app['cxx']}"
        "LDFLAGS=${LDFLAGS:?}"
        'SYSTEM_HTSLIB=1'
        'VERBOSE=1'
    )
    if _koopa_is_macos
    then
        # Static instead of dynamic build is currently recommended in README.
        # > make_args+=('STARforMac')
        make_args+=(
            # > "PKG_CONFIG=${app['pkg_config']} --static"
            'STARforMacStatic' 'STARlongForMacStatic'
        )
    else
        make_args+=('STAR' 'STARlong')
    fi
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src/source'
    dict['patch_common']="${dict['patch_prefix']}/common/star"
    _koopa_assert_is_dir "${dict['patch_common']}"
    dict['patch_file_1']="${dict['patch_common']}/01-disable-avx2.patch"
    dict['patch_file_2']="${dict['patch_common']}/02-unbundle-htslib.patch"
    _koopa_assert_is_file \
        "${dict['patch_file_1']}" \
        "${dict['patch_file_2']}"
    "${app['patch']}" \
        --input="${dict['patch_file_1']}" \
        --unified \
        --verbose
    "${app['patch']}" \
        --input="${dict['patch_file_2']}" \
        --unified \
        --verbose
    # Makefile is currently hard-coded to look for 'date', which isn't expected
    # GNU on macOS.
    _koopa_mkdir 'bin'
    (
        _koopa_cd 'bin'
        _koopa_ln "${app['date']}" 'date'
    )
    _koopa_add_to_path_start "$(_koopa_realpath 'bin')"
    _koopa_print_env
    _koopa_dl 'make args' "${make_args[*]}"
    "${app['make']}" "${make_args[@]}"
    _koopa_chmod +x 'STAR' 'STARlong'
    _koopa_cp 'STAR' "${dict['prefix']}/bin/STAR"
    _koopa_cp 'STARlong' "${dict['prefix']}/bin/STARlong"
    "${dict['prefix']}/bin/STAR" -h
    return 0
}

main() {
    if _koopa_is_arm64
    then
        install_from_source
    else
        install_from_conda
    fi
    return 0
}
