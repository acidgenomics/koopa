#!/usr/bin/env bash

koopa::debian_install_llvm() {
    # """
    # Install LLVM (clang).
    # @note Updated 2020-07-16.
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
    local current_major_version current_version major_version name name_fancy \
        pos reinstall version
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
    # FIXME Convert to function.
    [[ "$reinstall" -eq 1 ]] && uninstall-llvm
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
            koopa::note "${name_fancy} is installed."
            exit 0
        else
            koopa::dl 'LLVM config' "$LLVM_CONFIG"
            # FIXME Convert to function.
            uninstall-llvm
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
