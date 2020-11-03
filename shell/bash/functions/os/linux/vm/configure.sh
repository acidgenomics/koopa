#!/usr/bin/env bash

koopa::configure_vm() { # {{{1
    # """
    # Configure virtual machine.
    # @note Updated 2020-11-03.
    # """
    local dict install_base_flags mode prefixes
    koopa::assert_has_no_envs
    # Install mode:
    # - "bioconductor": Bioconductor mode, for continuous integration (CI)
    #   checks. This flag is intended installing different R/BioC versions on
    #   top of the Bioconductor (Debian) base image.
    # - "full": By default, this script skips installation of GNU utils and
    #   other dependencies that can take a long time to build from source. This
    #   works well for Docker builds but may not support additional software
    #   required on a full interactive VM.
    # - "minimal": Minimal config used for lightweight Docker images. This mode
    #   skips all program installation.
    # - "recommended": Install recommended packages (default).
    mode='recommended'
    # Associative array dictionary of key-value pairs.
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        # Conda distribution type to install (miniconda or anaconda).
        [conda]='miniconda'
        # Data disk prefix to use for app configuration (e.g. /mnt/data01).
        # Intended for full AWS EC2 or Azure VM instances.
        [data_disk_prefix]=''
        # Are we building inside a Docker container image?
        [docker]="$(
            if koopa::is_docker
            then
                koopa::print 1
            else
                koopa::print 0
            fi
        )"
        [install_aspera_connect]=0
        [install_autojump]=0
        [install_aws_cli]=1
        [install_azure_cli]=0
        [install_base_flags]=''
        [install_conda]=1
        [install_conda_envs]=0
        [install_curl]=0
        [install_docker]=0
        [install_docker_credential_pass]=0
        [install_emacs]=0
        [install_gcc]=0
        [install_google_cloud_sdk]=0
        [install_htop]=1
        [install_julia]=0
        [install_llvm]=0
        [install_lmod]=0
        [install_lmod]=0
        [install_lua]=0
        [install_luarocks]=0
        [install_neovim]=0
        [install_openjdk]=1
        [install_password_store]=0
        [install_perl_packages]=0
        [install_python]=1
        [install_python_packages]=1
        [install_r]=1
        [install_r_packages]=1
        [install_rstudio_server]=1
        [install_ruby_packages]=0
        [install_rust_packages]=0
        [install_shiny_server]=0
        [make_prefix]="$(koopa::make_prefix)"
        [passwordless_sudo]=1
        [python_version]="$(koopa::variable 'python')"
        [r_version]="$(koopa::variable 'r')"
        [remove_cache]=0
        [remove_skel]=1
        # Rsync mode will enable sync from "source_ip" to "data_disk".
        [rsync]=0
        # Source IP (for rsync mode).
        [source_ip]=''
        [ssh_key]=1
    )
    while (("$#"))
    do
        case "$1" in
            # Mode -------------------------------------------------------------
            --mode=*)
                mode="${1#*=}"
                shift 1
                ;;
            --bioconductor)
                mode='bioconductor'
                shift 1
                ;;
            --full)
                mode='full'
                shift 1
                ;;
            --minimal)
                mode='minimal'
                shift 1
                ;;
            --recommended)
                mode='recommended'
                shift 1
                ;;
            # Other variables --------------------------------------------------
            --data-disk=*)
                dict[data_disk_prefix]="${1#*=}"
                shift 1
                ;;
            --python-version=*)
                dict[python_version]="${1#*=}"
                shift 1
                ;;
            --no-passwordless-sudo)
                dict[passwordless_sudo]=0
                shift 1
                ;;
            --no-python)
                dict[install_python]=0
                dict[install_python_packages]=0
                ;;
            --no-r)
                dict[install_r]=0
                dict[install_r_packages]=0
                shift 1
                ;;
            --no-remove-skel)
                dict[remove_skel]=0
                shift 1
                ;;
            --r-version=*)
                dict[r_version]="${1#*=}"
                shift 1
                ;;
            --source-ip=*)
                dict[source_ip]="${1#*=}"
                shift 1
                ;;
            # Invalid arg trap -------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    # Automatically set internal variables, based on user input.
    case "$mode" in
        bioconductor)
            dict[install_aws_cli]=0
            dict[install_llvm]=1
            dict[install_python_packages]=0
            dict[install_r]=0
            dict[install_r_packages]=0
            dict[install_rstudio_server]=1
            dict[install_shiny_server]=0
            ;;
        full)
            # > dict[install_gcc]=1
            # > dict[install_the_silver_searcher]=1
            dict[conda]='anaconda'
            dict[install_aspera_connect]=1
            dict[install_base_flags]='--full'
            dict[install_conda_envs]=1
            dict[install_curl]=1
            dict[install_llvm]=1
            dict[install_lmod]=1
            dict[install_perl_packages]=1
            dict[install_rstudio_server]=1
            dict[install_ruby_packages]=1
            dict[install_rust_packages]=1
            dict[install_shiny_server]=1

            # FIXME These need to be set as defaults above.
            dict[install_autojump]=1
            dict[install_azure_cli]=1
            dict[install_docker]=1
            dict[install_docker_credential_pass]=1
            dict[install_emacs]=1
            dict[install_google_cloud_sdk]=1
            dict[install_julia]=1
            dict[install_lmod]=1
            dict[install_lua]=1
            dict[install_luarocks]=1
            dict[install_neovim]=1
            dict[install_password_store]=1
            ;;
        minimal|recommended)
            # No need to change any variables here.
            ;;
        *)
            koopa::stop 'Invalid mode.'
            ;;
    esac
    if [[ -n "${dict[source_ip]}" ]]
    then
        dict[rsync]=1
    fi
    if [[ "${dict[docker]}" -eq 1 ]]
    then
        dict[remove_cache]=1
        dict[ssh_key]=0
    fi
    if [[ "${dict[rsync]}" -eq 1 ]]
    then
        dict[install_aspera_connect]=0
        dict[install_conda]=0
        dict[install_conda_envs]=0
        dict[install_perl_packages]=0
        dict[install_python_packages]=0
        dict[install_r_packages]=0
        dict[install_ruby_packages]=0
        dict[install_rust_packages]=0
    fi

    # Initial configuration {{{2
    # --------------------------------------------------------------------------

    koopa::h1 'Configuring virtual machine.'
    # Enable useful global variables that make configuration easier.
    # > export GPG_TTY=/dev/null
    export FORCE_UNSAFE_CONFIGURE=1
    export KOOPA_FORCE=1
    export PYTHONDONTWRITEBYTECODE=true

    # Root user and sudo fixes {{{3
    # --------------------------------------------------------------------------

    if [[ "${dict[passwordless_sudo]}" -eq 1 ]]
    then
        koopa::enable_passwordless_sudo
        koopa::fix_sudo_setrlimit_error
    fi

    # Remove skeleton files {{{3
    # --------------------------------------------------------------------------

    # Remove default user-specific skeleton configuration files. This in
    # particular helps keep shell configuration consistent, especialy for
    # Ubuntu, which sets a lot of config in bashrc.
    if [[ "${dict[remove_skel]}" -eq 1 ]]
    then
        koopa::rm -S '/etc/skel'
    fi

    # Early return in minimal mode {{{3
    # --------------------------------------------------------------------------

    if [[ "$mode" == "minimal" ]]
    then
        koopa::success 'Minimal configuration was successful.'
        return 0
    fi

    # Disk configuration {{{3
    # --------------------------------------------------------------------------

    # Show available disk space.
    koopa::info 'Checking available local disk space.'
    df -h '/'
    # Ensure essential target prefixes exist.
    koopa::mkdir "${dict[make_prefix]}" "${dict[app_prefix]}"
    # Set up secondary data disk, if applicable.
    if [[ -e "${dict[data_disk_prefix]}" ]]
    then
        koopa::link_data_disk "${dict[data_disk_prefix]}"
    fi

    # Base system {{{2
    # --------------------------------------------------------------------------

    koopa::h2 'Installing base system.'
    koopa::update_etc_profile_d
    koopa::install_dotfiles
    koopa::mkdir "${dict[make_prefix]}"
    koopa::assert_is_installed install-base
    install_base_flags=("${dict[install_base_flags]}")
    install-base "${install_base_flags[@]:-}"
    koopa::assert_is_installed \
        'autoconf'    'bc'   'bzip2' 'g++'    'gcc' 'gfortran' \
        'gzip'        'make' 'man'   'msgfmt' 'tar' 'unzip' \
        'xml2-config' 'xz'
    koopa::assert_is_file '/usr/bin/gcc' '/usr/bin/g++'
    sudo ldconfig

    # rsync mode {{{2
    # --------------------------------------------------------------------------

    if [[ "${dict[rsync]}" -eq 1 ]]
    then
        koopa::rsync_vm --source-ip="${dict[source_ip]}"
    fi

    # Programs {{{2
    # --------------------------------------------------------------------------

    [[ "${dict[install_python]}" -eq 1 ]] && \
        install-python --version="${dict[python_version]}"
    [[ "${dict[install_conda]}" -eq 1 ]] && \
        "install-${dict[conda]}"
    [[ "${dict[install_openjdk]}" -eq 1 ]] && \
        install-openjdk
    [[ "${dict[install_llvm]}" -eq 1 ]] && \
        koopa::run_if_installed install-llvm



    # FIXME NEED TO MAKE THESE CONDITIONAL.
    full='fixme'
    if [[ "$full" -eq 1 ]]
    then
        install-curl
        install-wget
        install-cmake
        install-make
        install-autoconf
        install-automake
        install-libtool
        install-texinfo
        install-binutils
        install-coreutils
        install-findutils
        install-patch
        install-pkg-config
        install-ncurses
        install-gnupg
        install-grep
        install-gawk
        install-parallel
        install-rsync
        install-sed
        install-libevent
        install-taglib
        install-zsh
        install-bash
        install-fish
        install-git
        install-openssh
        install-perl
        install-geos
        install-sqlite
        install-proj
        install-gdal
        install-hdf5
        install-gsl
        install-udunits
        install-subversion
        install-go
        install-ruby
        install-rust
        install-neofetch
        install-fzf
    fi
    [[ "${dict[install_the_silver_searcher]}" -eq 1 ]] && \
        install-the-silver-searcher
    install-tmux
    install-vim
    install-shellcheck
    install-shunit2
    [[ "${dict[install_aws_cli]}" -eq 1 ]] && \
        install-aws-cli
    [[ "${dict[install_azure_cli]}" -eq 1 ]] && \
        koopa::run_if_installed install-azure-cli
    [[ "${dict[install_docker]}" -eq 1 ]] && \
        koopa::run_if_installed install-docker
    [[ "${dict[install_google_cloud_sdk]}" -eq 1 ]] && \
        koopa::run_if_installed install-google-cloud-sdk

        install-password-store
        install-docker-credential-pass
        install-neovim
        install-emacs
        install-julia
        install-lua
        install-luarocks
    [[ "${dict[install_lmod]}" -eq 1 ]] && \
        install-lmod
    [[ "${dict[install_htop]}" -eq 1 ]] && \
        install-htop
    [[ "${dict[install_autojump]}" -eq 1 ]] && \
        install-autojump
    [[ "${dict[install_gcc]}" -eq 1 ]] && \
        install-gcc
    # Install R.
    if [[ "${dict[install_r]}" -eq 1 ]]
    then
        if koopa::is_fedora
        then
            koopa::assert_is_installed R
        elif [[ "${dict[r_version]}" == 'devel' ]]
        then
            install-r-devel
        elif koopa::is_installed install-r-cran-binary
        then
            install-r-cran-binary --version="${dict[r_version]}"
        else
            install-r --version="${dict[r_version]}"
        fi
        koopa::update_r_config
    fi
    # Install RStudio software.
    [[ "${dict[install_rstudio_server]}" -eq 1 ]] && \
        koopa::run_if_installed install-rstudio-server
    [[  "${dict[install_shiny_server]}" -eq 1 ]] && \
        koopa::run_if_installed install-shiny-server
    # Ensure shared library configuration is current.
    [[ "${dict[install_lmod]}" -eq 1 ]] && \
        koopa::update_lmod_config
    sudo ldconfig

    # Language-specific packages {{{2
    # --------------------------------------------------------------------------

    [[ "${dict[install_python_packages]}" -eq 1 ]] && \
        install-python-packages
    [[ "${dict[install_r_packages]}" -eq 1 ]] && \
        install-r-packages
    [[ "${dict[install_python_packages]}" -eq 1 ]] && \
        install-python-packages
    [[ "${dict[install_r_packages]}" -eq 1 ]] && \
        install-r-packages
    [[ "${dict[install_perl_packages]}" -eq 1 ]] && \
        install-perl-packages
    [[ "${dict[install_ruby_packages]}" -eq 1 ]] && \
        install-ruby-packages
    [[ "${dict[install_rust_packages]}" -eq 1 ]] && \
        install-rust-packages

    # Bioinformatics tools {{{2
    # --------------------------------------------------------------------------

    [[ "${dict[install_aspera_connect]}" -eq 1 ]] && \
        install-aspera-connect
    [[ "${dict[install_conda_envs]}" -eq 1 ]] && \
        conda-create-bioinfo-envs

    # Final steps {{{2
    # --------------------------------------------------------------------------

    # Generate an SSH key.
    [[ "${dict[ssh_key]}" -eq 1 ]] && \
        koopa::generate_ssh_key

    # Clean up and fix permissions {{{3
    # --------------------------------------------------------------------------

    prefixes=("${dict[make_prefix]}" "${dict[app_prefix]}")
    koopa::sys_set_permissions -r "${prefixes[@]}"
    koopa::remove_broken_symlinks "${prefixes[@]}"
    # > koopa::remove_empty_dirs "${prefixes[@]}"
    # > koopa::fix_pyenv_permissions
    # > koopa::fix_rbenv_permissions
    koopa::fix_zsh_permissions
    if [[ "${dict[remove_cache]}" -eq 1 ]]
    then
        koopa::remove_linux_cache
    fi
    koopa::success 'Configuration completed successfully.'
    return 0
}

