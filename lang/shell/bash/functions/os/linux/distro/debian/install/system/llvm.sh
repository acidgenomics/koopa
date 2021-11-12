#!/usr/bin/env bash

# FIXME Need to rework this to not warn about missing llvm-config.
# FIXME Wrap this using our standard install:::app approach.
# FIXME Ensure version support works, e.g. LLVM 12 and 13.
# FIXME Need to wrap this.

koopa::debian_install_llvm() { # {{{1
    # """
    # Install LLVM (clang).
    # @note Updated 2021-11-03.
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
    local current_major_version current_version llvm_config
    local major_version name name_fancy pos reinstall version
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--reinstall')
                reinstall=1
                shift 1
                ;;
            '-'*)
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
    llvm_config="$(koopa::locate_llvm_config 2>/dev/null || true)"
    if [[ -x "$llvm_config" ]]
    then
        current_version="$(koopa::get_version "$llvm_config")"
        current_major_version="$(koopa::major_version "$current_version")"
        if [[ "$current_major_version" == "$major_version" ]]
        then
            koopa::alert_note "${name_fancy} is installed."
            return 0
        else
            koopa::dl 'LLVM config' "$llvm_config"
            koopa::debian_uninstall_llvm
        fi
    fi
    koopa::install_start "$name_fancy"
    koopa::debian_apt_add_llvm_repo
    pkgs=(
        "clang-${major_version}"
        "clangd-${major_version}"
        "lld-${major_version}"
        "lldb-${major_version}"
    )
    koopa::debian_apt_install "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

# FIXME Need to wrap this.
koopa::debian_uninstall_llvm() { # {{{1
    # """
    # Uninstall LLVM.
    # @note Updated 2021-05-26.
    # """
    name_fancy='LLVM'
    koopa::uninstall_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    sudo apt-get --yes remove '^clang-[0-9]+.*' '^llvm-[0-9]+.*'
    sudo apt-get --yes autoremove
    koopa::rm --sudo '/etc/apt/sources.list.d/llvm.list'
    unset -v LLVM_CONFIG
    koopa::uninstall_success "$name_fancy"
    return 0
}
