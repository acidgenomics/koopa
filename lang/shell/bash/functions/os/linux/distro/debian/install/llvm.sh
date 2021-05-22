#!/usr/bin/env bash

koopa::debian_install_llvm() { # {{{1
    # """
    # Install LLVM (clang).
    # @note Updated 2021-05-22.
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
    local current_major_version current_version major_version name name_fancy
    local pos reinstall version
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ "$reinstall" -eq 1 ]] && koopa::debian_uninstall_llvm
    name='llvm'
    version="$(koopa::variable "$name")"
    major_version="$(koopa::major_version "$version")"
    name_fancy="LLVM ${major_version}"
    # Check if LLVM installation is current, or whether we need to update.
    if [[ -n "${LLVM_CONFIG:-}" ]]
    then
        current_version="$(koopa::get_version "$LLVM_CONFIG")"
        current_major_version="$(koopa::major_version "$current_version")"
        if [[ "$current_major_version" == "$major_version" ]]
        then
            koopa::alert_note "${name_fancy} is installed."
            return 0
        else
            koopa::dl 'LLVM config' "$LLVM_CONFIG"
            koopa::debian_uninstall_llvm
        fi
    fi
    koopa::install_start "$name_fancy"
    koopa::apt_add_llvm_repo
    pkgs=(
        "clang-${major_version}"
        "clangd-${major_version}"
        "lld-${major_version}"
        "lldb-${major_version}"
    )
    koopa::apt_install "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_uninstall_llvm() { # {{{1
    # """
    # Uninstall LLVM.
    # @note Updated 2020-07-16.
    # """
    name_fancy='LLVM'
    koopa::uninstall_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    unset -v LLVM_CONFIG
    sudo apt-get --yes remove '^clang-[0-9]+.*' '^llvm-[0-9]+.*'
    sudo apt-get --yes autoremove
    koopa::rm -S '/etc/apt/sources.list.d/llvm.list'
    koopa::uninstall_success "$name_fancy"
    return 0
}
