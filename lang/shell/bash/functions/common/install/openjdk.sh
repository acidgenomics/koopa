#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_openjdk() { # {{{1
    koopa::install_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        --no-link \
        "$@"
}

koopa:::install_openjdk() { # {{{1
    # """
    # Install OpenJDK.
    # @note Updated 2021-05-05.
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
    # - https://www.oracle.com/java/technologies/javase-downloads.html#JDK16
    #
    # Legacy java.net links (now down):
    # - https://jdk.java.net/archive/
    # - https://jdk.java.net/15/
    # - https://openjdk.java.net/
    # """
    local arch arch2 file jdk_dirname name platform prefix version unique url
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='openjdk'
    case "$version" in
        16.0.1)
            unique='7147401fd7354114ac51ef3e1328291f/9'
            ;;
        16)
            unique='7863447f0ab643c585b9bdebf67c69db/36'
            ;;
        15.0.2)
            unique='0d1cfde4252546c6931946de8db48ee2/7'
            ;;
        15.0.1)
            unique='51f4f36ad4ef43e39d0dfdbaf6549e32/9'
            ;;
        15)
            unique='779bf45e88a44cbd9ea6621d33e33db1/36'
            ;;
        14.0.2)
            unique='205943a0976c4ed48cb16f1043c5c647/12'
            ;;
        14.0.1)
            unique='664493ef4a6946b186ff29eb326336a2/7'
            ;;
        14)
            unique='076bab302c7b4508975440c56f6cc26a/36'
            ;;
        13.0.2)
            unique='d4173c853231432d94f001e99d882ca7/8'
            ;;
        13.0.1)
            unique='cec27d702aa74d5a8630c65ae61e4305/9'
            ;;
        13)
            unique='5b8a42f3905b406298b72d750b6919f6/33'
            ;;
        *)
            koopa::stop "Unsupported version: '${version}'."
    esac
    if koopa::is_macos
    then
        platform='osx'
    else
        platform='linux'
    fi
    # ARM will return 'aarch64' here, which is what we want.
    # Need to handle x86 edge case.
    arch="$(koopa::arch)"
    case "$arch" in
        x86_64)
            arch2='x64'
            ;;
        *)
            arch2="$arch"
    esac
    file="${name}-${version}_${platform}-${arch2}_bin.tar.gz"
    url="https://download.java.net/java/GA/jdk${version}/\
${unique}/GPL/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    jdk_dirname="jdk-${version}"
    if koopa::is_macos
    then
        jdk_dirname="${jdk_dirname}.jdk"
    fi
    koopa::mv "$jdk_dirname" "$prefix"
    if koopa::is_linux
    then
        # This step will skip for non-shared install.
        koopa::linux_java_update_alternatives "$prefix"
    fi
}

koopa::uninstall_openjdk() { # {{{1
    koopa::uninstall_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        --no-link \
        "$@"
}