koopa::link_data_disk() { # {{{1
    # """
    # Link a secondary data disk.
    # @note Updated 2020-11-03.
    # """
    local app_prefix dd_link_prefix dd_prefix dd_real_prefix
    dd_prefix="${1:?}"
    dd_link_prefix="$(koopa::data_disk_link_prefix)"
    app_prefix="$(koopa::app_prefix)"
    if [[ -e "$dd_prefix" ]]
    then
        koopa::info "Data disk detected at '${dd_prefix}'."
    else
        koopa::stop "Failed to detect data disk at '${dd_prefix}'."
    fi
    # Early return if data disk is already symlinked.
    if [[ -L "$dd_link_prefix" ]] && [[ -L "$app_prefix" ]]
    then
        return 0
    fi
    koopa::h2 "Symlinking '${dd_link_prefix}' on '${dd_prefix}'."
    koopa::sys_rm "$dd_link_prefix" "$app_prefix"
    # e.g. '/mnt/data01/n'.
    dd_real_prefix="${dd_prefix}${dd_link_prefix}"
    koopa::sys_ln "$dd_real_prefix" "$dd_link_prefix"
    # e.g. 'opt'.
    app_prefix_bn="$(basename "$app_prefix")"
    # e.g. '/mnt/data01/n/opt'
    app_prefix_real="${dd_real_prefix}/${app_prefix_bn}"
    koopa::mkdir "$app_prefix_real"
    # e.g. '/mnt/data01/n/opt' to '/usr/local/opt'.
    koopa::sys_ln "$app_prefix_real" "$app_prefix"
    return 0
}

koopa::remove_linux_cache() { # {{{1
    # """
    # Remove cache files.
    # @note Updated 2020-11-03.
    #
    # Don't clear '/var/log/' here, as this can mess with 'sshd'.
    # """
    koopa::assert_is_linux
    koopa::h2 'Removing Linux caches, logs, and temporary files.'
    koopa::rm -S \
        '/root/.cache' \
        '/tmp/'* \
        '/var/backups/'* \
        '/var/cache/'*
    if koopa::is_debian_like
    then
        koopa::rm -S '/var/lib/apt/lists/'*
    fi
    return 0
}
