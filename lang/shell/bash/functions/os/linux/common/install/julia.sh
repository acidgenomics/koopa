#!/usr/bin/env bash

# FIXME Reconsider this approach, so we can install on macOS from source.

koopa::linux_install_julia() { # {{{1
    local installer pos
    installer='julia'
    pos=()
    while (("$#"))
    do
        case "$1" in
            --binary)
                installer='julia-binary'
                shift 1
                ;;
            --source)
                installer='julia'
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::linux_install_app \
        --name='julia' \
        --name-fancy='Julia' \
        --installer="$installer" \
        "$@"
}

koopa:::install_julia() { # {{{1
    # """
    # Install Julia (from source).
    # @note Updated 2021-05-04.
    # @seealso
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/linux.md
    # - https://docs.julialang.org/en/v1/devdocs/llvm/
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md#llvm
    # - https://github.com/JuliaLang/julia/blob/master/Make.inc
    # """
    local file jobs name prefix version url
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='julia'
    jobs="$(koopa::cpu_count)"
    # > file="v${version}.tar.gz"
    # > url="https://github.com/JuliaLang/julia/archive/${file}"
    file="${name}-${version}-full.tar.gz"
    url="https://github.com/JuliaLang/${name}/releases/download/\
v${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::alert_coffee_time
    # If set, this will interfere with internal LLVM build required for
    # Julia. See 'build.md' file for LLVM details.
    unset LLVM_CONFIG
    # Customize the 'Make.user' file.
    # Need to ensure we configure internal LLVM build here.
    cat > 'Make.user' << END
prefix=${prefix}
# > LLVM_ASSERTIONS=1
# > LLVM_DEBUG=Release
# > USE_BINARYBUILDER=0
USE_LLVM_SHLIB=0
USE_SYSTEM_LLVM=0
END
    make --jobs="$jobs"
    # > make test
    make install
    return 0
}

koopa:::linux_install_julia_binary() { # {{{1
    # """
    # Install Julia from binary.
    # @note Updated 2021-05-04.
    # @seealso
    # - https://julialang.org/downloads/
    # - https://julialang.org/downloads/platform/
    # """
    local arch file minor_version name os prefix subdir url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='julia'
    arch="$(koopa::arch)"
    os='linux'
    minor_version="$(koopa::major_minor_version "$version")"
    file="${name}-${version}-${os}-${arch}.tar.gz"
    case "$arch" in
        x86*)
            subdir='x86'
            ;;
        *)
            subdir="$arch"
            ;;
    esac
    url="https://julialang-s3.julialang.org/bin/${os}/${subdir}/\
${minor_version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::rm 'LICENSE.md'
    koopa::mkdir "$prefix"
    koopa::cp . "$prefix"
    return 0
}
