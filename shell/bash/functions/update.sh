#!/usr/bin/env bash

# FIXME REFERENCE FUNCTIONS HERE WHEN POSSIBLE.
koopa::update() { # {{{1
    # """
    # Update koopa installation.
    # @note Updated 2020-06-29.
    # """
    local app_prefix config_prefix configure_flags core dotfiles \
        dotfiles_prefix fast koopa_prefix make_prefix repos repo source_ip \
        system user
    koopa_prefix="$(koopa::prefix)"
    # Note that stable releases are not git, and can't be updated.
    if ! koopa::is_git_toplevel "$koopa_prefix"
    then
        version="$(koopa::version)"
        url="$(koopa::url)"
        koopa::note "Stable release of koopa ${version} detected."
        koopa::note "To update, first run the 'uninstall' script."
        koopa::note "Then run the default install command at '${url}'."
        exit 1
    fi
    config_prefix="$(koopa::config_prefix)"
    app_prefix="$(koopa::app_prefix)"
    make_prefix="$(koopa::make_prefix)"
    core=1
    dotfiles=1
    fast=0
    source_ip=
    system=0
    user=0
    while (("$#"))
    do
        case "$1" in
            --fast)
                fast=1
                shift 1
                ;;
            --source-ip=*)
                source_ip="${1#*=}"
                shift 1
                ;;
            --source-ip)
                source_ip="$2"
                shift 2
                ;;
            --system)
                system=1
                shift 1
                ;;
            --user)
                user=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ -n "$source_ip" ]]
    then
        rsync=1
        system=1
    else
        rsync=0
    fi
    if [[ "$fast" -eq 1 ]]
    then
        dotfiles=0
    fi
    if [[ "$user" -eq 1 ]] && [[ "$system" -eq 0 ]]
    then
        core=0
        dotfiles=0
    fi
    if [[ "$system" -eq 1 ]]
    then
        user=1
    fi
    koopa::h1 "Updating koopa at '${koopa_prefix}'."
    koopa::sys_set_permissions -r "$koopa_prefix"
    if [[ "$rsync" -eq 0 ]]
    then
        # Update koopa.
        if [[ "$core" -eq 1 ]]
        then
            koopa::sys_git_pull
        fi
        # Ensure dotfiles are current.
        if [[ "$dotfiles" -eq 1 ]]
        then
            (
                dotfiles_prefix="$(koopa::dotfiles_prefix)"
                cd "$dotfiles_prefix" || exit 1
                # Preivously, this repo was at 'mjsteinbaugh/dotfiles'.
                koopa::git_set_remote_url \
                    'https://github.com/acidgenomics/dotfiles.git'
                koopa::git_reset
                koopa::git_pull origin master
            )
        fi
        koopa::sys_set_permissions -r "$koopa_prefix"
    fi
    koopa::update_xdg_config
    if [[ "$system" -eq 1 ]]
    then
        koopa::h2 "Updating system configuration."
        koopa::assert_has_sudo
        koopa::dl "App prefix" "${app_prefix}"
        koopa::dl "Config prefix" "${config_prefix}"
        koopa::dl "Make prefix" "${make_prefix}"
        koopa::add_make_prefix_link
        if koopa::is_linux
        then
            koopa::update_etc_profile_d
            koopa::update_ldconfig
        fi
        if koopa::is_installed configure-vm
        then
            # Allow passthrough of specific arguments to 'configure-vm' script.
            configure_flags=("--no-check")
            if [[ "$rsync" -eq 1 ]]
            then
                configure_flags+=("--source-ip=${source_ip}")
            fi
            configure-vm "${configure_flags[@]}"
        fi
        if [[ "$rsync" -eq 0 ]]
        then
            # This can cause some recipes to break.
            # > update-conda
            update-r-packages
            update-python-packages
            update-rust
            update-rust-packages
            update-perlbrew
            if koopa::is_linux
            then
                update-google-cloud-sdk
                update-pyenv
                update-rbenv
            elif koopa::is_macos
            then
                update-homebrew
                update-microsoft-office
                # > update-macos
                # > update-macos-defaults
            fi
        fi
        koopa::fix_zsh_permissions
    fi
    if [[ "$user" -eq 1 ]]
    then
        koopa::h2 "Updating user configuration."
        # Remove legacy directories from user config, if necessary.
        rm -frv "${config_prefix}/"\
{Rcheck,autojump,oh-my-zsh,pyenv,rbenv,spacemacs}
        # Update git repos.
        repos=(
            "${config_prefix}/docker"
            "${config_prefix}/docker-private"
            "${config_prefix}/dotfiles-private"
            "${config_prefix}/scripts-private"
            "${XDG_DATA_HOME}/Rcheck"
            "${HOME}/.emacs.d-doom"
        )
        for repo in "${repos[@]}"
        do
            [[ -d "$repo" ]] || continue
            (
                koopa::cd "$repo"
                koopa::git_pull
            )
        done
        koopa::install_dotfiles
        koopa::install_dotfiles_private
        koopa::update_spacemacs
    fi
    koopa::success "koopa update was successful."
    koopa::restart
    [[ "$system" -eq 1 ]] && koopa check-system
    return 0
}

