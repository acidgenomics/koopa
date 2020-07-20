#!/usr/bin/env bash

koopa::enable_passwordless_sudo() { # {{{1
    # """
    # Enable passwordless sudo access for all admin users.
    # @note Updated 2020-07-07.
    # """
    local group string sudo_file
    koopa::assert_has_no_args "$#"
    koopa::is_root && return 0
    koopa::assert_has_sudo
    group="$(koopa::admin_group)"
    sudo_file='/etc/sudoers.d/sudo'
    sudo touch "$sudo_file"
    if sudo grep -q "$group" "$sudo_file"
    then
        koopa::success "Passwordless sudo enabled for '${group}' group."
        return 0
    fi
    koopa::info "Updating '${sudo_file}' to include '${group}'."
    string="%${group} ALL=(ALL) NOPASSWD: ALL"
    sudo sh -c "printf '%s\n' '$string' >> '${sudo_file}'"
    sudo chmod -v 0440 "$sudo_file"
    koopa::success "Passwordless sudo enabled for '${group}'."
    return 0
}

koopa::enable_shell() { # {{{1
    # """
    # Enable shell.
    # @note Updated 2020-07-07.
    # """
    local cmd_name cmd_path etc_file
    koopa::assert_has_args "$#"
    koopa::has_sudo || return 0
    cmd_name="${1:?}"
    cmd_path="$(koopa::make_prefix)/bin/${cmd_name}"
    etc_file='/etc/shells'
    [[ -f "$etc_file" ]] || return 0
    koopa::info "Updating '${etc_file}' to include '${cmd_path}'."
    if ! grep -q "$cmd_path" "$etc_file"
    then
        sudo sh -c "printf '%s\n' '${cmd_path}' >> '${etc_file}'"
    else
        koopa::success "'${cmd_path}' already defined in '${etc_file}'."
    fi
    koopa::note "Run 'chsh -s ${cmd_path} ${USER}' to change default shell."
    return 0
}

koopa::install_tex_packages() { # {{{1
    local package packages
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed tlmgr
    koopa::h1 'Installing TeX packages recommended for RStudio.'
    sudo tlmgr update --self
    packages=(
        collection-fontsrecommended  # priority
        collection-latexrecommended  # priority
        bera  # beramono
        biblatex
        caption
        changepage
        csvsimple
        enumitem
        etoolbox
        fancyhdr
        footmisc
        framed
        geometry
        hyperref
        inconsolata
        logreq
        marginfix
        mathtools
        natbib
        nowidow
        parnotes
        parskip
        placeins
        preprint  # authblk
        sectsty
        soul
        titlesec
        titling
        units
        wasysym
        xstring
    )
    for package in "${packages[@]}"
    do
        sudo tlmgr install "$package"
    done
    return 0
}

koopa::rsync_cloud() { # {{{1
    local flags
    koopa::assert_has_args "$#"
    koopa::assert_is_installed rsync
    flags=(
        # '--exclude=bam'
        # '--exclude=cram'
        # '--exclude=fastq'
        # '--exclude=sam'
        '--exclude=.Rproj.user'
        '--exclude=.git'
        '--exclude=.gitignore'
        '--exclude=work'
        '--human-readable'
        '--no-links'
        '--progress'
        '--recursive'
        '--size-only'
        '--stats'
        '--verbose'
    )
    rsync "${flags[@]}" --rsync-path='sudo rsync' "$@"
    return 0
}

koopa::update_tex() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed tlmgr
    koopa::h1 'Updating TeX Live.'
    sudo tlmgr update --self
    sudo tlmgr update --list
    sudo tlmgr update --all
    return 0
}

