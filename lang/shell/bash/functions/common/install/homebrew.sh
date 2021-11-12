#!/usr/bin/env bash

# FIXME Need to wrap in 'koopa:::install_app' call.
# FIXME Also check that Xcode CLT is installed here before proceeding on macOS.
koopa::install_homebrew() { # {{{1
    # """
    # Install Homebrew.
    # @note Updated 2021-07-28.
    #
    # @seealso
    # - https://docs.brew.sh/Installation
    # - https://github.com/Homebrew/legacy-homebrew/issues/
    #       46779#issuecomment-162819088
    # - https://github.com/Linuxbrew/brew/issues/556
    #
    # macOS:
    # NOTE This function won't run on macOS clean install due to very old Bash.
    # Installs to '/usr/local' on Intel and '/opt/homebrew' on Apple Silicon.
    #
    # Linux:
    # Creates a new linuxbrew user and installs to /home/linuxbrew/.linuxbrew.
    # """
    local tee tmp_dir
    koopa::assert_has_no_args "$#"
    if koopa::is_installed 'brew'
    then
        koopa::alert_note 'Homebrew is already installed.'
        return 0
    fi
    koopa::assert_is_admin
    koopa::assert_is_installed 'yes'
    name_fancy='Homebrew'
    koopa::install_start "$name_fancy"
    koopa::is_macos && koopa::macos_install_xcode_clt
    tee="$(koopa::locate_tee)"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='install.sh'
        url="https://raw.githubusercontent.com/Homebrew/install/master/${file}"
        koopa::download "$url"
        koopa::chmod 'u+x' "$file"
        yes | "./${file}" || true
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

# FIXME Consider wrapping this.
koopa::install_homebrew_bundle() { # {{{1
    # """
    # Install Homebrew packages using Bundle Brewfile.
    # @note Updated 2021-10-27.
    #
    # Custom brewfile is supported using a positional argument.
    # """
    local app brewfiles koopa_prefix install_args name_fancy
    koopa::assert_is_admin
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
    )
    if [[ "$#" -eq 0 ]]
    then
        koopa_prefix="$(koopa::koopa_prefix)"
        brewfiles=()
        if koopa::is_linux
        then
            brewfiles+=(
                "${koopa_prefix}/os/linux/common/etc/homebrew/brewfile"
            )
        elif koopa::is_macos
        then
            brewfiles+=(
                "${koopa_prefix}/os/macos/etc/homebrew/brewfile"
            )
        fi
        brewfiles+=(
            "${koopa_prefix}/etc/homebrew/brewfile"
        )
    else
        brewfiles=("$@")
    fi
    name_fancy='Homebrew Bundle'
    koopa::install_start "$name_fancy"
    "${app[brew]}" analytics off
    # Note that cask specific args are handled by 'HOMEBREW_CASK_OPTS' global
    # variable, which is defined in our main Homebrew activation function.
    install_args=(
        # > '--debug'
        # > '--verbose'
        '--force'
        '--no-lock'
        '--no-upgrade'
    )
    for brewfile in "${brewfiles[@]}"
    do
        koopa::assert_is_file "$brewfile"
        koopa::dl 'Brewfile' "$brewfile"
        "${app[brew]}" bundle install \
            "${install_args[@]}" \
            --file="${brewfile}"
    done
    return 0
}

# FIXME Need to wrap this.
koopa::uninstall_homebrew() { # {{{1
    # """
    # Uninstall Homebrew.
    # @note Updated 2021-07-28.
    # @seealso
    # - https://docs.brew.sh/FAQ
    # """
    local file name_fancy tee tmp_dir url user
    if ! koopa::is_installed 'brew'
    then
        koopa::alert_is_not_installed 'Homebrew'
        return 0
    fi
    koopa::assert_is_admin
    koopa::assert_is_installed 'yes'
    name_fancy='Homebrew'
    user="$(koopa::user)"
    koopa::uninstall_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    # Note that macOS Catalina now uses Zsh instead of Bash by default.
    if koopa::is_macos
    then
        koopa::alert 'Changing default shell to system Zsh.'
        chsh -s '/bin/zsh' "$user"
    fi
    tee="$(koopa::locate_tee)"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='uninstall.sh'
        url="https://raw.githubusercontent.com/Homebrew/install/master/${file}"
        koopa::download "$url"
        koopa::chmod 'u+x' "$file"
        yes | "./${file}" || true
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::uninstall_success "$name_fancy"
    return 0
}

# FIXME Need to wrap this.
koopa::update_homebrew() { # {{{1
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2021-10-27.
    #
    # @seealso
    # - Refer to useful discussion regarding '--greedy' flag.
    # - https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # - https://github.com/Homebrew/brew/issues/9139
    # - https://thecoatlessprofessor.com/programming/
    #       macos/updating-a-homebrew-formula/
    # """
    local app name_fancy reset
    koopa::assert_is_admin
    reset=0
    while (("$#"))
    do
        case "$1" in
            '--no-reset')
                reset=0
                shift 1
                ;;
            '--reset')
                reset=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
    )
    name_fancy='Homebrew'
    koopa::update_start "$name_fancy"
    if ! koopa::is_xcode_clt_installed
    then
        koopa::stop 'Need to reinstall Xcode CLT.'
    fi
    if [[ "$reset" -eq 1 ]]
    then
        koopa::brew_reset_permissions
        koopa::brew_reset_core_repo
    fi
    "${app[brew]}" analytics off
    "${app[brew]}" update &>/dev/null
    if koopa::is_macos
    then
        koopa::macos_brew_upgrade_casks
    fi
    koopa::brew_upgrade_brews
    koopa::brew_cleanup
    if [[ "$reset" -eq 1 ]]
    then
        koopa::brew_reset_permissions
    fi
    koopa::update_success "$name_fancy"
    return 0
}
