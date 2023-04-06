#!/usr/bin/env bash

main() {
    # """
    # Install Adoptium Temurin OpenJDK.
    # @note Updated 2023-04-06.
    #
    # Don't early return if directory exists here.
    # We need to ensure alternatives code runs (see below).
    #
    # Platform suffix examples:
    # - Linux/AArch64: 'linux-aarch64'
    # - Linux/x64: 'linux-x64'
    # - macOS/x64: 'osx-x64'
    #
    # @seealso
    # - https://adoptium.net/download/
    # - https://github.com/adoptium/temurin17-binaries
    # - https://openjdk.java.net/
    # - https://jdk.java.net/
    # - https://projects.eclipse.org/projects/adoptium.temurin
    # - https://www.oracle.com/technetwork/java/javase/downloads/index.html
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['arch']="$(koopa_arch)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_macos
    then
        dict['platform']='mac'
    else
        dict['platform']='linux'
    fi
    case "${dict['arch']}" in
        'arm64')
            # e.g. Apple Silicon.
            dict['arch2']='aarch64'
            ;;
        'x86_64')
            dict['arch2']='x64'
            ;;
        *)
            # e.g. 'aarch64'.
            dict['arch2']="${dict['arch']}"
    esac
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    # e.g. '17.0.3+7' to '17.0.3_7'.
    dict['version2']="$( \
        koopa_sub \
            --fixed \
            --pattern='+' \
            --replacement='_' \
            "${dict['version']}" \
    )"
    # e.g. '17.0.3+7' to '17.0.3%2B7'.
    dict['version3']="$( \
        koopa_sub \
            --fixed \
            --pattern='+' \
            --replacement='%2B' \
            "${dict['version']}" \
    )"
    # Need to support these:
    # - OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.3_7.tar.gz
    # - OpenJDK17U-jdk_aarch64_mac_hotspot_17.0.3_7.tar.gz
    # - OpenJDK17U-jdk_x64_linux_hotspot_17.0.3_7.tar.gz
    # - OpenJDK17U-jdk_x64_mac_hotspot_17.0.3_7.tar.gz
    dict['file']="OpenJDK${dict['maj_ver']}U-jdk_${dict['arch2']}_\
${dict['platform']}_hotspot_${dict['version2']}.tar.gz"
    dict['url']="https://github.com/adoptium/temurin${dict['maj_ver']}-\
binaries/releases/download/jdk-${dict['version3']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cp "jdk-${dict['version']}" "${dict['prefix']}/libexec"
    (
        local -a names
        local libexec name
        koopa_cd "${dict['prefix']}"
        if koopa_is_macos
        then
            libexec='libexec/Contents/Home'
        else
            libexec='libexec'
        fi
        names=('bin' 'include' 'lib' 'man')
        for name in "${names[@]}"
        do
            koopa_ln "${libexec}/${name}" "$name"
        done
    )
    # > if koopa_is_shared_install && koopa_is_linux
    # > then
    # >     koopa_linux_java_update_alternatives "${dict['prefix']}"
    # > fi
    return 0
}
