#!/usr/bin/env bash

koopa::configure_vm() { # {{{1
    # """
    # Configure virtual machine.
    # @note Updated 2020-11-10.
    # """
    local dict install_base_flags mode prefixes
    koopa::assert_has_no_envs
    # Install mode:
    # - "bioconductor": Bioconductor mode, for continuous integration (CI)
    #   checks. This flag is intended installing different R/BioC versions on
    #   top of the Bioconductor (Debian) base image.
    # - "default": Install recommended packages (default).
    # - "full": By default, this script skips installation of GNU utils and
    #   other dependencies that can take a long time to build from source. This
    #   works well for Docker builds but may not support additional software
    #   required on a full interactive VM.
    # - "minimal": Minimal config used for lightweight Docker images. This mode
    #   skips all program installation.
    mode='default'
    # Associative array dictionary of key-value pairs.
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        [data_disk_prefix]=''
        [delete_cache]=0
        [delete_skel]=1
        [docker]="$(
            if koopa::is_docker
            then
                koopa::print 1
            else
                koopa::print 0
            fi
        )"
        [install_aspera_connect]=0
        [install_autoconf]=0
        [install_autojump]=0
        [install_automake]=0
        [install_aws_cli]=1
        [install_azure_cli]=0
        [install_base_flags]=''
        [install_bash]=0
        [install_binutils]=0
        [install_cmake]=0
        [install_conda]=1
        [install_conda_envs]=0
        [install_coreutils]=0
        [install_curl]=0
        [install_curl]=0
        [install_docker]=0
        [install_docker_credential_pass]=0
        [install_emacs]=0
        [install_findutils]=0
        [install_fish]=0
        [install_fzf]=0
        [install_gawk]=0
        [install_gcc]=0
        [install_gdal]=0
        [install_geos]=0
        [install_git]=0
        [install_gnupg]=0
        [install_go]=0
        [install_google_cloud_sdk]=0
        [install_grep]=0
        [install_gsl]=0
        [install_hdf5]=0
        [install_homebrew]=1
        [install_htop]=1
        [install_julia]=0
        [install_libevent]=0
        [install_libtool]=0
        [install_llvm]=0
        [install_lmod]=0
        [install_lmod]=0
        [install_lua]=0
        [install_luarocks]=0
        [install_make]=0
        [install_ncurses]=0
        [install_neofetch]=0
        [install_neovim]=0
        [install_openjdk]=1
        [install_openssh]=0
        [install_parallel]=0
        [install_password_store]=0
        [install_patch]=0
        [install_perl]=0
        [install_perl_packages]=0
        [install_pkg_config]=0
        [install_proj]=0
        [install_python]=1
        [install_python_packages]=0
        [install_r]=1
        [install_r_packages]=0
        [install_rstudio_server]=0
        [install_rsync]=0
        [install_ruby]=0
        [install_ruby_packages]=0
        [install_rust]=0
        [install_rust_packages]=0
        [install_sed]=0
        [install_shellcheck]=1
        [install_shiny_server]=0
        [install_shunit2]=1
        [install_sqlite]=0
        [install_subversion]=0
        [install_taglib]=0
        [install_texinfo]=0
        [install_the_silver_searcher]=0
        [install_tmux]=1
        [install_udunits]=0
        [install_vim]=1
        [install_wget]=0
        [install_zsh]=0
        [make_prefix]="$(koopa::make_prefix)"
        [passwordless_sudo]=1
        [python_version]="$(koopa::variable 'python')"
        [r_version]="$(koopa::variable 'r')"
        [rsync]=0
        [source_ip]=''
        [ssh_key]=1
        [which_conda]='miniconda'
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
            --default|recommended)
                mode='default'
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
            # Other variables --------------------------------------------------
            --data-disk=*)
                dict[data_disk_prefix]="${1#*=}"
                shift 1
                ;;
            --python-version=*)
                dict[python_version]="${1#*=}"
                shift 1
                ;;
            --no-delete-skel)
                dict[delete_skel]=0
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
            dict[install_conda]=1
            dict[install_homebrew]=0
            dict[install_htop]=0
            dict[install_llvm]=0  # enable?
            dict[install_openjdk]=1
            dict[install_python]=0  # enable?
            dict[install_python_packages]=0
            dict[install_r]=0
            dict[install_r_packages]=0
            dict[install_rstudio_server]=0
            dict[install_shellcheck]=0
            dict[install_shiny_server]=0
            dict[install_shunit2]=0
            dict[install_tmux]=0
            dict[install_vim]=0
            ;;
        full)
            # > dict[install_gcc]=1
            # > dict[install_the_silver_searcher]=1
            dict[install_aspera_connect]=1
            dict[install_autoconf]=1
            dict[install_autojump]=1
            dict[install_automake]=1
            dict[install_azure_cli]=1
            dict[install_base_flags]='--full'
            dict[install_bash]=1
            dict[install_binutils]=1
            dict[install_cmake]=1
            dict[install_conda_envs]=1
            dict[install_coreutils]=1
            dict[install_curl]=1
            dict[install_curl]=1
            dict[install_docker]=1
            dict[install_docker_credential_pass]=1
            dict[install_emacs]=1
            dict[install_findutils]=1
            dict[install_fish]=1
            dict[install_fzf]=1
            dict[install_gawk]=1
            dict[install_gdal]=1
            dict[install_geos]=1
            dict[install_git]=1
            dict[install_gnupg]=1
            dict[install_go]=1
            dict[install_google_cloud_sdk]=1
            dict[install_grep]=1
            dict[install_gsl]=1
            dict[install_hdf5]=1
            dict[install_julia]=1
            dict[install_libevent]=1
            dict[install_libtool]=1
            dict[install_llvm]=1
            dict[install_lmod]=1
            dict[install_lua]=1
            dict[install_luarocks]=1
            dict[install_make]=1
            dict[install_ncurses]=1
            dict[install_neofetch]=1
            dict[install_neovim]=1
            dict[install_openssh]=1
            dict[install_parallel]=1
            dict[install_password_store]=1
            dict[install_patch]=1
            dict[install_perl]=1
            dict[install_perl_packages]=1
            dict[install_pkg_config]=1
            dict[install_proj]=1
            dict[install_python_packages]=1
            dict[install_r_packages]=1
            dict[install_rstudio_server]=1
            dict[install_rsync]=1
            dict[install_ruby]=1
            dict[install_ruby_packages]=1
            dict[install_rust]=1
            dict[install_rust_packages]=1
            dict[install_sed]=1
            dict[install_shiny_server]=1
            dict[install_sqlite]=1
            dict[install_subversion]=1
            dict[install_taglib]=1
            dict[install_texinfo]=1
            dict[install_udunits]=1
            dict[install_wget]=1
            dict[install_zsh]=1
            dict[which_conda]='anaconda'
            ;;
        default|minimal)
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
        dict[delete_cache]=1
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
    # Building Python from source can break dnf on Fedora 32+.
    if koopa::is_fedora
    then
        dict[install_python]=0
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

    # Delete skeleton files {{{3
    # --------------------------------------------------------------------------

    # Delete default user-specific skeleton configuration files. This in
    # particular helps keep shell configuration consistent, especialy for
    # Ubuntu, which sets a lot of config in bashrc.
    if [[ "${dict[delete_skel]}" -eq 1 ]]
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
    prefixes=("${dict[make_prefix]}" "${dict[app_prefix]}")
    koopa::sys_mkdir "${prefixes[@]}"
    koopa::sys_set_permissions -r "${prefixes[@]}"
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

    [[ "${dict[install_homebrew]}" -eq 1 ]] && \
        install-homebrew
    [[ "${dict[install_llvm]}" -eq 1 ]] && \
        koopa::run_if_installed install-llvm
    [[ "${dict[install_openjdk]}" -eq 1 ]] && \
        install-openjdk
    if [[ "${dict[install_python]}" -eq 1 ]]
    then
        install-python --version="${dict[python_version]}"
        koopa::install_py_koopa
    fi
    [[ "${dict[install_conda]}" -eq 1 ]] && \
        "install-${dict[which_conda]}"
    [[ "${dict[install_gcc]}" -eq 1 ]] && \
        install-gcc
    [[ "${dict[install_curl]}" -eq 1 ]] && \
        install-curl
    [[ "${dict[install_wget]}" -eq 1 ]] && \
        install-wget
    [[ "${dict[install_cmake]}" -eq 1 ]] && \
        install-cmake
    [[ "${dict[install_make]}" -eq 1 ]] && \
        install-make
    [[ "${dict[install_autoconf]}" -eq 1 ]] && \
        install-autoconf
    [[ "${dict[install_automake]}" -eq 1 ]] && \
        install-automake
    [[ "${dict[install_libtool]}" -eq 1 ]] && \
        install-libtool
    [[ "${dict[install_texinfo]}" -eq 1 ]] && \
        install-texinfo
    [[ "${dict[install_binutils]}" -eq 1 ]] && \
        install-binutils
    [[ "${dict[install_coreutils]}" -eq 1 ]] && \
        install-coreutils
    [[ "${dict[install_findutils]}" -eq 1 ]] && \
        install-findutils
    [[ "${dict[install_patch]}" -eq 1 ]] && \
        install-patch
    [[ "${dict[install_pkg_config]}" -eq 1 ]] && \
        install-pkg-config
    [[ "${dict[install_ncurses]}" -eq 1 ]] && \
        install-ncurses
    [[ "${dict[install_gnupg]}" -eq 1 ]] && \
        install-gnupg
    [[ "${dict[install_grep]}" -eq 1 ]] && \
        install-grep
    [[ "${dict[install_gawk]}" -eq 1 ]] && \
        install-gawk
    [[ "${dict[install_parallel]}" -eq 1 ]] && \
        install-parallel
    [[ "${dict[install_rsync]}" -eq 1 ]] && \
        install-rsync
    [[ "${dict[install_sed]}" -eq 1 ]] && \
        install-sed
    [[ "${dict[install_libevent]}" -eq 1 ]] && \
        install-libevent
    [[ "${dict[install_taglib]}" -eq 1 ]] && \
        install-taglib
    [[ "${dict[install_zsh]}" -eq 1 ]] && \
        install-zsh
    [[ "${dict[install_bash]}" -eq 1 ]] && \
        install-bash
    [[ "${dict[install_fish]}" -eq 1 ]] && \
        install-fish
    [[ "${dict[install_git]}" -eq 1 ]] && \
        install-git
    [[ "${dict[install_openssh]}" -eq 1 ]] && \
        install-openssh
    [[ "${dict[install_perl]}" -eq 1 ]] && \
        install-perl
    [[ "${dict[install_geos]}" -eq 1 ]] && \
        install-geos
    [[ "${dict[install_sqlite]}" -eq 1 ]] && \
        install-sqlite
    [[ "${dict[install_proj]}" -eq 1 ]] && \
        install-proj
    [[ "${dict[install_gdal]}" -eq 1 ]] && \
        install-gdal
    [[ "${dict[install_hdf5]}" -eq 1 ]] && \
        install-hdf5
    [[ "${dict[install_gsl]}" -eq 1 ]] && \
        install-gsl
    [[ "${dict[install_udunits]}" -eq 1 ]] && \
        install-udunits
    [[ "${dict[install_subversion]}" -eq 1 ]] && \
        install-subversion
    [[ "${dict[install_go]}" -eq 1 ]] && \
        install-go
    [[ "${dict[install_ruby]}" -eq 1 ]] && \
        install-ruby
    [[ "${dict[install_rust]}" -eq 1 ]] && \
        install-rust
    [[ "${dict[install_neofetch]}" -eq 1 ]] && \
        install-neofetch
    [[ "${dict[install_fzf]}" -eq 1 ]] && \
        install-fzf
    [[ "${dict[install_the_silver_searcher]}" -eq 1 ]] && \
        install-the-silver-searcher
    [[ "${dict[install_tmux]}" -eq 1 ]] && \
        install-tmux
    [[ "${dict[install_vim]}" -eq 1 ]] && \
        install-vim
    [[ "${dict[install_shellcheck]}" -eq 1 ]] && \
        install-shellcheck
    [[ "${dict[install_shunit2]}" -eq 1 ]] && \
        install-shunit2
    [[ "${dict[install_aws_cli]}" -eq 1 ]] && \
        install-aws-cli
    [[ "${dict[install_azure_cli]}" -eq 1 ]] && \
        koopa::run_if_installed install-azure-cli
    [[ "${dict[install_docker]}" -eq 1 ]] && \
        koopa::run_if_installed install-docker
    [[ "${dict[install_google_cloud_sdk]}" -eq 1 ]] && \
        koopa::run_if_installed install-google-cloud-sdk
    [[ "${dict[install_password_store]}" -eq 1 ]] && \
        install-password-store
    [[ "${dict[install_docker_credential_pass]}" -eq 1 ]] && \
        install-docker-credential-pass
    [[ "${dict[install_neovim]}" -eq 1 ]] && \
        install-neovim
    [[ "${dict[install_emacs]}" -eq 1 ]] && \
        install-emacs
    [[ "${dict[install_julia]}" -eq 1 ]] && \
        install-julia
    [[ "${dict[install_lua]}" -eq 1 ]] && \
        install-lua
    [[ "${dict[install_luarocks]}" -eq 1 ]] && \
        install-luarocks
    [[ "${dict[install_lmod]}" -eq 1 ]] && \
        install-lmod
    [[ "${dict[install_htop]}" -eq 1 ]] && \
        install-htop
    [[ "${dict[install_autojump]}" -eq 1 ]] && \
        install-autojump
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
        koopa::install_r_koopa
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

    koopa::sys_set_permissions -r "${prefixes[@]}"
    koopa::remove_broken_symlinks "${prefixes[@]}"
    # > koopa::remove_empty_dirs "${prefixes[@]}"
    # > koopa::fix_pyenv_permissions
    # > koopa::fix_rbenv_permissions
    koopa::fix_zsh_permissions
    if [[ "${dict[delete_cache]}" -eq 1 ]]
    then
        koopa::delete_cache
    fi
    koopa::success 'Configuration completed successfully.'
    return 0
}

koopa::link_data_disk() { # {{{1
    # """
    # Link a secondary data disk.
    # @note Updated 2020-11-10.
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
    koopa::sys_mkdir "$app_prefix_real"
    # e.g. '/mnt/data01/n/opt' to '/usr/local/opt'.
    koopa::sys_ln "$app_prefix_real" "$app_prefix"
    return 0
}