# shellcheck disable=SC2120
koopa::update_conda() { # {{{1
    # """
    # Update Conda.
    # @note Updated 2020-07-11.
    # """
    local force
    force=0
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::conda_prefix)"
    koopa::assert_is_dir "$prefix"
    if [[ "$force" -eq 0 ]]
    then
        if koopa::is_anaconda
        then
            koopa::note 'Update not supported for Anaconda.'
            return 0
        fi
        koopa::exit_if_current_version conda
    fi
    koopa::h1 "Updating Conda at '${prefix}'."
    conda="${prefix}/condabin/conda"
    koopa::assert_is_file "$conda"
    (
        "$conda" update --yes --name='base' --channel='defaults' conda
        "$conda" update --yes --name='base' --channel='defaults' --all
        # > "$conda" clean --yes --tarballs
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::remove_broken_symlinks "$prefix"
    koopa::sys_set_permissions -r "$prefix"
    return 0
}

koopa::update_conda_envs() { # {{{1
    local conda conda_prefix envs prefix
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed conda
    conda_prefix="$(koopa::conda_prefix)"
    koopa::assert_is_dir "$conda_prefix"
    conda="${conda_prefix}/condabin/conda"
    koopa::assert_is_file conda
    readarray -t envs <<< "$( \
        find "${conda_prefix}/envs" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -print \
            | sort \
    )"
    if ! koopa::is_array_non_empty "${envs[@]}"
    then
        koopa::note 'Failed to detect any conda environments.'
        return 0
    fi
    # shellcheck disable=SC2119
    koopa::update_conda
    koopa::h1 "Updating ${#envs[@]} environments at \"${conda_prefix}\"."
    for prefix in "${envs[@]}"
    do
        koopa::h2 "Updating \"${prefix}\"."
        "$conda" update -y --prefix="$prefix" --all
    done
    # > "$conda" clean --yes --tarballs
    koopa::sys_set_permissions -r "$conda_prefix"
    return 0
}

koopa::update_perlbrew() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::exit_if_not_installed perlbrew
    koopa::assert_has_no_envs
    koopa::h1 'Updating Perlbrew.'
    perlbrew self-upgrade
    return 0
}

koopa::update_pyenv() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::exit_if_not_installed pyenv
    koopa::assert_has_no_envs
    koopa::h1 'Updating pyenv.'
    (
        koopa::cd "$(pyenv root)"
        git pull
    )
    return 0
}

koopa::update_python_packages() { # {{{1
    # """
    # Update all pip packages.
    # @note Updated 2020-07-13.
    # @seealso
    # - https://github.com/pypa/pip/issues/59
    # - https://stackoverflow.com/questions/2720014
    # """
    local name_fancy pkgs prefix python x
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::exit_if_not_installed "$python"
    name_fancy='Python packages'
    koopa::install_start "$name_fancy"
    x="$("$python" -m pip list --outdated --format='freeze')"
    x="$(koopa::print "$x" | grep -v '^\-e')"
    if [[ -z "$x" ]]
    then
        koopa::success 'All Python packages are current.'
        return 0
    fi
    prefix="$(koopa::python_site_packages_prefix)"
    readarray -t pkgs <<< "$(koopa::print "$x" | cut -d '=' -f 1)"
    koopa::dl 'Packages' "$(koopa::to_string "${pkgs[@]}")"
    koopa::dl 'Prefix' "$prefix"
    "$python" -m pip install --no-warn-script-location --upgrade "${pkgs[@]}"
    koopa::is_cellar "$python" && koopa::link_cellar python
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_rust() { # {{{1
    local force
    koopa::assert_has_no_envs
    force=0
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ "$force" -eq 0 ]] && koopa::exit_if_current_version rust
    koopa::h1 'Updating Rust via rustup.'
    koopa::exit_if_not_installed rustup
    export RUST_BACKTRACE='full'
    # rustup v1.21.0 fix.
    # https://github.com/rust-lang/rustup/issues/2166
    mkdir -pv "${RUSTUP_HOME}/downloads"
    # rustup v1.21.1 fix (2020-01-31).
    rm -f "${CARGO_HOME}/bin/"{'cargo-fmt','rustfmt'}
    # > rustup update stable
    rustup update
    return 0
}

koopa::update_venv() {
    # """
    # Update Python virtual environment.
    # @note Updated 2020-07-13.
    # """
    local array lines python
    koopa::assert_has_no_args "$#"
    python="$(koopa::python)"
    koopa::assert_is_installed "$python"
    if ! koopa::is_venv_active
    then
        koopa::note 'No active Python venv detected.'
        return 0
    fi
    koopa::h1 'Updating Python venv.'
    "$python" -m pip install --upgrade pip
    lines="$("$python" -m pip list --outdated --format='freeze')"
    readarray -t array <<< "$lines"
    koopa::is_array_non_empty "${array[@]}" || exit 0
    koopa::h1 "${#array[@]} outdated packages detected."
    koopa::print "$lines" \
        | cut -d '=' -f 1 \
        | xargs -n1 "$python" -m pip install --upgrade
    return 0
}

