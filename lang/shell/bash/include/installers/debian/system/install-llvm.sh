#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

main() { # {{{1
    # """
    # Install LLVM (clang).
    # @note Updated 2022-01-27.
    #
    # @seealso
    # - https://apt.llvm.org/
    #
    # Automatic script:
    # https://apt.llvm.org/llvm.sh
    # The 'llvm.sh' install script contains the GPG signing keys.
    #
    # Note that default llvm recipe currently installs version 6.
    # """
    local dict pkgs
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A dict=(
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    koopa_debian_apt_add_llvm_repo
    pkgs=(
        "clang-${dict[maj_ver]}"
        "clangd-${dict[maj_ver]}"
        "lld-${dict[maj_ver]}"
        "lldb-${dict[maj_ver]}"
    )
    koopa_debian_apt_install "${pkgs[@]}"
    return 0
}
