#!/usr/bin/env bash

koopa::configure_vm() { # {{{1
    # """
    # Configure virtual machine.
    # @note Updated 2020-10-29.
    # """
    local app_prefix app_prefix_bn app_prefix_real bioconductor data_disk \
        data_disk_link data_disk_real docker full gb_total \
        install_base_flags make_prefix minimal pos prefixes r_version rsync \
        source_ip
    koopa::assert_has_no_envs
    # Bioconductor mode, for continuous integration (CI) checks.
    bioconductor=0
    # Are we building from source inside Docker?
    docker=0
    # By default, this script skips installation of GNU utils and other
    # dependencies that can take a long time to build from source. This works
    # well for Docker builds but may not support additional software required on
    # a full VM. Pass '--full' flag to enable more source builds.
    full=0
    # Minimal config used for lightweight Docker images. This mode skips all
    # program installation.
    minimal=0
    # Used for app configuration.
    data_disk=
    # Skip rsync mode by default.
    rsync=0
    # Used for rsync mode.
    source_ip=
    # Set the desired R version automatically.
    r_version="$(koopa::variable 'r')"
    pos=()
    while (("$#"))
    do
        case "$1" in
            --bioconductor)
                bioconductor=1
                shift 1
                ;;
            --data-disk=*)
                data_disk="${1#*=}"
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
            --r-version=*)
                r_version="${1#*=}"
                shift 1
                ;;
            --source-ip=*)
                source_ip="${1#*=}"
                shift 1
                ;;
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
    [[ -n "$source_ip" ]] && rsync=1
    koopa::is_docker && docker=1

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

    koopa::enable_passwordless_sudo
    koopa::fix_sudo_setrlimit_error

    # Remove skeleton files {{{3
    # --------------------------------------------------------------------------

    # Remove default user-specific skeleton configuration files. This in
    # particular helps keep shell configuration consistent, especialy for
    # Ubuntu, which sets a lot of config in bashrc.
    koopa::rm -S '/etc/skel'

    # Early return in minimal mode {{{3
    # --------------------------------------------------------------------------

    if [[ "$minimal" -eq 1 ]]
    then
        koopa::success 'Configuration completed successfully.'
        return 0
    fi

    # Koopa paths {{{3
    # --------------------------------------------------------------------------

    # e.g. '/usr/local'.
    make_prefix="$(koopa::make_prefix)"
    # For data disk, linked to '/mnt/data01/n/opt' (see below).
    # e.g. '/usr/local/opt'.
    app_prefix="$(koopa::app_prefix)"

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
    install_base_flags=()
    [[ "$full" -eq 1 ]] && install_base_flags+=('--full')
    install-base "${install_base_flags[@]:-}"
    koopa::assert_is_installed \
        'autoconf' \
        'bc' \
        'bzip2' \
        'g++' \
        'gcc' \
        'gfortran' \
        'gzip' \
        'make' \
        'man' \
        'msgfmt' \
        'tar' \
        'unzip' \
        'xml2-config' \
        'xz'
    koopa::assert_is_file \
        '/usr/bin/gcc' \
        '/usr/bin/g++'
    sudo ldconfig

    # rsync mode {{{2
    # --------------------------------------------------------------------------

    [[ "$rsync" -eq 1 ]] && koopa::rsync_vm --source-ip="$source_ip"

    # Programs {{{2
    # --------------------------------------------------------------------------

    install-python
    if [[ "$full" -eq 1 ]]
    then
        install-anaconda
    else
        install-miniconda
    fi
    # > if [[ "$bioconductor" -eq 1 ]]
    # > then
    # >     conda-create-bioinfo-envs --reticulate
    # > fi
    install-openjdk
    if [[ "$bioconductor" -eq 1 ]] || [[ "$full" -eq 1 ]]
    then
        koopa::run_if_installed install-llvm
    fi
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
    fi
    if [[ "$full" -eq 1 ]] || koopa::is_rhel_ubi
    then
        install-libevent
        install-taglib
        install-zsh
    fi
    if [[ "$full" -eq 1 ]]
    then
        install-bash
        install-fish
        install-git
        install-openssh
        install-perl
        install-geos
        install-sqlite
    fi
    if [[ "$full" -eq 1 ]] || koopa::is_rhel_ubi
    then
        install-proj
        install-gdal
        install-hdf5
        install-gsl
    fi
    if [[ "$full" -eq 1 ]]
    then
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
    if [[ "$bioconductor" -eq 1 ]] || [[ "$full" -eq 1 ]]
    then
        koopa::run_if_installed install-rstudio-server install-shiny-server
    fi
    # Ensure configuration is current.
    koopa::update_r_config
    koopa::update_lmod_config
    sudo ldconfig

    # Language-specific packages {{{2
    # --------------------------------------------------------------------------

    if [[ "$rsync" -eq 0 ]]
    then
        # Install Python and R packages, except for Bioconductor base image.
        if [[ "$bioconductor" -eq 0 ]]
        then
            install-python-packages
            # FIXME This may not set up bb8 correctly on BioC images if skipped.
            install-r-packages
        fi
        if [[ "$full" -eq 1 ]]
        then
            install-perl-packages
            install-ruby-packages
            install-rust-packages
        fi
    fi

    # Bioinformatics tools {{{2
    # --------------------------------------------------------------------------

    if [[ "$full" -eq 1 ]] && [[ "$rsync" -eq 0 ]]
    then
        install-aspera-connect
        conda-create-bioinfo-envs
        # > install-bcbio
    fi

    # Final steps and clean up {{{2
    # --------------------------------------------------------------------------

    # Generate SSH key {{{3
    # --------------------------------------------------------------------------

    [[ "$docker" -eq 0 ]] && koopa::generate_ssh_key

    # Remove legacy packages {{{3
    # --------------------------------------------------------------------------

    # Ensure that perlbrew, pyenv, and rbenv are no longer installed by default.
    koopa::sys_rm \
        "${app_prefix}/perl" \
        "${app_prefix}/python/pyenv" \
        "${app_prefix}/perl"
    # Otherwise, ensure permissions are correct:
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
