#!/usr/bin/env bash

# FIXME RETHINK THE VARIABLE AND FLAG SUPPORT HERE.
# NEED BIOCONDUCTOR BASE IMAGE BUILT ON DEBIAN.
# --no-r
# --no-python
# --no-r-packages
# --no-python-packages
# --bioconductor
# --bioconductor-base

koopa::configure_vm() { # {{{1
    # """
    # Configure virtual machine.
    # @note Updated 2020-10-31.
    # """
    local app_prefix app_prefix_bn app_prefix_real bioconductor \
        data_disk data_disk_link data_disk_real docker full \
        gb_total install_base_flags install_perl_packages install_python \
        install_python_packages install_r install_r_packages \
        install_ruby_packages install_rust_packages make_prefix minimal pos \
        prefixes python_version r_version rsync source_ip
    koopa::assert_has_no_envs
    # Bioconductor mode, for continuous integration (CI) checks.
    # This flag is intended installing different R/BioC versions on top of the
    # Bioconductor (Debian) base image.
    bioconductor=0
    # By default, this script skips installation of GNU utils and other
    # dependencies that can take a long time to build from source. This works
    # well for Docker builds but may not support additional software required on
    # a full VM. Pass '--full' flag to enable more source builds.
    full=0
    # Minimal config used for lightweight Docker images. This mode skips all
    # program installation.
    minimal=0

    install_base_flags=()

    install_aspera_connect=0
    install_aws_cli=1
    install_conda=1
    install_conda_envs=0
    install_llvm=0
    install_lmod=0
    install_openjdk=1
    install_perl_packages=0
    install_python=1
    install_python_packages=1
    install_r=1
    install_r_packages=1
    install_rstudio_server=0
    install_ruby_packages=0
    install_rust_packages=0
    install_shiny_server=0

    passwordless_sudo=1
    remove_skel=1
    ssh_key=1

    # Which conda to install (miniconda or anaconda).
    conda='miniconda'

    # Python version.
    python_version="$(koopa::variable 'python')"
    # R version.
    r_version="$(koopa::variable 'r')"

    # Data disk to use for app configuration. Intended for full AWS EC2 or
    # Azure VM instances.
    data_disk=
    # Source IP (for rsync mode).
    source_ip=

    # Parse arguments.
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Modes ------------------------------------------------------------
            --bioconductor)
                bioconductor=1
                shift 1
                ;;
            --full)
                full=1
                shift 1
                ;;
            --minimal)
                minimal=1
                shift 1
                ;;
            # Rsync settings ---------------------------------------------------
            --data-disk=*)
                data_disk="${1#*=}"
                shift 1
                ;;
            --source-ip=*)
                source_ip="${1#*=}"
                shift 1
                ;;
            # Versions ---------------------------------------------------------
            --python-version=*)
                python_version="${1#*=}"
                shift 1
                ;;
            --r-version=*)
                r_version="${1#*=}"
                shift 1
                ;;
            # Overrides --------------------------------------------------------
            --no-passwordless-sudo)
                passwordless_sudo=0
                shift 1
                ;;
            --no-remove-skel)
                remove_skel=0
                shift 1
                ;;
            # Additional parsing -----------------------------------------------
            '')
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
    koopa::assert_has_no_args "$#"

    # FIXME CHECK FOR INPUT OF SINGLE MODE FLAG.

    # Are we building from source inside Docker?
    koopa::is_docker && docker=1 || docker=0
    # Are we rsyncing files from a source machine?
    [[ -n "$source_ip" ]] && rsync=1 || rsync=0
    if [[ "$docker" -eq 1 ]]
    then
        ssh_key=0
    fi
    if [[ "$bioconductor" -eq 1 ]]
    then
        install_aws_cli=0
        install_llvm=1
        install_python_packages=0
        install_r=0
        install_r_packages=0
        install_rstudio_server=1
        install_shiny_server=0
    elif [[ "$full" -eq 1 ]]
    then
        conda='anaconda'
        install_aspera_connect=1
        install_conda_envs=1
        install_llvm=1
        install_lmod=1
        install_perl_packages=1
        install_rstudio_server=1
        install_ruby_packages=1
        install_rust_packages=1
        install_shiny_server=1
        install_base_flags+=('--full')
    fi
    if [[ "$rsync" -eq 1 ]]
    then
        install_aspera_connect=0
        install_conda=0
        install_conda_envs=0
        install_perl_packages=0
        install_python_packages=0
        install_r_packages=0
        install_ruby_packages=0
        install_rust_packages=0
    fi
    # e.g. '/usr/local'.
    make_prefix="$(koopa::make_prefix)"
    # For data disk, linked to '/mnt/data01/n/opt' (see below).
    # e.g. '/usr/local/opt'.
    app_prefix="$(koopa::app_prefix)"

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

    if [[ "$passwordless_sudo" -eq 1 ]]
    then
        koopa::enable_passwordless_sudo
        koopa::fix_sudo_setrlimit_error
    fi

    # Remove skeleton files {{{3
    # --------------------------------------------------------------------------

    # Remove default user-specific skeleton configuration files. This in
    # particular helps keep shell configuration consistent, especialy for
    # Ubuntu, which sets a lot of config in bashrc.
    if [[ "$remove_skel" -eq 1 ]]
    then
        koopa::rm -S '/etc/skel'
    fi

    # Early return in minimal mode {{{3
    # --------------------------------------------------------------------------

    if [[ "$minimal" -eq 1 ]]
    then
        koopa::success 'Configuration completed successfully.'
        return 0
    fi

    # Local disk configuration {{{3
    # --------------------------------------------------------------------------

    if [[ "$docker" -eq 0 ]]
    then
        koopa::info 'Checking available local disk space.'
        df -h '/'
        gb_total="$(koopa::disk_gb_total)"
        [[ "$gb_total" -lt 16 ]] && full=0
        # > gb_free="$(koopa::disk_gb_free)"
        # > [[ "$gb_free" -lt 10 ]] && full=0
        # Attempt to detect an attached disk automatically.
        if [[ ! -e "$data_disk" ]]
        then
            # Our current standard configuration on AWS EC2 VMs.
            [[ -e '/mnt/data01' ]] && data_disk='/mnt/data01'
        fi
        if [[ -e "$data_disk" ]]
        then
            koopa::info "Data disk detected at '${data_disk}'."
        fi
    fi
    # Prepare app prefix on external disk for write access (e.g. '/n').
    data_disk_link="$(koopa::data_disk_link_prefix)"
    if [[ -e "$data_disk" ]] && \
        { [[ ! -L "$data_disk_link" ]] || [[ ! -L "$app_prefix" ]]; }
    then
        koopa::h2 "Symlinking '${data_disk_link}' on '${data_disk}'."
        koopa::sys_rm "$data_disk_link" "$app_prefix"
        # e.g. '/mnt/data01/n'.
        data_disk_real="${data_disk}${data_disk_link}"
        koopa::sys_ln "$data_disk_real" "$data_disk_link"
        # e.g. 'opt'.
        app_prefix_bn="$(basename "$app_prefix")"
        # e.g. '/mnt/data01/n/opt'
        app_prefix_real="${data_disk_real}/${app_prefix_bn}"
        koopa::mkdir "$app_prefix_real"
        # e.g. '/mnt/data01/n/opt' to '/usr/local/opt'.
        koopa::sys_ln "$app_prefix_real" "$app_prefix"
    else
        koopa::mkdir "$app_prefix"
    fi

    # Base system {{{2
    # --------------------------------------------------------------------------

    koopa::h2 'Installing base system.'
    koopa::update_etc_profile_d
    koopa::install_dotfiles
    koopa::mkdir "$make_prefix"
    koopa::assert_is_installed install-base
    install-base "${install_base_flags[@]:-}"
    koopa::assert_is_installed \
        'autoconf'    'bc'   'bzip2' 'g++'    'gcc' 'gfortran' \
        'gzip'        'make' 'man'   'msgfmt' 'tar' 'unzip' \
        'xml2-config' 'xz'
    koopa::assert_is_file '/usr/bin/gcc' '/usr/bin/g++'
    sudo ldconfig

    # rsync mode {{{2
    # --------------------------------------------------------------------------

    [[ "$rsync" -eq 1 ]] && \
        koopa::rsync_vm --source-ip="$source_ip"

    # Programs {{{2
    # --------------------------------------------------------------------------

    [[ "$install_python" -eq 1 ]] && \
        install-python --version="$python_version"
    [[ "$install_conda" -eq 1 ]] && \
        "install-${conda}"
    [[ "$install_openjdk" -eq 1 ]] && \
        install-openjdk
    [[ "$install_llvm" -eq 1 ]] && \
        koopa::run_if_installed install-llvm
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
        # > install-the-silver-searcher
    fi
    install-tmux
    install-vim
    install-shellcheck
    install-shunit2
    [[ "$install_aws_cli" -eq 1 ]] && \
        install-aws-cli
    if [[ "$full" -eq 1 ]]
    then
        koopa::run_if_installed \
            install-azure-cli \
            install-docker \
            install-google-cloud-sdk
        install-password-store
        install-docker-credential-pass
        install-neovim
        install-emacs
        install-julia
        install-lua
        install-luarocks
        install-lmod
        install-htop
        install-autojump
        # > install-gcc
    fi
    # Install R.
    if [[ "$install_r" -eq 1 ]]
    then
        if koopa::is_fedora
        then
            koopa::assert_is_installed R
        elif [[ "$r_version" == 'devel' ]]
        then
            install-r-devel
        elif koopa::is_installed install-r-cran-binary
        then
            install-r-cran-binary --version="$r_version"
        else
            install-r --version="$r_version"
        fi
        koopa::update_r_config
    fi
    [[ "$install_rstudio_server" -eq 1 ]] && \
        koopa::run_if_installed install-rstudio-server
    [[  "$install_shiny_server" -eq 1 ]] && \
        koopa::run_if_installed install-shiny-server
    [[ "$install_lmod" -eq 1 ]] && \
        koopa::update_lmod_config
    sudo ldconfig

    # Language-specific packages {{{2
    # --------------------------------------------------------------------------

    [[ "$install_python_packages" -eq 1 ]] && \
        install-python-packages
    [[ "$install_r_packages" -eq 1 ]] && \
        install-r-packages
    [[ "$install_python_packages" -eq 1 ]] && \
        install-python-packages
    [[ "$install_r_packages" -eq 1 ]] && \
        install-r-packages
    [[ "$install_perl_packages" -eq 1 ]] && \
        install-perl-packages
    [[ "$install_ruby_packages" -eq 1 ]] && \
        install-ruby-packages
    [[ "$install_rust_packages" -eq 1 ]] && \
        install-rust-packages

    # Bioinformatics tools {{{2
    # --------------------------------------------------------------------------

    [[ "$install_aspera_connect" -eq 1 ]] && \
        install-aspera-connect
    [[ "$install_conda_envs" -eq 1 ]] && \
        conda-create-bioinfo-envs

    # Final steps and clean up {{{2
    # --------------------------------------------------------------------------

    # Generate SSH key {{{3
    # --------------------------------------------------------------------------

    [[ "$ssh_key" -eq 1 ]] && \
        koopa::generate_ssh_key

    # Remove legacy packages {{{3
    # --------------------------------------------------------------------------

    # Ensure that perlbrew, pyenv, and rbenv are no longer installed by default.
    koopa::sys_rm \
        "${app_prefix}/perl" \
        "${app_prefix}/python/pyenv" \
        "${app_prefix}/perl"
    # Otherwise, ensure permissions are correct.
    # > koopa::fix_pyenv_permissions
    # > koopa::fix_rbenv_permissions

    # Fix permissions and clean up {{{3
    # --------------------------------------------------------------------------

    prefixes=("$make_prefix" "$app_prefix")
    koopa::sys_set_permissions -r "${prefixes[@]}"
    koopa::remove_broken_symlinks "${prefixes[@]}"
    # > koopa::remove_empty_dirs "${prefixes[@]}"
    koopa::fix_zsh_permissions

    # Remove temporary files {{{3
    # --------------------------------------------------------------------------

    if [[ "$docker" -eq 1 ]]
    then
        koopa::h2 'Removing caches, logs, and temporary files.'
        # Don't clear '/var/log/' here, as this can mess with 'sshd'.
        koopa::rm -S \
            '/root/.cache' \
            '/tmp/'* \
            '/var/backups/'* \
            '/var/cache/'*
        koopa::is_debian_like && \
            koopa::rm -S '/var/lib/apt/lists/'*
    fi

    koopa::success 'Configuration completed successfully.'
    return 0
}
