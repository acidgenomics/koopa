#!/usr/bin/env bash

koopa_linux_configure_system() { # {{{1
    # """
    # Configure Linux system.
    # @note Updated 2022-02-23.
    #
    # Intended primarily for virtual machine and Docker image builds.
    #
    # @section Install mode:
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
    # """
    local dict prefixes
    koopa_assert_has_no_envs
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [delete_cache]=0
        [delete_skel]=1
        [docker]="$(
            if koopa_is_docker
            then
                koopa_print 1
            else
                koopa_print 0
            fi
        )"
        [install_aspera_connect]=0
        [install_autoconf]=0
        [install_automake]=0
        [install_aws_cli]=0
        [install_azure_cli]=0
        [install_base_system_args]=''
        [install_bash]=0
        [install_binutils]=0
        [install_cmake]=0
        [install_conda]=0
        [install_conda_envs]=0
        [install_coreutils]=0
        [install_curl]=0
        [install_curl]=0
        [install_docker]=0
        [install_docker_credential_pass]=0
        [install_dotfiles]=0
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
        [install_homebrew]=0
        [install_homebrew_bundle]=0
        [install_htop]=0
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
        [install_openjdk]=0
        [install_openssh]=0
        [install_parallel]=0
        [install_password_store]=0
        [install_patch]=0
        [install_perl]=0
        [install_perl_packages]=0
        [install_pkg_config]=0
        [install_proj]=0
        [install_python]=0
        [install_python_packages]=0
        [install_r]=0
        [install_r_packages]=0
        [install_rstudio_server]=0
        [install_rsync]=0
        [install_ruby]=0
        [install_ruby_packages]=0
        [install_rust]=0
        [install_rust_packages]=0
        [install_sed]=0
        [install_shellcheck]=0
        [install_shiny_server]=0
        [install_shunit2]=0
        [install_sqlite]=0
        [install_subversion]=0
        [install_taglib]=0
        [install_texinfo]=0
        [install_the_silver_searcher]=0
        [install_tmux]=0
        [install_udunits]=0
        [install_vim]=0
        [install_wget]=0
        [install_zsh]=0
        [make_prefix]="$(koopa_make_prefix)"
        [mode]='default'
        [opt_prefix]="$(koopa_opt_prefix)"
        [passwordless_sudo]=0
        [python_version]="$(koopa_variable 'python')"
        [r_version]="$(koopa_variable 'r')"
        [ssh_key]=1
        [which_conda]='conda'
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--mode='*)
                dict[mode]="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict[mode]="${2:?}"
                shift 2
                ;;
            '--python-version='*)
                dict[python_version]="${1#*=}"
                shift 1
                ;;
            '--python-version')
                dict[python_version]="${2:?}"
                shift 2
                ;;
            '--r-version='*)
                dict[r_version]="${1#*=}"
                shift 1
                ;;
            '--r-version')
                dict[r_version]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--all' | \
            '--full')
                dict[mode]='full'
                shift 1
                ;;
            '--base-image')
                dict[mode]='base-image'
                shift 1
                ;;
            '--bioconductor')
                dict[mode]='bioconductor'
                shift 1
                ;;
            '--default' | \
            '--recommended')
                dict[mode]='default'
                shift 1
                ;;
            '--minimal')
                dict[mode]='minimal'
                shift 1
                ;;
            '--verbose')
                set -o xtrace
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    # Automatically set internal variables, based on user input.
    case "${dict[mode]}" in
        'default' | \
        'minimal')
            ;;
        'base-image')
            # > dict[install_bash]=1
            # > dict[install_zsh]=1
            dict[install_base_system_args]='--base-image'
            ;;
        'bioconductor')
            dict[install_dotfiles]=1
            dict[install_openjdk]=1
            ;;
        'full')
            dict[install_aspera_connect]=1
            dict[install_autoconf]=1
            dict[install_automake]=1
            dict[install_azure_cli]=1
            dict[install_base_system_args]='--full'
            dict[install_bash]=1
            dict[install_binutils]=1
            dict[install_cmake]=1
            dict[install_conda_envs]=1
            dict[install_coreutils]=1
            dict[install_curl]=1
            dict[install_curl]=1
            dict[install_docker]=1
            dict[install_docker_credential_pass]=1
            dict[install_dotfiles]=1
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
            dict[install_homebrew]=1
            dict[install_homebrew_bundle]=1
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
            dict[passwordless_sudo]=1
            dict[which_conda]='anaconda'
            ;;
        'recommended')
            dict[install_aws_cli]=1
            dict[install_conda]=1
            dict[install_dotfiles]=1
            dict[install_homebrew]=1
            dict[install_htop]=1
            dict[install_openjdk]=1
            dict[install_python]=1
            dict[install_r]=1
            dict[install_shellcheck]=1
            dict[install_shunit2]=1
            dict[install_tmux]=1
            dict[install_vim]=1
            ;;
        *)
            koopa_stop 'Invalid mode.'
            ;;
    esac
    if [[ "${dict[docker]}" -eq 1 ]]
    then
        dict[delete_cache]=1
        dict[ssh_key]=0
    fi
    # NOTE Building Python from source can break dnf on Fedora 32+.
    if koopa_is_fedora
    then
        dict[install_python]=0
    fi
    # Initial configuration {{{2
    # --------------------------------------------------------------------------
    koopa_h1 'Configuring system.'
    # Enable useful global variables that make configuration easier.
    # > export GPG_TTY=/dev/null
    export FORCE_UNSAFE_CONFIGURE=1
    export KOOPA_FORCE=1
    export PYTHONDONTWRITEBYTECODE=true
    # Root user and sudo fixes {{{3
    # --------------------------------------------------------------------------
    if [[ "${dict[passwordless_sudo]}" -eq 1 ]]
    then
        koopa_enable_passwordless_sudo
        koopa_linux_fix_sudo_setrlimit_error
    fi
    # Delete skeleton files {{{3
    # --------------------------------------------------------------------------
    # Delete default user-specific skeleton configuration files. This in
    # particular helps keep shell configuration consistent, especialy for
    # Ubuntu, which sets a lot of config in bashrc.
    if [[ "${dict[delete_skel]}" -eq 1 ]]
    then
        koopa_rm --sudo '/etc/skel'
    fi
    # Early return in minimal mode {{{3
    # --------------------------------------------------------------------------
    if [[ "${dict[mode]}" == 'minimal' ]]
    then
        koopa_alert_success 'Minimal configuration was successful.'
        return 0
    fi
    # Disk configuration {{{3
    # --------------------------------------------------------------------------
    # Show available disk space.
    koopa_alert 'Checking available local disk space.'
    df -h '/'
    # Ensure essential target prefixes exist.
    prefixes=(
        "${dict[app_prefix]}"
        "${dict[make_prefix]}"
        "${dict[opt_prefix]}"
    )
    koopa_sys_mkdir "${prefixes[@]}"
    koopa_sys_set_permissions --recursive "${prefixes[@]}"
    # Base system {{{2
    # --------------------------------------------------------------------------
    koopa_alert 'Installing base system.'
    koopa_linux_update_etc_profile_d
    koopa install base-system "${dict[install_base_system_args]}"
    # Consider requiring: gfortran, xml2-config.
    koopa_assert_is_installed \
        'autoconf' \
        'bc' \
        'bzip2' \
        'g++' \
        'gcc' \
        'gzip' \
        'make' \
        'man' \
        'msgfmt' \
        'tar' \
        'unzip' \
        'xz'
    koopa_assert_is_file '/usr/bin/gcc' '/usr/bin/g++'
    koopa_linux_update_ldconfig
    # Programs {{{2
    # --------------------------------------------------------------------------
    [[ "${dict[install_dotfiles]}" -eq 1 ]] && \
        koopa install dotfiles
    [[ "${dict[install_homebrew]}" -eq 1 ]] && \
        koopa install homebrew
    [[ "${dict[install_homebrew_bundle]}" -eq 1 ]] && \
        koopa install homebrew-bundle
    [[ "${dict[install_llvm]}" -eq 1 ]] && \
        koopa install llvm
    [[ "${dict[install_openjdk]}" -eq 1 ]] && \
        koopa install openjdk
    [[ "${dict[install_python]}" -eq 1 ]] && \
        koopa install python --version="${dict[python_version]}"
    [[ "${dict[install_conda]}" -eq 1 ]] && \
        koopa install "${dict[which_conda]}"
    [[ "${dict[install_gcc]}" -eq 1 ]] && \
        koopa install gcc
    [[ "${dict[install_curl]}" -eq 1 ]] && \
        koopa install curl
    [[ "${dict[install_wget]}" -eq 1 ]] && \
       koopa install wget
    [[ "${dict[install_cmake]}" -eq 1 ]] && \
       koopa install cmake
    [[ "${dict[install_make]}" -eq 1 ]] && \
       koopa install make
    [[ "${dict[install_autoconf]}" -eq 1 ]] && \
       koopa install autoconf
    [[ "${dict[install_automake]}" -eq 1 ]] && \
       koopa install automake
    [[ "${dict[install_libtool]}" -eq 1 ]] && \
       koopa install libtool
    [[ "${dict[install_texinfo]}" -eq 1 ]] && \
       koopa install texinfo
    [[ "${dict[install_binutils]}" -eq 1 ]] && \
       koopa install binutils
    [[ "${dict[install_coreutils]}" -eq 1 ]] && \
       koopa install coreutils
    [[ "${dict[install_findutils]}" -eq 1 ]] && \
       koopa install findutils
    [[ "${dict[install_patch]}" -eq 1 ]] && \
       koopa install patch
    [[ "${dict[install_pkg_config]}" -eq 1 ]] && \
       koopa install pkg-config
    [[ "${dict[install_ncurses]}" -eq 1 ]] && \
       koopa install ncurses
    [[ "${dict[install_gnupg]}" -eq 1 ]] && \
       koopa install gnupg
    [[ "${dict[install_grep]}" -eq 1 ]] && \
       koopa install grep
    [[ "${dict[install_gawk]}" -eq 1 ]] && \
       koopa install gawk
    [[ "${dict[install_parallel]}" -eq 1 ]] && \
       koopa install parallel
    [[ "${dict[install_rsync]}" -eq 1 ]] && \
       koopa install rsync
    [[ "${dict[install_sed]}" -eq 1 ]] && \
       koopa install sed
    [[ "${dict[install_libevent]}" -eq 1 ]] && \
       koopa install libevent
    [[ "${dict[install_taglib]}" -eq 1 ]] && \
       koopa install taglib
    [[ "${dict[install_zsh]}" -eq 1 ]] && \
       koopa install zsh
    [[ "${dict[install_bash]}" -eq 1 ]] && \
       koopa install bash
    [[ "${dict[install_fish]}" -eq 1 ]] && \
       koopa install fish
    [[ "${dict[install_git]}" -eq 1 ]] && \
       koopa install git
    [[ "${dict[install_openssh]}" -eq 1 ]] && \
       koopa install openssh
    [[ "${dict[install_perl]}" -eq 1 ]] && \
       koopa install perl
    [[ "${dict[install_geos]}" -eq 1 ]] && \
       koopa install geos
    [[ "${dict[install_sqlite]}" -eq 1 ]] && \
       koopa install sqlite
    [[ "${dict[install_proj]}" -eq 1 ]] && \
       koopa install proj
    [[ "${dict[install_gdal]}" -eq 1 ]] && \
       koopa install gdal
    [[ "${dict[install_hdf5]}" -eq 1 ]] && \
       koopa install hdf5
    [[ "${dict[install_gsl]}" -eq 1 ]] && \
       koopa install gsl
    [[ "${dict[install_udunits]}" -eq 1 ]] && \
       koopa install udunits
    [[ "${dict[install_subversion]}" -eq 1 ]] && \
       koopa install subversion
    [[ "${dict[install_go]}" -eq 1 ]] && \
       koopa install go
    [[ "${dict[install_ruby]}" -eq 1 ]] && \
       koopa install ruby
    [[ "${dict[install_rust]}" -eq 1 ]] && \
       koopa install rust
    [[ "${dict[install_neofetch]}" -eq 1 ]] && \
       koopa install neofetch
    [[ "${dict[install_fzf]}" -eq 1 ]] && \
       koopa install fzf
    [[ "${dict[install_the_silver_searcher]}" -eq 1 ]] && \
       koopa install the-silver-searcher
    [[ "${dict[install_tmux]}" -eq 1 ]] && \
       koopa install tmux
    [[ "${dict[install_vim]}" -eq 1 ]] && \
       koopa install vim
    [[ "${dict[install_shellcheck]}" -eq 1 ]] && \
       koopa install shellcheck
    [[ "${dict[install_shunit2]}" -eq 1 ]] && \
       koopa install shunit2
    [[ "${dict[install_aws_cli]}" -eq 1 ]] && \
       koopa install aws-cli
    [[ "${dict[install_azure_cli]}" -eq 1 ]] && \
        koopa install azure-cli
    [[ "${dict[install_docker]}" -eq 1 ]] && \
        koopa install docker
    [[ "${dict[install_google_cloud_sdk]}" -eq 1 ]] && \
        koopa install google-cloud-sdk
    [[ "${dict[install_password_store]}" -eq 1 ]] && \
        koopa install password-store
    [[ "${dict[install_docker_credential_pass]}" -eq 1 ]] && \
       koopa install docker-credential-pass
    [[ "${dict[install_neovim]}" -eq 1 ]] && \
       koopa install neovim
    [[ "${dict[install_emacs]}" -eq 1 ]] && \
       koopa install emacs
    [[ "${dict[install_julia]}" -eq 1 ]] && \
       koopa install julia
    [[ "${dict[install_lua]}" -eq 1 ]] && \
       koopa install lua
    [[ "${dict[install_luarocks]}" -eq 1 ]] && \
       koopa install luarocks
    [[ "${dict[install_lmod]}" -eq 1 ]] && \
       koopa install lmod
    [[ "${dict[install_htop]}" -eq 1 ]] && \
       koopa install htop
    # Install R.
    if [[ "${dict[install_r]}" -eq 1 ]]
    then
        if [[ "${dict[r_version]}" == 'devel' ]]
        then
            # Currently only supported for Debian.
            koopa install r-devel
        else
            if koopa_is_debian
            then
                koopa install r-cran-binary --version="${dict[r_version]}"
            elif koopa_is_fedora
            then
                koopa_assert_is_installed R
                koopa_configure_r
            else
                koopa install r --version="${dict[r_version]}"
            fi
        fi
    fi
    # Install RStudio software.
    [[ "${dict[install_rstudio_server]}" -eq 1 ]] && \
        koopa install rstudio-server
    [[  "${dict[install_shiny_server]}" -eq 1 ]] && \
        koopa install shiny-server
    # Ensure shared library configuration is current.
    [[ "${dict[install_lmod]}" -eq 1 ]] && \
        koopa_configure_lmod
    koopa_linux_update_ldconfig
    # Language-specific packages {{{2
    # --------------------------------------------------------------------------
    [[ "${dict[install_python_packages]}" -eq 1 ]] && \
       koopa install python-packages
    [[ "${dict[install_r_packages]}" -eq 1 ]] && \
       koopa install r-packages
    [[ "${dict[install_perl_packages]}" -eq 1 ]] && \
       koopa install perl-packages
    [[ "${dict[install_ruby_packages]}" -eq 1 ]] && \
       koopa install ruby-packages
    [[ "${dict[install_rust_packages]}" -eq 1 ]] && \
       koopa install rust-packages
    # Bioinformatics tools {{{2
    # --------------------------------------------------------------------------
    [[ "${dict[install_aspera_connect]}" -eq 1 ]] && \
       koopa install aspera-connect
    [[ "${dict[install_conda_envs]}" -eq 1 ]] && \
        conda-create-bioinfo-envs
    # Final steps {{{2
    # --------------------------------------------------------------------------
    # Generate an SSH key.
    [[ "${dict[ssh_key]}" -eq 1 ]] && \
        koopa_ssh_generate_key
    # Clean up and fix permissions {{{3
    # --------------------------------------------------------------------------
    koopa_sys_set_permissions --recursive "${prefixes[@]}"
    koopa_delete_broken_symlinks "${prefixes[@]}"
    # > koopa_delete_empty_dirs "${prefixes[@]}"
    # > koopa_fix_pyenv_permissions
    # > koopa_fix_rbenv_permissions
    koopa_fix_zsh_permissions
    if [[ "${dict[delete_cache]}" -eq 1 ]]
    then
        koopa_linux_delete_cache
    fi
    koopa_alert_success 'Configuration completed successfully.'
    return 0
}
