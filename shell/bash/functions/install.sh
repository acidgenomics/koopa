#!/usr/bin/env bash

koopa::install_chromhmm() {
    local file name prefix tmp_dir url
    koopa::assert_has_no_args "$#"
    name='ChromHMM'
    prefix="$(koopa::app_prefix)/$(koopa::lowercase "$name")"
    koopa::install_start "$name" "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="${name}.zip"
        url="http://compbio.mit.edu/${name}/${file}"
        koopa::download "$url"
        koopa::extract "$file"
        koopa::cp "$name" "$prefix"
    )
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name"
    return 0
}

koopa::install_conda() {
    local anaconda name_fancy ostype script tmp_dir url version
    koopa::exit_if_installed conda
    koopa::assert_has_no_envs
    ostype="${OSTYPE:?}"
    case "$ostype" in
        darwin*)
            ostype="MacOSX"
            ;;
        linux*)
            ostype="Linux"
            ;;
        *)
            koopa::stop "\"${ostype}\" is not supported."
            ;;
    esac
    anaconda=0
    version=
    while (("$#"))
    do
        case "$1" in
            --anaconda)
                anaconda=1
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    prefix="$(koopa::conda_prefix)"
    koopa::exit_if_dir "$prefix"
    if [[ "$anaconda" -eq 1 ]]
    then
        [[ -z "$version" ]] && version="$(koopa::variable 'anaconda')"
        name_fancy='Anaconda'
        script="Anaconda3-${version}-${ostype}-x86_64.sh"
        url="https://repo.anaconda.com/archive/${script}"
    else
        [[ -z "$version" ]] && version="$(koopa::variable 'conda')"
        name_fancy='Miniconda'
        # The py38 release is currently buggy.
        script="Miniconda3-py37_${version}-${ostype}-x86_64.sh"
        url="https://repo.continuum.io/miniconda/${script}"
    fi
    koopa::install_start "$name_fancy" "$prefix"
    koopa::mkdir "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        koopa::download "$url"
        bash "$script" -bf -p "$prefix"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::ln "$(koopa::prefix)/os/linux/etc/conda/condarc" "${prefix}/.condarc"
    koopa::remove_broken_symlinks "$prefix"
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

