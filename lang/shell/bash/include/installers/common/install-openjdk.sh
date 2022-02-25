#!/usr/bin/env bash

install_openjdk() { # {{{1
    # """
    # Install OpenJDK.
    # @note Updated 2021-12-14.
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
    # - https://jdk.java.net/
    # - https://www.oracle.com/java/technologies/javase-downloads.html#JDK16
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [name]='openjdk'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa_is_macos
    then
        dict[platform]='osx'
    else
        dict[platform]='linux'
    fi
    case "${dict[arch]}" in
        x86_64)
            dict[arch2]='x64'
            ;;
        *)
            dict[arch2]="${dict[arch]}"
    esac
    case "${dict[version]}" in
        '17.0.1')
            dict[unique]='2a2082e5a09d4267845be086888add4f/12'
            ;;
        '17')
            dict[unique]='0d483333a00540d886896bac774ff48b/35'
            ;;
        '16.0.2')
            dict[unique]='d4a915d82b4c4fbb9bde534da945d746/7'
            ;;
        '16.0.1')
            dict[unique]='7147401fd7354114ac51ef3e1328291f/9'
            ;;
        '16')
            dict[unique]='7863447f0ab643c585b9bdebf67c69db/36'
            ;;
        '15.0.2')
            dict[unique]='0d1cfde4252546c6931946de8db48ee2/7'
            ;;
        '15.0.1')
            dict[unique]='51f4f36ad4ef43e39d0dfdbaf6549e32/9'
            ;;
        '15')
            dict[unique]='779bf45e88a44cbd9ea6621d33e33db1/36'
            ;;
        '14.0.2')
            dict[unique]='205943a0976c4ed48cb16f1043c5c647/12'
            ;;
        '14.0.1')
            dict[unique]='664493ef4a6946b186ff29eb326336a2/7'
            ;;
        '14')
            dict[unique]='076bab302c7b4508975440c56f6cc26a/36'
            ;;
        '13.0.2')
            dict[unique]='d4173c853231432d94f001e99d882ca7/8'
            ;;
        '13.0.1')
            dict[unique]='cec27d702aa74d5a8630c65ae61e4305/9'
            ;;
        '13')
            dict[unique]='5b8a42f3905b406298b72d750b6919f6/33'
            ;;
        *)
            koopa_stop "Unsupported version: '${dict[version]}'."
    esac
    dict[file]="${dict[name]}-${dict[version]}_${dict[platform]}-\
${dict[arch2]}_bin.tar.gz"
    dict[url]="https://download.java.net/java/GA/jdk${dict[version]}/\
${dict[unique]}/GPL/${dict[file]}"
    dict[jdk_dirname]="jdk-${dict[version]}"
    if koopa_is_macos
    then
        dict[jdk_dirname]="${dict[jdk_dirname]}.jdk"
    fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_mv "${dict[jdk_dirname]}" "${dict[prefix]}"
    if koopa_is_linux
    then
        # This step will skip for non-shared install.
        koopa_linux_java_update_alternatives "${dict[prefix]}"
    fi
}
