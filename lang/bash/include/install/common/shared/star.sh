#!/usr/bin/env bash

install_from_conda() {
    # """
    # Install STAR from bioconda.
    # @note Updated 2025-03-01.
    # """
    local -A app dict
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    koopa_install_conda_package
    if koopa_is_linux
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
        koopa_write_string \
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
    ! koopa_is_macos && deps+=('bzip2')
    deps+=('xz' 'zlib' 'htslib')
    koopa_is_macos && deps+=('llvm')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    if koopa_is_macos
    then
        app['cxx']="$(koopa_locate_clangxx)"
    else
        app['cxx']="$(koopa_locate_cxx --only-system)"
    fi
    app['date']="$(koopa_locate_date)"
    app['make']="$(koopa_locate_make)"
    app['patch']="$(koopa_locate_patch)"
    app['pkg_config']="$(koopa_locate_pkg_config)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['patch_prefix']="$(koopa_patch_prefix)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/alexdobin/STAR/archive/\
${dict['version']}.tar.gz"
    # > if koopa_is_macos
    # > then
    # >     dict['clt_ver']="$(koopa_macos_xcode_clt_version)"
    # >     dict['clt_maj_ver']="$(koopa_major_version "${dict['clt_ver']}")"
    # >     if [[ "${dict['clt_maj_ver']}" -ge 15 ]]
    # >     then
    # >         koopa_append_ldflags '-Wl,-ld_classic'
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
    if koopa_is_macos
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
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/source'
    dict['patch_common']="${dict['patch_prefix']}/common/star"
    koopa_assert_is_dir "${dict['patch_common']}"
    dict['patch_file_1']="${dict['patch_common']}/01-disable-avx2.patch"
    dict['patch_file_2']="${dict['patch_common']}/02-unbundle-htslib.patch"
    koopa_assert_is_file \
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
    koopa_mkdir 'bin'
    (
        koopa_cd 'bin'
        koopa_ln "${app['date']}" 'date'
    )
    koopa_add_to_path_start "$(koopa_realpath 'bin')"
    koopa_print_env
    koopa_dl 'make args' "${make_args[*]}"
    "${app['make']}" "${make_args[@]}"
    koopa_chmod +x 'STAR' 'STARlong'
    koopa_cp 'STAR' "${dict['prefix']}/bin/STAR"
    koopa_cp 'STARlong' "${dict['prefix']}/bin/STARlong"
    "${dict['prefix']}/bin/STAR" -h
    return 0
}

main() {
    if koopa_is_arm64
    then
        install_from_source
    else
        install_from_conda
    fi
    return 0
}