koopa::install_doom_emacs() {
    local doom emacs_prefix install_dir name repo
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed git tee
    name='doom'
    emacs_prefix="$(koopa::emacs_prefix)"
    install_dir="${emacs_prefix}-${name}"
    koopa::exit_if_dir "$install_dir"
    koopa::install_start "$name" "$install_dir"
    (
        repo='https://github.com/hlissner/doom-emacs'
        git clone "$repo" "$install_dir"
        doom="${install_dir}/bin/doom"
        "$doom" quickstart
        "$doom" refresh
        "$doom" doctor
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::link_emacs "$name"
    koopa::install_success "$name"
    return 0
}

koopa::install_ensembl_perl_api() {
    local name_fancy prefix
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::app_prefix)/ensembl"
    koopa::exit_if_dir "$prefix"
    name_fancy='Ensembl Perl API'
    koopa::install_start "$name_fancy" "$prefix"
    koopa::mkdir "$prefix"
    (
        koopa::cd "$prefix"
        # Install BioPerl.
        git clone -b release-1-6-924 --depth 1 \
            "https://github.com/bioperl/bioperl-live.git"
        git clone "https://github.com/Ensembl/ensembl-git-tools.git"
        git clone "https://github.com/Ensembl/ensembl.git"
        git clone "https://github.com/Ensembl/ensembl-variation.git"
        git clone "https://github.com/Ensembl/ensembl-funcgen.git"
        git clone "https://github.com/Ensembl/ensembl-compara.git"
        git clone "https://github.com/Ensembl/ensembl-io.git"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

koopa::install_perlbrew() { # {{{1
    # """
    # Install Perlbrew.
    # @note Updated 2020-07-10.
    #
    # Available releases:
    # > perlbrew available
    # """
    local all name_fancy prefix
    koopa::assert_has_args_le "$#" 1
    all=0
    while (("$#"))
    do
        case "$1" in
            --all)
                all=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::perlbrew_prefix)"
    koopa::exit_if_dir "$prefix"
    name_fancy='Perlbrew'
    koopa::install_start "$name_fancy" "$prefix"
    koopa::assert_has_no_envs
    koopa::assert_is_not_installed perlbrew
    export PERLBREW_ROOT="$prefix"

    # Install Perlbrew {{{2
    # --------------------------------------------------------------------------

    koopa::mkdir "$prefix"
    koopa::rm "${HOME}/.perlbrew"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='install.sh'
        url='https://install.perlbrew.pl'
        koopa::download "$url" "$file"
        chmod +x "$file"
        "./${file}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$prefix"
    koopa::activate_perlbrew

    # Add system Perl to Perlbrew {{{2
    # --------------------------------------------------------------------------

    if [[ -x "/usr/local/bin/perl" ]]
    then
        bin_dir="/usr/local/bin"
    elif [[ -x "/usr/bin/perl" ]]
    then
        bin_dir="/usr/bin"
    else
        bin_dir=
    fi
    if [[ -d "$bin_dir" ]]
    then
        koopa::h2 "Linking system Perl in perlbrew."
        (
            koopa::cd "${PERLBREW_ROOT}/perls"
            koopa::rm system
            koopa::mkdir system
            koopa::ln "$bin_dir" "system/bin"
        )
    fi

    # Install latest Perl and pinned version for Ensembl Perl API {{{2
    # --------------------------------------------------------------------------

    if [[ "$all" -eq 1 ]]
    then
        perls=(
            "perl-$(koopa::variable ensembl-perl)"
            "perl-$(koopa::variable perl)"
        )
        installed="$(perlbrew list)"
        for perl in "${perls[@]}"
        do
            koopa::str_match "$installed" "$perl" && continue
            koopa::h2 "Installing '${perl}'."
            koopa::coffee_time
            perlbrew install "$perl"
            koopa::install_success "$perl"
        done
    fi
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

koopa::install_perlbrew_perl() {
    # """
    # Install Perlbrew Perl.
    # @note Updated 2020-07-10.
    #
    # Note that 5.30.1 is currently failing with Perlbrew on macOS.
    # Using the '--notest' flag to avoid this error.
    #
    # See also:
    # - https://www.reddit.com/r/perl/comments/duddcn/perl_5301_released/
    # """
    local perl_name version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed perlbrew
    version="$(koopa::variable perl)"
    perl_name="perl-${version}"
    # Alternatively, can use '--force' here.
    perlbrew --notest install "$perl_name"
    perlbrew switch "$perl_name"
    # > perlbrew list
    return 0
}

koopa::install_pip() { # {{{1
    # """
    # Install pip for Python.
    # @note Updated 2020-07-10.
    # """
    local file name pos python reinstall tmp_dir url
    name='pip'
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
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
    koopa::assert_has_args_le "$#" 1
    python="${1:-python3}"
    if ! koopa::is_installed "$python"
    then
        koopa::warning "Python (\"${python}\") is not installed."
        return 1
    fi
    if [[ "$reinstall" -eq 0 ]]
    then
        if koopa::is_python_package_installed --python="$python" "$name"
        then
            koopa::note "Python package \"${name}\" is already installed."
            return 0
        fi
    fi
    koopa::install_start "$name"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='get-pip.py'
        url="https://bootstrap.pypa.io/${file}"
        koopa::download "$url"
        "$python" "$file" --no-warn-script-location
    )
    koopa::rm "$tmp_dir"
    koopa::install_success "$name"
    koopa::restart
    return 0
}

koopa::install_python_packages() {
    # """
    # Install Python packages.
    # @note Updated 2020-07-10.
    # These are used internally by koopa.
    # """
    local install_flags name_fancy pkgs pos python
    python="$(koopa::python)"
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
    koopa::assert_has_no_envs
    koopa::assert_is_installed "$python"
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        pkgs=(
            'setuptools'
            'wheel'
            'black==19.10b0'
            'flake8==3.8.3'
            'logbook==1.5.3'
            'pipx==0.15.4.0'
            'pyflakes==2.2.0'
            'pylint==2.5.3'
            'pytest==5.4.3'
            'six==1.15.0'
        )
    fi
    name_fancy='Python packages'
    koopa::install_start "$name_fancy"
    koopa::dl 'Site library' "$(koopa::python_site_packages_prefix)"
    install_flags=()
    [[ "$reinstall" -eq 1 ]] && install_flags+=('--reinstall')
    koopa::install_pip "${install_flags[@]}"
    koopa::pip_install "${install_flags[@]}" "${pkgs[@]}"
    koopa::is_cellar "$python" && koopa::link_cellar python
    koopa::install_success "$name_fancy"
    return 0
}

koopa::install_rbenv_ruby() {
    # """
    # Install latest verison of Ruby in rbenv.
    # @note Updated 2020-07-08.
    #
    # > rbenv install -l
    # > rbenv versions
    #
    # Ensure installation uses system OpenSSL.
    # > export RUBY_CONFIGURE_OPTS=--with-openssl-dir=/usr
    # """
    local name_fancy version
    koopa::assert_is_installed rbenv
    version="$(koopa::variable ruby)"
    # Ensure '2.6.5p' becomes '2.6.5', for example.
    version="$(koopa::sanitize_version "$version")"
    name_fancy="Ruby ${version}"
    koopa::install_start "$name_fancy"
    # Ensure ruby-build is current.
    ruby_build_dir="$(koopa::rbenv_prefix)/plugins/ruby-build"
    if [[ -d "$ruby_build_dir" ]]
    then
        koopa::note "Updating ruby-build plugin: \"${ruby_build_dir}\"."
        (
            koopa::cd "$ruby_build_dir"
            git pull --quiet
        )
    fi
    rbenv install "$version"
    rbenv global "$version"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::install_rcheck() {
    # """
    # Install Rcheck scripts for CI.
    # @note Updated 2020-07-08.
    # """
    local link_name name source_repo target_dir
    koopa::assert_has_no_args "$#"
    name='Rcheck'
    source_repo="https://github.com/acidgenomics/${name}.git"
    target_dir="$(koopa::local_app_prefix)/${name}"
    link_name=".${name}"
    koopa::install_start "$name"
    if [[ ! -d "$target_dir" ]]
    then
        koopa::h2 "Downloading ${name} to \"${target_dir}\"."
        (
            koopa::mkdir "$target_dir"
            git clone "$source_repo" "$target_dir"
        )
    fi
    koopa::ln "$target_dir" "$link_name"
    koopa::install_success "$name"
    return 0
}

koopa::install_ruby_packages() {
    koopa::assert_has_no_envs
    koopa::exit_if_not_installed gem
    name_fancy='Ruby gems'
    koopa::install_start "$name_fancy"
    # > gemdir="$(gem environment gemdir)"
    # > koopa::dl 'gemdir' "$gemdir"
    if [[ "$#" -eq 0 ]]
    then
        # > gem pristine --all --only-executables
        gems=(
            bashcov
            ronn
        )
    else
        gems=("$@")
    fi
    koopa::dl 'Gems' "$(koopa::to_string "${gems[@]}")"
    for gem in "${gems[@]}"
    do
        gem install "$gem"
    done
    koopa::install_success "$name_fancy"
    return 0
}

koopa::install_rust() {
    local file name_fancy pos reinstall tmp_dir url
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
    CARGO_HOME="$(koopa::rust_cargo_prefix)"
    export CARGO_HOME
    RUSTUP_HOME="$(koopa::rust_rustup_prefix)"
    export RUSTUP_HOME
    if [[ "$reinstall" -eq 1 ]]
    then
        koopa::sys_rm "$CARGO_HOME" "$RUSTUP_HOME"
    fi
    koopa::exit_if_dir "$CARGO_HOME" "$RUSTUP_HOME"
    name_fancy='Rust'
    koopa::install_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::assert_is_not_installed rustup-init
    koopa::dl 'CARGO_HOME' "$CARGO_HOME"
    koopa::dl 'RUSTUP_HOME' "$RUSTUP_HOME"
    koopa::mkdir "$CARGO_HOME" "$RUSTUP_HOME"
    tmp_dir="$(koopa::tmp_dir)"
    (
        url='https://sh.rustup.rs'
        file='rustup.sh'
        koopa::download "$url" "$file"
        chmod +x file
        ./rustup.sh --no-modify-path -v -y
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$CARGO_HOME" "$RUSTUP_HOME"
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

koopa::install_rust_packages() {
    # """
    # Install Rust packages.
    # @note Updated 2020-07-10.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # install-update now supported:
    # - https://stackoverflow.com/questions/34484361
    # - https://github.com/rust-lang/cargo/pull/6798
    # - https://github.com/rust-lang/cargo/pull/7560
    # """
    local crate crates name_fancy prefix
    koopa::assert_has_no_envs
    koopa::activate_rust
    koopa::exit_if_not_installed cargo rustc rustup
    name_fancy='Rust cargo crates'
    prefix="${CARGO_HOME:?}"
    koopa::install_start "$name_fancy" "$prefix"
    if [[ "$#" -eq 0 ]]
    then
        crates=(
            'bat'
            'broot'
            'du-dust'
            'exa'
            'fd-find'
            'hyperfine'
            'ripgrep'
            'tokei'
            'xsv'
        )
    else
        crates=("$@")
    fi
    koopa::dl 'Crates' "$(koopa::to_string "${crates[@]}")"
    koopa::sys_set_permissions -ru "$prefix"
    for crate in "${crates[@]}"
    do
        cargo install "$crate"
    done
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::install_spacemacs() {
    # """
    # Install Spacemacs.
    # @note Updated 2020-07-10.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local emacs_prefix install_dir name
    name='spacemacs'
    emacs_prefix="$(koopa::emacs_prefix)"
    install_dir="${emacs_prefix}-${name}"
    koopa::exit_if_dir "$install_dir"
    koopa::h1 "Installing ${name} at '${install_dir}."
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed emacs
    (
        repo="https://github.com/syl20bnr/${name}.git"
        git clone "$repo" "$install_dir"
        koopa::cd "$install_dir"
        git checkout -b develop origin/develop
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::link_emacs "$name"
    koopa::update_spacemacs
    koopa::install_success "$name"
    return 0
}

